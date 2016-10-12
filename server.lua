-- -- server.lua
-- local socket = require("socket")
local json = require("json")
-- local host = "127.0.0.1"
-- local port = "8080"
-- local server = assert(socket.bind(host, port, 1024))
-- server:settimeout(0)
-- local client_tab = {}
-- local conn_count = 0
 
-- print("Server Start " .. host .. ":" .. port) 

-- while 1 do
--     local conn = server:accept()
--     if conn then
--         conn_count = conn_count + 1
--         client_tab[conn_count] = conn
--         print("A client successfully connect!") 
--     end

--     for conn_count, client in pairs(client_tab) do
--         local receive, receive_status = client:receive()
--         if receive_status ~= "closed" then
--             if receive then
--                 -- assert(client:send("Client " .. conn_count .. " Send : "))
--                 assert(client:send(receive .. "\n"))
--                 print("Receive Client " .. conn_count .. " : ", receive)   
--             end
--         else
--             table.remove(client_tab, conn_count) 
--             client:close() 
--             print("Client " .. conn_count .. " disconnect!") 
--         end
--     end
-- end

-- local a = {1, 2, 3}
-- a["2"] = 3
-- table.insert(a, 1)
-- table.insert(a, 2)
-- table.insert(a, 3)
-- table.insert(a, 4)
-- table.insert(a, 5)
-- table.insert(a, 6)
-- table.insert(a, 7)
-- print(a[6])
-- print(a["6"])
-- print(json.encode(a))

pair = "2231,333"

_, _, key, value = string.find(pair, "(%d+)%s*,%s*(%d+)")

print(key)
print(value)