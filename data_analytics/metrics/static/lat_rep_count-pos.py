import json
import matplotlib.pyplot as plt
from skeleton_processing import get_joint_data, initialise_dema
from scipy.signal import find_peaks
import numpy as np

#### Graphing ####

fig = plt.figure(figsize=(15, 15))
plt.xlabel("time")
plt.ylabel("y-pos")

#### End of Graphing ####

def get_left_hand_y_smooth(frame):
    (_, y, _), _, _, _ = get_joint_data(frame, 28)
    return y

def get_left_hand_data(frames):
    points = []

    for frame in frames:
        points.append(get_left_hand_y_smooth(frame))

    return points

def plot_data(frames):
    points = get_left_hand_data(frames)
    times = np.arange(0, len(frames) * 0.01, 0.01)

    plt.plot(times, points)

    # Find and plot peaks
    peaks = find_peaks(points, prominence=0.5) # returns indices of the peaks (is 2D)
    peak_vals = [points[i] for i in peaks[0]]
    peak_times = [0.01 * index for index in peaks[0]]
    plt.scatter(peak_times, peak_vals, c='red', marker='x', s=500, label="peaks")

    # Negate points to find troughs
    negative_points = [-x for x in points]
    troughs = find_peaks(negative_points, distance=10)
    trough_vals = [points[i] for i in troughs[0]]
    trough_times = [0.01 * index for index in troughs[0]]
    plt.scatter(trough_times, trough_vals, c='green', marker='x', s=500, label="troughs")
    # Add final point as trough
    plt.scatter(0.87, points[87], c='green', marker='x', s=500)

    reps = (len(troughs[0]) + len(peaks[0])) // 2

    plt.legend(loc='top left', prop={'size': 20})
    plt.annotate("Rep count:" + str(reps), xy=(0, 0), xytext=(0, 35), xycoords=('axes fraction', 'figure fraction'),
            textcoords='offset points', size=25, ha='center', va='bottom')
    plt.show()

with open('../json/lateral-raises-1.json') as json_file:
    data = json.load(json_file)
    frames = data['skeletons']

    # Average the first few frames to initialise the dema array
    initialise_dema(frames[0:3])

    # Animate the data and smooth it
    plot_data(frames[3:])
