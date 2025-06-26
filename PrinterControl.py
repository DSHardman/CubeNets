import numpy as np
import random
import time
import serial
from datetime import datetime

# Cornerposition = (61, 23, 0)
Cornerposition = (0, 0, 0)  # This needs updating before running
retractheight = 15
waittime = 8
savestring = "Data/fitz"

Ender = serial.Serial("COM5", 115200)
time.sleep(2)


def waitforposition():
    Ender.flush()
    Ender.write(str.encode("M114 R\r\n"))
    while True:
        line = Ender.readline()
        if line.find(b'Count') != -1:
            break
    return


def takereading(depth):
    starttime = datetime.now()
    Ender.write(str.encode("G1 Z" + str(Cornerposition[2]) + " F400\r\n"))
    waitforposition()

    Ender.write(str.encode("G1 Z" + str(Cornerposition[2] - depth) + " F400\r\n"))
    waitforposition()

    midtime = datetime.now()
    time.sleep(waittime)

    Ender.write(str.encode("G1 Z" + str(Cornerposition[2] + retractheight) + " F400\r\n"))
    waitforposition()

    endtime = datetime.now()
    return starttime, midtime, endtime


def setup():
    # Ender.write(str.encode("G28\r\n")) // We start under the assumption that printer has been homed & set to height
    Ender.write(str.encode("G92 X0 Y0 Z0\r\n"))
    Ender.write(str.encode("G1 Z"+str(Cornerposition[2]+retractheight)+" F400\r\n"))
    Ender.write(str.encode("G1 X "+str(Cornerposition[0])+" Y "+str(Cornerposition[1])+" F1000\r\n"))
    waitforposition()


def main():
    # Random probing at 3 mm
    depth = 3  # In mm
    for i in range(1000):
        print(i)

        # Keep selecting random coordinates until these are located within net
        while 1:
            x = 115*random.random()
            y = 85*random.random() - 27.5
            if 0 <= y <= 27.5:
                break
            elif 27.5 <= x <= 57.5:
                break

        # x = 69
        # y = 0
        Ender.write(str.encode("G1 X "+str(Cornerposition[0]+x)+" Y "+str(Cornerposition[1]+y)+" F800\r\n"))
        waitforposition()
        times = takereading(depth)
        with open(savestring+'.txt', 'a') as file:
            file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
        time.sleep(waittime)

setup()
main()