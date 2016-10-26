CONST_Socket_TickTime = 0.05
CONST_Socket_ReconnectTime = 5

CONST_HeartBeaT_TimeOut = 20
CONST_HeartBeaT_SendTime = 15
CONST_HeartBeaT_CheckTime = 25
packType_heartbeat = 1
packType_message = 2
packType_welcome = 3

local Tcp = class("Tcp")
local scheduler = require("framework.scheduler")
local socket = require "socket"

function Tcp:ctor(host, port)  
    self.host = nil
    self.port = nil
	self.tickScheduler = nil
	self.timeCheckScheduler = nil
	self.heartbeatScheduler = nil
	self.reconnectScheduler = nil
	self.connectTimeTickScheduler = nil
	self.lastHeartbeatTime = os.time()
	self.name = 'SnakeTcp'
	self.tcp = nil
	self.isRetryConnect = true
	self.isConnected = false
	self.delegate = nil
end

function Tcp:setDelegate (delegate)
	self.delegate = delegate
end

function Tcp:setName( name )
	self.name = name
end

function Tcp:connect(host, port)
	if host then self.host = host end
	if port then self.port = port end
	self.tcp = assert (socket.connect (host, port))
	self.tcp:settimeout(0)

	-- test timeout
	-- not connect after 2s as not connect
	local connectTimeTick = function ()
		print(self.name, "connectTimeTick")
		if not self.isConnected then
	    	self:doClose()
			self:onConnectFailure()
		end
	end
	self.connectTimeTickScheduler = scheduler.performWithDelayGlobal(connectTimeTick, 3)
	local tick = function()
		recvt, sendt, status = socket.select({self.tcp}, nil, 1)
    	while #recvt > 0 do
    	    local response, receive_status = self.tcp:receive()
    	    if receive_status ~= "closed" and receive_status ~= "Socket is not connected" then
    	        if response then
    	            print(response)
    	            self:onPacket(response)
    	            recvt, sendt, status = socket.select({self.tcp}, nil, 1)
    	        end
    	    else
    	        self:doClose()
			    if self.isConnected then
			    	self:onDisconnect()
			    else 
			    	self:onConnectFailure()
			    end
			   	return
    	    end
    	end
	end
	-- read recv
	self.tickScheduler = scheduler.scheduleGlobal(tick, CONST_Socket_TickTime)
end

function Tcp:doClose( ... )
	print(self.name, "Tcp:doClose")
	self.tcp:close();
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end
	if self.tickScheduler then scheduler.unscheduleGlobal(self.tickScheduler) end
	if self.heartbeatScheduler then scheduler.unscheduleGlobal(self.heartbeatScheduler) end
	if self.timeCheckScheduler then scheduler.unscheduleGlobal(self.timeCheckScheduler) end
end

-- protocal
function Tcp:onDisconnect()
	print(self.name, "onDisconnect");
	self.isConnected = false
	self:_reconnect();
	self.delegate:onDisconnect();
end

-- connect server successful
function Tcp:onConnected()
	print(self.name, "Tcp:onConnected")
	self.isConnected = true
	local _sendHeartbeat = function ()
		self:sendStr(packType_heartbeat, 0, '{}')
	end
	local _checkHeartBeat = function ()
		print(self.name, "_checkHeartBeat", self.lastHeartbeatTime)
		if os.time() - self.lastHeartbeatTime > CONST_HeartBeaT_TimeOut then
			print(self.name, "心跳超时")
			self:_disconnect()
		end
	end
	-- self.heartbeatScheduler = scheduler.scheduleGlobal(_sendHeartbeat, CONST_HeartBeaT_SendTime, false)
	-- self.timeCheckScheduler = scheduler.scheduleGlobal(_checkHeartBeat, CONST_HeartBeaT_CheckTime, false)
	self.delegate:onConnected();
end

-- 
function Tcp:onConnectFailure(status)
	print(self.name, "Tcp:onConnectFailure");
	self:_reconnect();
end

-- get data from server
function Tcp:onPacket(message)
	print(self.name, "onPacket", message, os.time())
	self.lastHeartbeatTime = os.time()
	self:onConnected()
	local data = JSON.decode(message);
end

-- method
-- inside method disconnect
function Tcp:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
end

-- disconnect by self
function Tcp:disconnect()
	self:_disconnect()
	self.isRetryConnect = false--主动性断开不重连
end

-- reconnect
-- disconnect not by self, will reconnect in 3s 
-- disconnect by self will not reconnect
function Tcp:_reconnect()
	print(self.name, "_reconnect")
	if not self.isRetryConnect then return end--不允许重连
	if self.reconnectScheduler then scheduler.unscheduleGlobal(self.reconnectScheduler) end
	local _doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = scheduler.performWithDelayGlobal(_doReConnect, CONST_Socket_ReconnectTime)
end

--do send jsonstr
function Tcp:sendStr(jsonStr)
	if self.isConnected == false then return end
	local _sendStr = jsonStr
	print('sendStr:', _sendStr)
	assert(self.tcp:send(_sendStr))
end

--do send table
function Tcp:send(data)
	self:sendStr(data)
end

function Tcp:doEmit( serverEvent, data )
	self:sendStr(packType_message, serverEvent, JSON.encode(data))
end

return Tcp