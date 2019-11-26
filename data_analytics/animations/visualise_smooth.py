import json
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from skeleton_processing import get_joint_data, initialise_dema

#### Graphing ####

fig = plt.figure(figsize=(15, 15))
ax = Axes3D(fig)
ax.set_xlim3d([-1, 1])
ax.set_ylim3d([-1, 1])
ax.set_zlim3d([-1, 1])
ax.view_init(90, 270)

#### End of Graphing ####

def clear_plot():
    for point in ax.collections:
        point.remove()
    for line in ax.get_lines():
        line.remove()

def plot_skeleton(frame):
    # Number of joints to plot
    length = len(frame['joints'])

    for i in range(1, length):
        child_coords, xs, ys, zs = get_joint_data(frame, i)

        # Plot point and line to parent
        #ax.scatter3D(child_coords[0], child_coords[1], child_coords[2])
        ax.plot3D(xs, ys, zs, color='b')

def plot_data(frames):
    i = 0
    length = len(frames)

    while True:
        frame = frames[i]
        plot_skeleton(frame)

        plt.pause(0.01)
        i = (i + 1) % length

        clear_plot()

with open('../json/lateral-raises-1.json') as json_file:
    data = json.load(json_file)
    frames = data['skeletons']

    # Average the first few frames to initialise the dema array
    initialise_dema(frames[0:3])

    # Animate the data and smooth it
    plot_data(frames[3:])
