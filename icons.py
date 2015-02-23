import Image
import os

im = Image.open("icon.png")

sizes = [
    29, 29*2, 29*3,
        40*2, 40*3,
    57, 57*2,
        60*2, 60*3,
    29, 29*2,
    40, 40*2,
    50, 50*2,
    72, 72*2,
    76, 76*2,
    120
]

for i, size in enumerate(sizes):
    f, e = os.path.splitext("icon.png")
    outfilename = f + str(size) + "-" + str(i) + ".png"
    try:
        out = im.resize((size, size), Image.ANTIALIAS)
        out.save(outfilename)
    except IOError:
        print "error"