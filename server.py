# #!/usr/bin/env python 
# import SocketServer 
# from time import ctime 
# import simplejson
# import threading

# lock = threading.Lock()

# player = {}
# foods = {}
# data = {}

# HOST = '127.0.0.1' 
# PORT = 8080 
# ADDR = (HOST, PORT) 

# class MyRequestHandler(SocketServer.BaseRequestHandler): 
#    def handle(self): 
#        # print '...connected from:', self.client_address
#        while True: 
#             lock.acquire()
#             print self.client_address
#             try:
#                 ddd = self.request.recv(10240)
#             except:
#                 self.close()
#             dic = simplejson.loads(ddd)
#             data[dic["name"]] = {"snakePos":dic["mySnakePos"],"color":dic["color"],"live":dic["live"]}
#             sendData = {}
#             sendData["map"] = 1

#             if dic.get("type") == "ctor":
#                 player[dic["name"]] = ''
#                 print "player num: ",len(player)
#                 if len(player) == 1:
#                     print "has no food"
#                     sendData["food"] = 0
#                 # else:
#                 #     print "get food"
#                 #     sendData["food"] = foods
#             else:
#                 if dic["food"] != 0:
#                     foods = dic["food"]
#             sendData["data"] = data
#             # print self.client_address,": \n",data,"\n"
#             self.request.sendall(simplejson.dumps(sendData)+'\n')
#             lock.release()
           
# tcpServ = SocketServer.ThreadingTCPServer(ADDR, MyRequestHandler) 
# print 'waiting for connection...' 
# while True:
#     try:
#         tcpServ.serve_forever(poll_interval=0.5)
#     except:
#         continue


#!/usr/bin/env python    
#encoding: utf-8  
import simplejson
import socket, threading  
from time import ctime  

lock = threading.Lock()

player = {}
foods = {}
data = {}
    
SERVER = '139.129.59.141'
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
            lock.acquire()
            print self.address
            try:
                d = self.socket.recv(10240)
            except:
                lock.release()
                break
            dic = simplejson.loads(d)
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
            self.socket.send(simplejson.dumps(sendData)+'\n')
            lock.release()
        del data[self.address[0]+str(self.address[1])]
        del player[self.address[0]+str(self.address[1])]
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