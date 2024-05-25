


from sklearn.linear_model import LinearRegression

def train_regression_model(X, y):
    # Example: Train a linear regression model to predict heart rate based on speed
    model = LinearRegression().fit(X, y)
    return model
