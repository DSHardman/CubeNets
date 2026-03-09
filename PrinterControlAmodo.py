import numpy as np
import random
import time
import serial
from datetime import datetime


from scipy.io import loadmat
import time
import amodo_eit as eit
from utils import print_info, print_warning, print_error

STIM_FREQ_KHZ = 1
PERIODS_PER_MEASUREMENT = 1
TX_GAIN = 16  # 50k 16 32, 10k & 5k 8 8, 1k 16 16, 2k 8 16
RX_GAIN = 16

configs = loadmat("Cube24Combos.mat")
configs = configs["configs"]

devices = eit.get_connected_devices()
if not devices:
    print_error("No Amodo EIT devices connected.")
    exit()
device = devices[0]
if len(devices) > 1:
    print_warning("Multiple Amodo EIT devices detected.")

from vispy import app, scene

# Cornerposition = (61, 23, 0)
Cornerposition = (0, 0, 0)  # This needs updating before running
retractheight = 5
waittime = 5
savestring = "Data/fitz"

Ender = serial.Serial("COM12", 115200)
time.sleep(2)

print_info(f"Using device: {device.port}, version {device.version}, build {device.build_date_time}")

def waitforposition():
    Ender.flush()
    Ender.write(str.encode("M114 R\r\n"))
    while True:
        line = Ender.readline()
        if line.find(b'Count') != -1:
            break
    return


def takereading(depth):
    Ender.write(str.encode("G1 Z" + str(Cornerposition[2]) + " F3000\r\n"))
    waitforposition()
    empty_frame, clipping = device.latest_frame

    Ender.write(str.encode("G1 Z" + str(Cornerposition[2] - depth) + " F3000\r\n"))
    waitforposition()

    time.sleep(waittime)

    current_frame, clipping = device.latest_frame
    Ender.write(str.encode("G1 Z" + str(Cornerposition[2] + retractheight) + " F3000\r\n"))
    waitforposition()

    return empty_frame, current_frame


def setup():
    # Ender.write(str.encode("G28\r\n")) // We start under the assumption that printer has been homed & set to height
    Ender.write(str.encode("G92 X0 Y0 Z0\r\n"))
    Ender.write(str.encode("G1 Z"+str(Cornerposition[2]+retractheight)+" F400\r\n"))
    Ender.write(str.encode("G1 X "+str(Cornerposition[0])+" Y "+str(Cornerposition[1])+" F1000\r\n"))
    waitforposition()

    # device.reset()
    device.set_stimulation_frequency(STIM_FREQ_KHZ)

    # Send electrode configuration
    print_info("Loading electrode configuration...")
    electrode_configurations = []
    # pin_mapping = [4, 3, 5, 9, 6, 10, 7, 11, 8, 12, 17, 19, 18, 23, 22, 24, 1, 15, 2, 16, 13, 20, 14, 21]
    # pin_mapping = [7, 5, 9, 17, 11, 19, 13, 21, 15, 23, 41, 45, 43, 53, 51, 55, 1, 37, 3, 39, 33, 47, 35, 49]
    # pin_mapping = [8, 6, 10, 18, 12, 20, 14, 22, 16, 24, 42, 46, 44, 54, 52, 56, 2, 38, 4, 40, 34, 48, 36, 50]
    pin_mapping = [52, 50, 40, 48, 38, 46, 36, 44, 34, 42, 12, 16, 4, 14, 2, 6, 22, 8, 24, 10, 54, 18, 56, 20]

    for i in range(len(configs)):
        configuration = (pin_mapping[configs[i][0]], pin_mapping[configs[i][1]], pin_mapping[configs[i][2]],
                         pin_mapping[configs[i][3]], TX_GAIN, RX_GAIN)
        electrode_configurations.append(configuration)
        print(
            f"{configuration[0]} {configuration[1]} {configuration[2]} {configuration[3]} {configuration[4]} {configuration[5]}")

    device.set_electrode_configurations(electrode_configurations)
    print_info(f"Electrode configuration loaded ({len(electrode_configurations)} configurations).\n")

    device.set_num_periods_to_sample_per_measurement(20)
    device.set_num_periods_to_sample_per_measurement(PERIODS_PER_MEASUREMENT)

    device.start_streaming()
    time.sleep(0.5)


def main():
    # Random probing at 3 mm
    depth = 3  # In mm
    for i in range(3000):
        print(i)

        # Keep selecting random coordinates until these are located within net
        while 1:
            x = 120*random.random()
            y = 90*random.random() - 30
            if 0 <= y <= 30:
                break
            elif 30 <= x <= 60:
                break

        Ender.write(str.encode("G1 X "+str(Cornerposition[0]+x)+" Y "+str(Cornerposition[1]+y)+" F3000\r\n"))
        waitforposition()
        outdata = takereading(depth)
        with open(savestring + '.txt', 'a') as file:
            file.write('%s, %s, %s, %s\n' % (str(x), str(y), str(outdata[0]), str(outdata[1])))
        np.savetxt(savestring+str(i)+"EMPTY.txt", outdata[0], delimiter=",")
        np.savetxt(savestring + str(i) + ".txt", outdata[1], delimiter=",")


        time.sleep(waittime)


with device:
    setup()
    main()
