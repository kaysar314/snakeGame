--[[
  onlytcp lua客户端
		因为发现luasocket receive(number)方式的一个奇惨问题 所以收数据改成了按行读取
]]
CONST_Socket_TickTime = 0.1--SOCKET接收信息轮训时间
CONST_Socket_ReconnectTime = 5--socket重连偿试时间时隔

CONST_HeartBeaT_TimeOut = 20--socket心跳超时时间
CONST_HeartBeaT_SendTime = 15--socket心跳发送间隔
CONST_HeartBeaT_CheckTime = 25--socket心跳检查时间

packType_heartbeat = 1--心跳
packType_message = 2--信息包
packType_welcome = 3--心跳

local ONLYSocket = class("ONLYSocket")
local scheduler = require("framework.client.scheduler")

local socket = require "socket"

function ONLYSocket:ctor(host, port)  
    self.host = nil
    self.port = nil
	self.tickScheduler = nil--socket 消息接收定时器
	self.timeCheckScheduler = nil-- 心跳动超时检测定时器
	self.heartbeatScheduler = nil-- 心跳包定时发送定时器
	self.reconnectScheduler = nil-- 重连定时器
	self.connectTimeTickScheduler = nil--检测连接超时定时器
	self.lastHeartbeatTime = os.time()
	self.name = 'NTChatClient'
	self.tcp = nil
	self.isRetryConnect = true
	self.isConnected = false
	self.delegate = nil
end

--设置委托对像
function ONLYSocket:setDelegate (delegate)
	self.delegate = delegate
end

function ONLYSocket:setName( name )
	self.name = name
end

function ONLYSocket:connect(host, port)
	if host then self.host = host end
	if port then self.port = port end
	self.tcp = socket.tcp()
	self.tcp:settimeout(0)

	local response, status, partial = self.tcp:connect(self.host, self.port)
	--print("response", response);
	--print("status", status);
	--print("partial", partial);
	--检测连接超时
	--两秒后如果未连接视为连接失败
	local connectTimeTick = function ()
		print(self.name, "connectTimeTick")
		if not self.isConnected then
	    	self:doClose()
			self:onConnectFailure()
		end
	end
	self.connectTimeTickScheduler = scheduler.performWithDelayGlobal(connectTimeTick, 3)
	local tick = function()
		while true do
			local body, status, partial = self.tcp:receive("*l")--读取包体
    	    if status == "closed" or status == "Socket is not connected" then --如果读取失败 则跳出
		    	self:doClose()
		    	if self.isConnected then
		    		self:onDisconnect()
		    	else 
		    		self:onConnectFailure()
		    	end
		   		return
	    	end
		    if not body then return end
			local packArr = string.split(body, "::")
			local packType = tonumber(packArr[1]);
			local clientEvent = tonumber(packArr[2]);
			local message = packArr[3]
		    self:onPacket(packType, clientEvent, message)
		end
	end
	--开始读取TCP数据
	self.tickScheduler = scheduler.scheduleGlobal(tick, CONST_Socket_TickTime)
end

function ONLYSocket:doClose( ... )
	--print(self.name, "ONLYSocket:doClose")
	self.tcp:close();
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end
	if self.tickScheduler then scheduler.unscheduleGlobal(self.tickScheduler) end
	if self.heartbeatScheduler then scheduler.unscheduleGlobal(self.heartbeatScheduler) end
	if self.timeCheckScheduler then scheduler.unscheduleGlobal(self.timeCheckScheduler) end
end

--protocal
function ONLYSocket:onDisconnect()
	print(self.name, "onDisconnect");
	self.isConnected = false
	self:_reconnect();
	self.delegate:onDisconnect();
end

--成功建立连接
function ONLYSocket:onConnected()
	print(self.name, "ONLYSocket:onConnected")
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
	self.heartbeatScheduler = scheduler.scheduleGlobal(_sendHeartbeat, CONST_HeartBeaT_SendTime, false)
	self.timeCheckScheduler = scheduler.scheduleGlobal(_checkHeartBeat, CONST_HeartBeaT_CheckTime, false)
	self.delegate:onConnected();
end

--连接失败
function ONLYSocket:onConnectFailure(status)
	--print(self.name, "ONLYSocket:onConnectFailure");
	self:_reconnect();
end

--收到服务端数据
function ONLYSocket:onPacket(packType, clientEvent, message)
	print(self.name, "onPacket", packType, clientEvent, message, os.time())
	self.lastHeartbeatTime = os.time()
	if packType == packType_heartbeat then --收到心跳包
	elseif packType == packType_welcome then
		self:onConnected()
	else--收到数据包
		local data = JSON.decode(message);
		self.delegate.onMessage(clientEvent, data);
	end
end

--method
--断开连接 内部方法
function ONLYSocket:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
end

--用户主动退出
function ONLYSocket:disconnect()
	self:_disconnect()
	self.isRetryConnect = false--主动性断开不重连
end

--重连 
-- 非主动性断开3秒后重连 
--主动性断开不重连
function ONLYSocket:_reconnect()
	--print(self.name, "_reconnect")
	if not self.isRetryConnect then return end--不允许重连
	if self.reconnectScheduler then scheduler.unscheduleGlobal(self.reconnectScheduler) end
	local _doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = scheduler.performWithDelayGlobal(_doReConnect, CONST_Socket_ReconnectTime)
end

--do send jsonstr
function ONLYSocket:sendStr(packType, serverEvent, jsonStr)
	if self.isConnected == false then return end
	local _sendStr = packType.."::"..serverEvent.."::"..jsonStr..'\n'
	if packType > 1 then print('sendStr:', _sendStr) end
	--防止socket中断了还发消息造成crash
	local pool  = { self.tcp }
	-- rx, wr, er  = socket.select( nil, pool, 0.001 )
	-- if (er ~= nil) then return end;
	-- for n, sck in ipairs( wr ) do
	self.tcp:send(_sendStr)
	-- end
end

--do send table
function ONLYSocket:send(packType, serverEvent, data)
	self:sendStr(packType, serverEvent, JSON.encode(data))
end

--触发服务端事件
function ONLYSocket:doEmit( serverEvent, data )
	self:sendStr(packType_message, serverEvent, JSON.encode(data))
end

return ONLYSocket
--CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(test, 5, false)--10秒后退出
--testObj:connect('192,168.2.125', '7979')