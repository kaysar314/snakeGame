#!/usr/bin/env python    
#encoding: utf-8  
import simplejson
import socket, threading  
from time import ctime  

lock = threading.Lock()

player = {}
foods = {}
data = {}

addNew = ["false"]
    
SERVER = '127.0.0.1'
PORT = 6666
MAXTHREADS = 20
RECVBUFLEN = 10240
  
class ComunicateServer(threading.Thread):
    def __init__(self, clientsocket, address, num):
        threading.Thread.__init__(self)
        self.socket = clientsocket
        self.num = num
        self.address = address
        print 'New thread [%d] started!' % self.num

    def run(self):
        while True:
            try:
                d = self.socket.recv(10240)
            except:
                break
            dic = simplejson.loads(d)
            sendData = {}
            sendData["map"] = 1

            if dic.get("type") == "ctor":
                data[dic["name"]] = {"snakePos":dic["mySnakePos"],"color":dic["color"],"myShadows":dic["myShadows"],"mySnakeFir":dic["mySnakeFir"]}
                player[dic["name"]] = ''
                print "player num: ",len(player)
                if len(player) == 1:
                    print "has no food"
                    sendData["food"] = 0
                addNew[0] = "true"
                for an in player:
                    if an != dic["name"]:
                        addNew.append(an)
                # else:
                #     print "get food"
                #     sendData["food"] = foods
            elif dic.get("type") == "loop":
                data[dic["name"]] = {"myShadows":dic["myShadows"],"live":dic["live"]}
                if dic.get("headtime"):
                    data[dic["name"]] = {"myShadows":dic["myShadows"],"live":dic["live"],"headtime":dic["headtime"]}
                if dic.get("snakePos") != None :
                    if dic.get("live"):
                        data[dic["name"]] = {"color":dic["color"],"snakePos":dic["snakePos"],"myShadows":dic["myShadows"],"mySnakeFir":dic["mySnakeFir"],"live":dic["live"]}
                    else:
                        data[dic["name"]] = {"snakePos":dic["snakePos"],"myShadows":dic["myShadows"],"live":dic["live"]}
                if dic["food"] != 0:
                    foods = dic["food"]
                if dic.get("addNew") != None :
                    addNew[0] = "true"
                    for an in dic["addNew"]:
                        if an != dic["name"]:
                            addNew.append(an)
            if addNew[0] == "true" and dic["name"] in addNew:
                addNew.remove(dic["name"])
                sendData["type"] = "addNew"
            sendData["data"] = data
            # print self.client_address,": \n",data,"\n"
            self.socket.send(simplejson.dumps(sendData)+'\n')
        del data[str(self.address[1])]
        del player[str(self.address[1])]
        self.socket.close()  

class ListenServer(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.socket = None
        print 'Start Listen....'

    def run(self):  
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  
        self.socket.bind((SERVER,PORT))  
        self.socket.listen(2)  
        num = 1  
        while True:  
            cs,address = self.socket.accept()  
            comser = ComunicateServer(cs, address, num)  
            comser.start()  
            num += 1
            print 'Listen Next...'  
        self.socket.close()  
  
if __name__ == '__main__':  
    asvr = ListenServer()  
    asvr.start()  
    asvr.join() 