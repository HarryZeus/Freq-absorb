import socket
import struct
import _thread
import time

CLIENT_IP = "192.168.3.11"
SERVER_IP = "192.168.3.9"
PORT = 8888
path_reply = "reply.txt"

counter = 0
def counting():
    last_counter = 0
    while True:
        print (counter - last_counter), counter
        last_counter = counter
        time.sleep(1)
_thread.start_new_thread(counting, ())

r = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
r.bind((CLIENT_IP, PORT))

#f = open(path_reply, "w")
while True:
    packet, addr = r.recvfrom(1024)
    counter = counter + 1
    #op = struct.unpack("B", packet[0])
    #key_header = struct.unpack(">I", packet[1:5])[0]
    #f.write(str(op) + ' ')
    #f.write(str(key_header) + '\n')
    #f.flush()
    #print counter
#f.close()    