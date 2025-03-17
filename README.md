# GridGuardian Model Documentation

## 🔍 Brief Description

GridGuardian uses a machine learning model to predict household appliance energy consumption. It leverages factors like household size, appliance type, and seasonal variations to provide insights into energy usage patterns. This empowers users to make informed decisions and optimize energy consumption in their smart homes.

## 📊 Source of Data

The dataset used to train the model comes from Kaggle: Smart Home Energy Consumption Dataset. It includes detailed records of energy consumption across various household appliances, making it ideal for building predictive models.

## ⚙️ Data Preprocessing

**Feature Selection:**

Selected relevant features:

**Appliance Type**
**Energy Consumption (kWh)**
**Season**
**Household Size**

**Encoding:**

Applied one-hot encoding to categorical variables such as Appliance Type and Season.
Handling Missing Values:

Checked for missing values and applied imputation if necessary.

**Scaling:**

Standardized numerical features like Household Size and Energy Consumption (kWh) to ensure proper model training.
Data Splitting:

Split the dataset into 80% training and 20% testing data for model evaluation.

## 🤖 Model Training

Several regression models were trained to identify the best performer for energy consumption prediction:

**Stochastic Gradient Descent Regressor (SGDRegressor):**

Performed well with large datasets but required careful tuning of the learning rate.
**Random Forest Regressor:**

Captured non-linear relationships effectively but had higher training time.
**Decision Tree Regressor:**

Simpler and faster but prone to overfitting, especially with fewer data points.
After evaluation, the Random Forest Regressor provided the best balance between accuracy and generalization. This model was selected for deployment.

## 📌 Model Persistence

The trained model was saved using Joblib for easy integration with the FastAPI service.
The scaler used for feature normalization was also saved to ensure consistency during predictions.

## 📈 Model Evaluation

The model’s performance was assessed using:
Mean Squared Error (MSE)
R² Score
