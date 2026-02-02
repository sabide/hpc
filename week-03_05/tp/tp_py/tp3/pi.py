import math

# Interval number
nbblock = 3 * 1000 * 1000 * 100
# Interval width
width = 1.0 / nbblock

# Compute global_sum
for i in range(1, nbblock+1):
    x = width * (i - 0.5)
    global_sum += width * (4.0 / (1.0 + x * x))

print(f"Pi = {global_sum}")
print(f"Difference = {global_sum - 4.0 * math.atan(1.0)}")
