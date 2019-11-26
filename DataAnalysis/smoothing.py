# EMA weighting, can change -> larger is more responsive to change
# Between 0 -> 1
alpha = 0.25

# ARKit 3
def ema(actual, ema_prev):
    return actual * alpha + ema_prev * (1.0 - alpha)

def dema(actual, prev):
    smoothed = ema(actual, prev)
    double_smoothed = ema(smoothed, prev)
    return 2 * smoothed - double_smoothed