#!/usr/bin/env python 
import SocketServer 
from time import ctime 
import simplejson
import threading

lock = threading.Lock()

player = {}
foods = {}
data = {}

HOST = '127.0.0.1' 
PORT = 8080 
ADDR = (HOST, PORT) 

class MyRequestHandler(SocketServer.BaseRequestHandler): 
   def handle(self): 
       # print '...connected from:', self.client_address
       while True: 
            lock.acquire()
            print self.client_address
            try:
                ddd = self.request.recv(10240)
            except:
                self.close()
            dic = simplejson.loads(ddd)
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
            # print self.client_address,": \n",data,"\n"
            self.request.sendall(simplejson.dumps(sendData)+'\n')
            lock.release()
           
tcpServ = SocketServer.ThreadingTCPServer(ADDR, MyRequestHandler) 
print 'waiting for connection...' 
while True:
    try:
        tcpServ.serve_forever(poll_interval=0.5)
    except:
        continue