import random

path_query = "query_uni_0.7.txt"
num_query = 1000000
#Read ratio = 1 - write ratio
ratio = 0.7   

len_key = 16
len_val = 128
max_key = 10000

seq = 0

f = open(path_query, "w")
print("open file success!")
for i in range(num_query):
    #Randomly select a key
    key_header = random.randint(1, max_key)
    key_body = [0] * (len_key - 4)
    
    #Save the generated query to the file
    n = random.randint(1, 100)
    if(n <= ratio*100):
        f.write("get ")
    else:
        f.write("write ")
        f.write(str(seq) + ' ')
        seq = (seq + 1)%1024
    f.write(str(key_header) + ' ')
    for i in range(len(key_body)):
        f.write(hex(key_body[i]) + ' ')
    f.write('\n')
f.flush()
f.close()
