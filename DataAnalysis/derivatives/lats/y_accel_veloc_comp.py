import json
import matplotlib.pyplot as plt
from skeleton_processing import get_joint_data, initialise_dema
import matplotlib.patches as mpatches

#### Graphing ####

fig = plt.figure(figsize=(15, 15))
plt.xlabel("time")
plt.ylabel("change")
plt.ylim([-45, 45])

#### End of Graphing ####

def get_left_hand_y(frame):
    (_, y, _), _, _, _ = get_joint_data(frame, 28)
    return y

def plot_data(frames):
    i = 0
    length = len(frames)

    # Using smoothed values
    time = prev_y = prev_vel = prev_acc = 0
    while True:
        frame = frames[i]
        y = get_left_hand_y(frame)
        vel = (y - prev_y) / 0.01
        acc = (vel - prev_vel) / 0.01

        plt.plot([time - 0.01, time], [prev_vel, vel], '-r')
        plt.plot([time - 0.01, time], [prev_acc, acc], '-b')
        prev_y = y
        prev_vel = vel
        prev_acc = acc

        plt.pause(0.1)

        i = (i + 1) % length
        time += 0.01

with open('../../json/lateral-raises-1.json') as json_file:
    data = json.load(json_file)
    frames = data['skeletons']

    # Average the first few frames to initialise the dema array
    initialise_dema(frames[0:3])

    # Set up legend
    red_patch = mpatches.Patch(color='red', label='velocity')
    blue_patch = mpatches.Patch(color='blue', label='acceleration')
    plt.legend(loc='top left', handles=[red_patch, blue_patch])

    # Non-blocking plot (can exit program)
    plt.show(block=False)

    # Animate the data and smooth it
    plot_data(frames[3:])
