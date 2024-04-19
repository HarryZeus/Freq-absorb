import socket
import struct
import _thread
import time

from config import *

CLIENT_IP = "192.168.3.11"
SERVER_IP = "192.168.3.9"
PORT = 8888

counter = 0
def counting():
    last_counter = 0
    while True:
        print (counter - last_counter), counter
        last_counter = counter
        time.sleep(1)
_thread.start_new_thread(counting, ())

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind((SERVER_IP, PORT))

while True:
    packet, addr = s.recvfrom(2048)
    pkt = b"OK"
    s.sendto(pkt,(CLIENT_IP,PORT))
    counter = counter + 1