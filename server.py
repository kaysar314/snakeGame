# #-*- coding: utf-8 -*-
# from socket import *
# from time import ctime

# HOST='127.0.0.1'
# PORT=8080
# BUFSIZ=1024
# ADDR=(HOST, PORT)
# sock=socket(AF_INET, SOCK_STREAM)

# sock.bind(ADDR)

# sock.listen(5)
# while True:
#     print 'waiting for connection'
#     tcpClientSock, addr=sock.accept()
#     print 'connect from ', addr
#     while True:
#         try:
#             data=tcpClientSock.recv(BUFSIZ)
#         except Exception , e:
#             print e
#             tcpClientSock.close()
#             break
#         if not data:
#             break
#         tcpClientSock.send(data)
#         print [ctime()], ':', data
# tcpClientSock.close()
# sock.close()

#!/usr/bin/env python 
import SocketServer 
from time import ctime 
HOST = '127.0.0.1' 
PORT = 8080 
ADDR = (HOST, PORT) 

class MyRequestHandler(SocketServer.BaseRequestHandler): 
   def handle(self): 
       print '...connected from:', self.client_address 
       while True: 
           self.request.sendall(self.request.recv(1024)) 
           
tcpServ = SocketServer.ThreadingTCPServer(ADDR, MyRequestHandler) 
print 'waiting for connection...' 
tcpServ.serve_forever()