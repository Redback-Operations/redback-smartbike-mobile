import matplotlib.pyplot as plt

# see before send to flutter

def plot_histogram(data):
    # Example: Plot a histogram of heart rates
    heart_rates = [entry.heart_rate for entry in data if entry.heart_rate is not None]
    plt.hist(heart_rates, bins=20, color='skyblue', edgecolor='black')
    plt.xlabel('Heart Rate')
    plt.ylabel('Frequency')
    plt.title('Histogram of Heart Rates')
    plt.show()
