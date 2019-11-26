from smoothing import dema

# Dema array of tuples (x, y, z) for all 91 joints
demas = [(0.0, 0.0, 0.0)] * 91

# Fill up demas with average of the first few frame
def initialise_dema(frames):
    # For each frame, accumulate each joint
    for frame in frames:
        joints = frame['joints']
        length = len(joints)

        # For each joint add the current positions to the accumulator
        for i in range(1, length):
            pos = joints[i]['position']
            acc = demas[i]
            # Tuple are immutable
            demas[i] = (acc[0] + pos[0], acc[1] + pos[1], acc[2] + pos[2])

    # Average each joint
    size = len(frames)
    for i in range(91):
        for j in range(3):
            acc = demas[i]
            demas[i] = (acc[0] / size, acc[1] / size, acc[2] / size)

# Return joint xyz and lines between joint and parent
def get_joint_data(skeleton, i):
    joints = skeleton['joints']

    # Get current joint and parent index
    joint = joints[i]
    parent_index = joint['parentIndex']

    # Get current and previously smoothed joint position
    child_coords = joint['position']
    prev_child_coords = demas[i]

    # Calculate current smoothed values
    smoothed_x = dema(child_coords[0], prev_child_coords[0])
    smoothed_y = dema(child_coords[1], prev_child_coords[1])
    smoothed_z = dema(child_coords[2], prev_child_coords[2])
    smoothed_child_coords = (smoothed_x, smoothed_y, smoothed_z)

    # Update demas with new smoothed values
    demas[i] = smoothed_child_coords
    # Parent is already smoothed from previous iteration
    smoothed_parent_coords = demas[parent_index]

    # Lines between child and parent
    xs = [smoothed_child_coords[0], smoothed_parent_coords[0]]
    ys = [smoothed_child_coords[1], smoothed_parent_coords[1]]
    zs = [smoothed_child_coords[2], smoothed_parent_coords[2]]

    return smoothed_child_coords, xs, ys, zs
