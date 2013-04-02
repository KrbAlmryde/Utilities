# There are just R values

def rgbToHex(R,G,B):
    return toHex(R),toHex(G),toHex(B)

def toHex(n):
    if n == 0:
        return 00
    n = max(0,min(n,255))
    return "0123456789ABCDEF"[(n-n%16)/16], "0123456789ABCDEF"[n%16]


print rgbToHex(255, 255, 0)
print rgbToHex(255, 0, 0)
print rgbToHex(0, 0, 255)
print rgbToHex(0, 255, 0)
print rgbToHex(255, 0, 255)
print rgbToHex(255, 127, 0)
print rgbToHex(127, 127, 127)
print rgbToHex(127, 255, 0)
print rgbToHex(255, 127, 127)
print rgbToHex(127, 0, 127)
print rgbToHex(127, 127, 0)
print rgbToHex(255, 0, 127)
print rgbToHex(0, 127, 127)
print rgbToHex(127, 0, 255)
print rgbToHex(127, 127, 127)
print rgbToHex(170, 85, 85)
print rgbToHex(170, 170, 0)
print rgbToHex(255, 85, 85)
print rgbToHex(85, 170, 85)
print rgbToHex(170, 85, 170)
print rgbToHex(170, 170, 85)
print rgbToHex(85, 85, 85)
print rgbToHex(170, 0, 170)
print rgbToHex(170, 85, 85)
print rgbToHex(85, 85, 170)
print rgbToHex(127, 127, 63)
print rgbToHex(191, 63, 127)
print rgbToHex(191, 127, 63)
print rgbToHex(127, 127, 127)
print rgbToHex(127, 63, 127)
print rgbToHex(153, 102, 102)



