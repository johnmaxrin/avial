import os
import glob
import matplotlib.pyplot as plt

# Path to folder containing data files
folder_path = "outputs"

# Get all .txt files inside the folder
file_paths = glob.glob(os.path.join(folder_path, "*.txt"))

if not file_paths:
    raise FileNotFoundError("No .txt files found in the 'outputs' folder.")

plt.figure()

for file_path in file_paths:
    # Read values from file
    with open(file_path, "r") as f:
        x_values = [float(line.strip()) for line in f if line.strip()]
    
    # Use filename as label
    filename = os.path.basename(file_path)
    plt.plot(x_values, label=filename)

plt.xlabel("Index")
plt.ylabel("x value")
plt.title("Plot of x values from outputs folder")
plt.legend()
plt.grid(True)

plt.tight_layout()
plt.show()