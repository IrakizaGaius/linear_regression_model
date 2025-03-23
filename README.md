# GridGuardian Model Documentation

## 🔍 Brief Description

GridGuardian uses a machine learning model to predict household appliance energy consumption. It leverages factors like household size, appliance type, and seasonal variations to provide insights into energy usage patterns. This empowers users to make informed decisions and optimize energy consumption in their smart homes.

## GridGuardian Mission Statement

"Empowering Rwandan households with data-driven insights to optimize energy consumption, reduce waste, and promote sustainable living through advanced machine learning technology."

**Why Optimizing Energy Consumption Matters in Rwanda:**

High Reliance on Biomass: Approximately 85% of Rwanda's primary energy use comes from biomass sources, such as firewood and charcoal. This heavy reliance contributes to deforestation and environmental degradation.​
Source: [UNL Institutional Repository Article 2022](https://digitalcommons.unl.edu/cgi/viewcontent.cgi?article=1141&context=ageconugensc)

Dominant Residential Energy Use: Households account for about 81% of Rwanda's total final energy consumption, highlighting the significant impact of residential energy use on the country's overall energy demand. ​
source: [International Energy Agency Reports 2022](https://www.iea.org/countries/rwanda/efficiency-demand)

**Economic Implications:** Implementing energy-efficient practices can lead to substantial cost savings for households, reducing the financial burden associated with energy expenses.

## 📊 Source of Data

The dataset used to train the model comes from [Kaggle: Smart Home Energy Consumption Dataset](https://www.kaggle.com/datasets/mexwell/smart-home-energy-consumption/data). It includes detailed records of energy consumption across various household appliances, making it ideal for building predictive models. This model doesnot specifically uses Rwanda as its case study. But I found it relevant to develop a model that would predict the energy Consumption o a ppliances in asmart home. to help know how to manage the energy spendings.

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

## How to run Grid-Guardian App

### Prerequisites

**Flutter SDK:** Ensure that the Flutter SDK is installed.

**Dart SDK:** Included with Flutter; no separate installation needed.

**Integrated Development Environment (IDE):** Recommend using Visual Studio Code or Android Studio with the Flutter and Dart plugins installed.

### Installation Steps

**Clone the Repository:**

```bash
git clone https://github.com/your-username/grid-guardian.git
```

**Navigate to the Project Directory:**

```bash
cd grid-guardian
```

**Install Dependencies:**

```bash
flutter pub get
```

**Running the Application:**

**For iOS:**

Ensure that Xcode is installed.

**Open the iOS simulator:**

```bash
open -a Simulator
```

**Run the app:**

```bash
flutter run
```

**For Android:**

Ensure that Android Studio and the Android SDK are installed.

**Start an Android emulator or connect a physical device.**

**Run the app:**

```bash
flutter run
```
