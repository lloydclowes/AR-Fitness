import json
import matplotlib.pyplot as plt
from skeleton_processing import get_joint_data, initialise_dema
from scipy.signal import find_peaks
import matplotlib.patches as mpatches

# TODO: Change to use degrees (just need json format change)
# TODO: Don't store all peaks, if we have one just increment

#### Graphing ####

fig = plt.figure(figsize=(15, 15))
plt.xlabel("time")
plt.ylabel("y-pos")

#### End of Graphing ####

def get_left_hand_y(frame):
    (_, y, _), _, _, _ = get_joint_data(frame, 28)
    return y

def plot_data(frames):
    i = 0
    length = len(frames)
    time = prev = 0
    points = []
    anot = plt.annotate("Rep count: 0", xy=(0, 0), xytext=(0, 35), xycoords=('axes fraction', 'figure fraction'),
                     textcoords='offset points', size=25, ha='center', va='bottom')
    while True:
        frame = frames[i]
        curr = get_left_hand_y(frame)
        points.append(curr)

        plt.plot([time - 0.01, time], [prev, curr], '-b')
        prev = curr

        # Find and plot peaks
        peaks = find_peaks(points, height=(0.6, 1))  # returns indices of the peaks (is 2D)
        peak_vals = [points[i] for i in peaks[0]]
        peak_times = [0.01 * index for index in peaks[0]]
        plt.scatter(peak_times, peak_vals, c='red', marker='x', s=500)

        # Negate points to find troughs
        negative_points = [-x for x in points]
        troughs = find_peaks(negative_points, distance=20)
        trough_vals = [points[i] for i in troughs[0]]
        trough_times = [0.01 * index for index in troughs[0]]
        plt.scatter(trough_times, trough_vals, c='green', marker='x', s=500)

        reps = min((len(troughs[0]) + len(peaks[0])) // 2, len(peaks[0] * 2))

        anot.remove()
        anot = plt.annotate("Rep count:" + str(reps), xy=(0, 0), xytext=(0, 35),
                            xycoords=('axes fraction', 'figure fraction'),
                            textcoords='offset points', size=25, ha='center', va='bottom')

        plt.pause(0.1)

        i = (i + 1) % length
        time += 0.01

with open('../../json/lateral-raises-1.json') as json_file:
    data = json.load(json_file)
    frames = data['skeletons']

    # Average the first few frames to initialise the dema array
    initialise_dema(frames[0:3])

    # Set up legend
    red_patch = mpatches.Patch(color='red', label='peaks')
    blue_patch = mpatches.Patch(color='green', label='troughs')
    plt.legend(loc='top left', prop={'size': 20}, handles=[red_patch, blue_patch])

    # Non-blocking plot (can exit program)
    plt.show(block=False)

    # Animate the data and smooth it
    plot_data(frames[3:])
