f = open('saves/saves.fen')

out = []
pos = 0
x = f.read()
for i in x:
    if (i == ' '):
        break
    if (ord(i) < 58):
        out.append("-"*(ord(i)-48))
    elif (i == '/'):
        continue
    else:
        out.append(i)
    pos += 1

out.append(' ')
out.append(x[pos+1])

print (''.join(out))
