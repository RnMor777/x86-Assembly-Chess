f = open('saves/saves.txt')
# print (f.readlines())

count = 0
iteration = 0
out = []
x = f.read()
for i in x[:64]:
    if (iteration%8==0 and iteration!=0):
        if (count > 0):
            out.append(str(count))
        out.append('/')
        count = 0
    if (i == "-"):
        count += 1
    else:
        if (count > 0):
            out.append(str(count))
            count = 0
        if (ord(i)>96):
            out.append(chr(ord(i)-32))
        else:
            out.append(chr(ord(i)+32))
    iteration += 1
    # position, count, iteration
if (ord(x[74])==1):
    out.append(' b ')
else:
    out.append(' w ')

count = 0
if (ord(x[76]) == 1):
    out.append ('K')
    count = 1
if (ord(x[75]) == 1):
    out.append ('Q')
    count = 1
if (ord(x[78]) == 1):
    out.append ('k')
    count = 1
if (ord(x[77]) == 1):
    out.append ('q')
    count = 1
if (count == 0):
    out.append ('-')
out.append (' - 0 0')


print (''.join(out))
