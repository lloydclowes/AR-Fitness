import asyncio
import matplotlib.pyplot as plt
import mpl_toolkits.mplot3d.axes3d as p3
import matplotlib.animation as animation


def get_skeleton_coords(skeleton):
    coords = []
    for joint in skeleton['joints']:
        parentIndex = joint['parentIndex']

        if parentIndex == -1:
            continue

        parent = skeleton['joints'][parentIndex]

        xs = [joint['position'][0], parent['position'][0]]
        ys = [joint['position'][1], parent['position'][1]]
        zs = [joint['position'][2], parent['position'][2]]
        coords.append((xs, ys, zs))

    return coords


def call_back(i, drawer, pipe):
    print("callback")
    while pipe.poll():
        print("pipe")
        data = pipe.recv()
        print(data)
        return drawer.update_skeleton(data)

    return []


class Drawer:

    def __init__(self):
        self.lines = []
        self.fig = plt.figure()
        self.ax = p3.Axes3D(self.fig)
        self.newest_skeleton = ()
        plt.ion()
        plt.show()

    def update_skeleton(self, skeleton):
        self.newest_skeleton = skeleton
        return self.update_animation()

    def draw_lines(self, skeleton):
        lines = []

        for (xs, ys, zs) in get_skeleton_coords(skeleton):
            lines.append(self.ax.plot(xs, ys, zs, color='b')[0])

        return lines

    def update_animation(self):
        if len(self.lines) == 0:
            self.lines = self.draw_lines(self.newest_skeleton)
            return self.lines

        coords = get_skeleton_coords(self.newest_skeleton)
        for i in range(len(coords)):
            (xs, ys, zs) = coords[i]
            self.lines[i].set_data_3d(xs, ys, zs)

        plt.pause(0.001)
        return self.lines
