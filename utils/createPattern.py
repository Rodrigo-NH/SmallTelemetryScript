# Generate bitmap representation of a given BMP image to be used in lua script
# BMP must be white background with black pixels (or < 128,128,128 RGB)
import os, io
from PIL import Image

def main():
    filelocal = os.path.join(r'D:\share\bitmaps\example.bmp')
    im = Image.open(filelocal)
    pp = list(im.getdata())
    psize = im.size

    ctr = 0
    output = []    
    for x in range(0, psize[1]):
        # line = []
        print("Line: " + str(x))
        column = []
        for y in range (0, psize[0]):            
            pxval = 1
            if pp[ctr][1] > 128:
                pxval = 0
            column.append(pxval)
            ctr += 1
            print("Column: " + str(y))
        output.append(column)
        
    pattern = "pattern = { \n"    
    for line in output:
        pattern = pattern + "\t{ "
        for pixel in line:
            pattern = pattern + str(pixel) + ", "
        pattern = pattern + " },\n"
    pattern = pattern + " }"    
    print(pattern) 


if __name__ == "__main__":
    main()
