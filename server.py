#!/usr/bin/env python 
import SocketServer 
from time import ctime 
import simplejson

player = {}
foods = {}
data = {}

HOST = '139.129.59.141' 
PORT = 9080 
ADDR = (HOST, PORT) 

class MyRequestHandler(SocketServer.BaseRequestHandler): 
   def handle(self): 
       print '...connected from:', self.client_address
       while True: 
            dic = simplejson.loads(self.request.recv(10240))

            data[dic["name"]] = {"snakePos":dic["mySnakePos"],"color":dic["color"],"live":dic["live"]}
            sendData = {}
            sendData["map"] = 1

            if dic.get("type") == "ctor":
                player[dic["name"]] = ''
                print "player num: ",len(player)
                if len(player) == 1:
                    print "has no food"
                    sendData["food"] = 0
                # else:
                #     print "get food"
                #     sendData["food"] = foods
            else:
                if dic["food"] != 0:
                    foods = dic["food"]
            sendData["data"] = data
            self.request.sendall(simplejson.dumps(sendData)+'\n')
           
tcpServ = SocketServer.ThreadingTCPServer(ADDR, MyRequestHandler) 
print 'waiting for connection...' 
tcpServ.serve_forever()