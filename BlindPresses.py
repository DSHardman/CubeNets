import numpy as np
import random
import time
import serial
from datetime import datetime

# Cornerposition = (61, 23, 0)
Cornerposition = (0, 0, 0)  # This needs updating before running
retractheight = 15
waittime = 8

Ender = serial.Serial("COM12", 115200)
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

    for i in range(9):
        Ender.write(str.encode("G1 X0 Y0 Z" + str(3*retractheight) + " F400\r\n"))
        waitforposition()
        time.sleep(15)

        Ender.write(str.encode("G1 X0 Y0 F800\r\n"))
        waitforposition()
        takereading(depth)

        Ender.write(str.encode("G1 X10 Y0 F800\r\n"))
        waitforposition()
        takereading(depth)

        Ender.write(str.encode("G1 X10 Y10 F800\r\n"))
        waitforposition()
        takereading(depth)

        Ender.write(str.encode("G1 X0 Y10 F800\r\n"))
        waitforposition()
        takereading(depth)

        Ender.write(str.encode("G1 X-10 Y10 F800\r\n"))
        waitforposition()
        takereading(depth)

        Ender.write(str.encode("G1 X-10 Y0 F800\r\n"))
        waitforposition()
        takereading(depth)

        Ender.write(str.encode("G1 X-10 Y-10 F800\r\n"))
        waitforposition()
        takereading(depth)

        Ender.write(str.encode("G1 X0 Y-10 F800\r\n"))
        waitforposition()
        takereading(depth)

        Ender.write(str.encode("G1 X10 Y-10 F800\r\n"))
        waitforposition()
        takereading(depth)

        # Ender.write(str.encode("G1 X0 Y0 Z0 F800\r\n"))

setup()
main()
