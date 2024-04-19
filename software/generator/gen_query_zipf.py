import random

path_query = "query_zipf_0.7_0.90.txt"
num_query = 1000000
zipf = 0.9
#Read ratio = 1 - write ratio
ratio = 0.7   

len_key = 16
len_val = 128
max_key = 10000

seq = 0

#Zipf
zeta = [0.0]
for i in range(1, max_key + 1):
    zeta.append(zeta[i - 1] + 1 / pow(i, zipf))
field = [0] * (num_query + 1)
k = 1
for i in range(1, num_query + 1):
    if(i > num_query * zeta[k] / zeta[max_key]):
        k = k + 1
    field[i] = k

#Generate queries
f = open(path_query, "w")
for i in range(num_query):
    #Randomly select a key in zipf distribution
    r = random.randint(1, num_query)
    key_header = field[r]
    key_body = [0] * (len_key - 4)
    
    #Save the generated query to the file
    n = random.randint(1, 100)
    if(n <= ratio*100):
        f.write("get ")
    else:
        f.write("write ")
        f.write(str(seq) + ' ')
        seq = (seq + 1)%100000
    f.write(str(key_header) + ' ')
    for i in range(len_key - 4):
        f.write(hex(key_body[i]) + ' ')
    f.write('\n')
f.flush()
f.close()
