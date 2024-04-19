import socket
import _thread
import time
import struct

CLIENT_IP = "192.168.3.11"
SERVER_IP = "192.168.3.9"
PORT = 8888
hot_kv = "hot.txt"
query_rate = 1000

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

counter = 0
def counting():
    last_counter = 0
    while True:
        print (counter - last_counter), counter
        last_counter = counter
        time.sleep(1)
_thread.start_new_thread(counting, ())


f = open(hot_kv, "r")
interval = 1.0 / (query_rate + 1)
for line in f.readlines():
    line = line.split()
    key_header = int(line[0])
    key_body = line[1:]

    op_field = struct.pack("B", 4)

    key_field = struct.pack(">I", key_header)
    for i in range(len(key_body)):
        key_field += struct.pack("B", int(key_body[i], 16))
        
    packet = op_field + key_field
    s.sendto(packet, (CLIENT_IP, PORT))
    counter = counter + 1
    time.sleep(interval)

f.close()
    