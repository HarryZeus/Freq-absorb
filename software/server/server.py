import socket
import struct
import _thread
import time

from config import *

CLIENT_IP = "192.168.3.11"
SERVER_IP = "192.168.3.9"
PORT = 8888
path_kv = "kv.txt"

f = open(path_kv, "r")
lines = f.readlines()
f.close()

kv = {}
for i in range(2, 3002, 3):
    line = lines[i].split()
    key_header = line[0]
    key_body = line[1:]
    val = lines[i + 1].split()
    
    key_header = int(key_header)
    for i in range(len(key_body)):
        key_body[i] = int(key_body[i], 16)
    for i in range(len(val)):
        val[i] = int(val[i], 16)
    
    key_field = b""
    key_field += struct.pack(">I", key_header)
    for i in range(len(key_body)):
        key_field += struct.pack("B", key_body[i])
    
    val_field = b""
    for i in range(len(val)):
        val_field += struct.pack("B", val[i])
    
    kv[key_header] = (key_field, val_field)
# f.close()

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
    op_field = bytes([packet[0]])
    print("op_field:", op_field)
    key_field = packet[1:]
    
    op = struct.unpack("B", op_field)[0]
    key_header = struct.unpack(">I", key_field[:4])[0]
    
    if (op == READ_REQUEST):
        op = READ_REPLY
        op_field = struct.pack("B", op)
        key_field, val_field = kv[key_header]
        pkt = op_field + key_field + val_field
        s.sendto(pkt, (CLIENT_IP, PORT))
        counter = counter + 1
    elif (op == WRITE_REQUEST or op == STASH_SYN):
        op = WRITE_REPLY
        op_field = struct.pack("B", op)
        seq_body = packet[2:5]
        seq_field = b""
        for byte in seq_body:
            seq_field += struct.pack("B", byte)
        val_field = b"OK"
        pkt = op_field + seq_field + val_field
        # key_field, val_field = kv[key_header]
        # packet = op_field + key_field + val_field
        s.sendto(pkt, (CLIENT_IP, PORT))
    
    #f.write(str(op) + ' ')
    #f.write(str(key_header) + '\n')
    #f.flush()
    #print counter
#f.close()