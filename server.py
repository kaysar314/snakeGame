#!/usr/bin/env python 
import SocketServer 
from time import ctime 
import simplejson

player = {}
foods = None
data = None

HOST = '127.0.0.1' 
PORT = 8080 
ADDR = (HOST, PORT) 

class MyRequestHandler(SocketServer.BaseRequestHandler): 
   def handle(self): 
       print '...connected from:', self.client_address 
       while True: 
            dict = simplejson.loads(self.request.recv(1024))
            data[dict["name"]]["snakePos"] = dict["mySnakePos"]
            data[dict["name"]]["color"] = dict["color"]

            sendData = {}
            sendData["map"] = 1

            if dict["type"] == "ctor":
                player[dict["name"]] = ''
                if len(dict) == 1:
                    sendData["food"] = None
                else:
                    sendData["food"] = foods
            else:
                if dict["food"] != None:
                    foods = dict["food"]

            sendData["data"] = data
            sendData["live"] = True

            self.request.sendall(simplejson.drump(sendData))
           
tcpServ = SocketServer.ThreadingTCPServer(ADDR, MyRequestHandler) 
print 'waiting for connection...' 
tcpServ.serve_forever()