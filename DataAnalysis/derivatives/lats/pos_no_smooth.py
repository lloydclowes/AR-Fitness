import json
import matplotlib.pyplot as plt
from skeleton_processing import get_joint_data, initialise_dema

#### Graphing ####

fig = plt.figure(figsize=(15, 15))
ax = fig.add_subplot(111)
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_xlim([-1, 1])
ax.set_ylim([-1, 1])

#### End of Graphing ####

def clear_plot():
    for point in ax.collections:
        point.remove()
    for line in ax.get_lines():
        line.remove()

def plot_left_hand(frame):
    (x, y, _) = frame['joints'][28]['position']
    plt.scatter(x, y)

def plot_data(frames):
    i = 0
    length = len(frames)

    while True:
        frame = frames[i]
        plot_left_hand(frame)

        plt.pause(0.1)
        i = (i + 1) % length

        #clear_plot()

with open('../../json/lateral-raises-1.json') as json_file:
    data = json.load(json_file)
    frames = data['skeletons']

    # Average the first few frames to initialise the dema array
    initialise_dema(frames[0:3])

    # Non-blocking plot (can exit program)
    plt.show(block=False)

    # Animate the data and smooth it
    plot_data(frames[3:])
