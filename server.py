#!/usr/bin/env python 
import SocketServer 
from time import ctime 
import simplejson

playerCount = []

snakePos = None
foods = None
eatFoods = None
allDirections = None
directions = None
names = None
dataBig = None
dataSmall = None

HOST = '127.0.0.1' 
PORT = 8080 
ADDR = (HOST, PORT) 

class MyRequestHandler(SocketServer.BaseRequestHandler): 
   def handle(self): 
       print '...connected from:', self.client_address 
       while True: 
            dict = simplejson.loads(self.request.recv(1024))
            data[dict["name"]]["mySnakePos"] = dict["mySnakePos"]

            
            if dict["food"] != None and dict["food"] != "had":
                foods = dict["food"]

            sendData = {}
            sendData["map"] = 1
            if playerCount == 0 or dict["food"] == "had":
                sendData["food"] = None
            else :
                sendData["food"] = foods

            self.request.sendall(self.request.recv(1024)) 
           
tcpServ = SocketServer.ThreadingTCPServer(ADDR, MyRequestHandler) 
print 'waiting for connection...' 
tcpServ.serve_forever()