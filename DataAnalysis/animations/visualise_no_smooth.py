import json
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.animation as animation

fig = plt.figure(figsize=(15, 15))
ax = Axes3D(fig)
ax.set_xlim3d([-1, 1])
ax.set_ylim3d([-1, 1])
ax.set_zlim3d([-1, 1])
ax.view_init(90, 270)

def get_skeleton_lines(skeleton):
    lines = []
    for i in range(1, len(skeleton['joints'])):
        joint = skeleton['joints'][i]
        parent_index = joint['parentIndex']
        parent = skeleton['joints'][parent_index]

        xs = [joint['position'][0], parent['position'][0]]
        ys = [joint['position'][1], parent['position'][1]]
        zs = [joint['position'][2], parent['position'][2]]

        lines.append([xs, ys, zs])
    return lines

def get_initial_plot(skeleton):
    lines = []

    for line_coords in get_skeleton_lines(skeleton):
        line = ax.plot3D(line_coords[0], line_coords[1], line_coords[2], color='b')[0]
        lines.append(line)

    return lines

def update_lines(frame, lines, frames):
    skeleton = frames[frame]
    newLines = get_skeleton_lines(skeleton)
    for i in range(0, len(lines)):
        lines[i].set_xdata(newLines[i][0])
        lines[i].set_ydata(newLines[i][1])
        lines[i].set_3d_properties(newLines[i][2])
    return lines

with open('../json/lateral-raises-1.json') as json_file:
    data = json.load(json_file)
    frames = data['skeletons']
    frames_len = len(frames)
    lines = get_initial_plot(frames[0])
    ani = animation.FuncAnimation(fig, update_lines, frames_len, fargs=(lines, frames), interval=100, blit=False)
    plt.show()

