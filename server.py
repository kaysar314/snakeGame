#!/usr/bin/env python 
import SocketServer 
from time import ctime 
import simplejson

player = {}
foods = {}
data = {}

HOST = '127.0.0.1' 
PORT = 8080 
ADDR = (HOST, PORT) 

class MyRequestHandler(SocketServer.BaseRequestHandler): 
   def handle(self): 
       print '...connected from:', self.client_address 
       while True: 
            dic = simplejson.loads(self.request.recv(1024))

            data[dic["name"]] = {"snakePos":dic["mySnakePos"],"color":dic["color"]}

            print dic
            sendData = {}
            sendData["map"] = 1

            if dic.get("type") == "ctor":
                player[dic["name"]] = ''
                print player
                if len(dic) == 1:
                    sendData["food"] = None
                # else:
                    # sendData["food"] = foods
            else:
                if dic["food"] != None:
                    foods = dic["food"]
            print data
            sendData["data"] = data
            sendData["live"] = True
            print simplejson.dumps(sendData)+'\n'
            self.request.sendall(simplejson.dumps(sendData)+'\n')
           
tcpServ = SocketServer.ThreadingTCPServer(ADDR, MyRequestHandler) 
print 'waiting for connection...' 
tcpServ.serve_forever()