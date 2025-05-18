
import numpy as np


def calculate_statistics(data):
    # Example: Calculate mean and standard deviation of heart rate
    heart_rates = [entry.heart_rate for entry in data if entry.heart_rate is not None]
    mean_hr = np.mean(heart_rates)
    std_hr = np.std(heart_rates)
    return mean_hr, std_hr
