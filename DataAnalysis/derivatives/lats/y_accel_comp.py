import json
import matplotlib.pyplot as plt
from skeleton_processing import get_joint_data, initialise_dema
import matplotlib.patches as mpatches

#### Graphing ####

fig = plt.figure(figsize=(15, 15))
plt.xlabel("time")
plt.ylabel("acceleration")

#### End of Graphing ####

def get_left_hand_y_smooth(frame):
    (_, y, _), _, _, _ = get_joint_data(frame, 28)
    return y

def get_left_hand_y_no_smooth(frame):
    (_, y, _) = frame['joints'][28]['position']
    return y

def plot_data(frames):
    i = 0
    length = len(frames)
    time = prev_smooth = prev_smooth_vel = prev_smooth_acc = prev_no_smooth = prev_no_smooth_vel = prev_no_smooth_acc = 0
    while True:
        frame = frames[i]
        y_smooth = get_left_hand_y_smooth(frame)
        smooth_vel = (y_smooth - prev_smooth) / 0.01
        smooth_acc = (smooth_vel - prev_smooth_vel) / 0.01
        y_no_smooth = get_left_hand_y_smooth(frame)
        no_smooth_vel = (y_no_smooth - prev_no_smooth) / 0.01
        no_smooth_acc = (no_smooth_vel - prev_no_smooth_vel) / 0.01

        plt.plot([time - 0.01, time], [prev_no_smooth_acc, no_smooth_acc], '-r')
        prev_no_smooth = y_no_smooth
        prev_no_smooth_vel = no_smooth_vel
        prev_no_smooth_acc = no_smooth_acc

        plt.plot([time - 0.01, time], [prev_smooth_acc, smooth_acc], '-b')
        prev_smooth = y_smooth
        prev_smooth_vel = smooth_vel
        prev_smooth_acc = smooth_acc

        plt.pause(0.1)

        i = (i + 1) % length
        time += 0.01

with open('../../json/lateral-raises-1.json') as json_file:
    data = json.load(json_file)
    frames = data['skeletons']

    # Average the first few frames to initialise the dema array
    initialise_dema(frames[0:3])

    # Set up legend
    red_patch = mpatches.Patch(color='red', label='no_smooth')
    blue_patch = mpatches.Patch(color='blue', label='smooth')
    plt.legend(loc='top left', handles=[red_patch, blue_patch])

    # Non-blocking plot (can exit program)
    plt.show(block=False)

    # Animate the data and smooth it
    plot_data(frames[3:])
