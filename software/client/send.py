import socket
import struct
import _thread
import time

CLIENT_IP = "192.168.3.11"
SERVER_IP = "192.168.3.9"
PORT = 8888
path_query = "query_zipf.txt"
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


f = open(path_query, "r")
interval = 1.0 / (query_rate + 1)
for line in f.readlines():
    line = line.split()
    op = line[0]
    seq = int(line[1])
    key_header = int(line[2])
    key_body = line[3:]

    if op == "get":
        op_field = struct.pack("B", 0) #READ_REQEUST
    else:
        op_field = struct.pack("B", 2) #WRITE_REQEUST
    seq_field = struct.pack(">I", seq)
    key_field = struct.pack(">I", key_header)
    for i in range(len(key_body)):
        key_field += struct.pack("B", int(key_body[i], 16))
    packet = op_field + seq_field + key_field

    s.sendto(packet, (SERVER_IP, PORT))
    counter = counter + 1
    time.sleep(0)

f.close()
