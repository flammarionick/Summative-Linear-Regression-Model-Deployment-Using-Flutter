# Summative-Linear-Regression-Model-Deployment-Using-Flutter
# AQI Prediction API

This API predicts the **Air Quality Index (AQI)** based on pollution levels using the input values from various sensors.

## API Endpoint

### `/predict`

This endpoint accepts a **POST** request with the following data to predict the AQI.

### Input Data Schema:
- **PT08_S2_NMHC**: The value of PT08 sensor (NMHC).
- **PT08_S5_O3**: The value of PT08 sensor (O3).
- **PT08_S4_NO2**: The value of PT08 sensor (NO2).
- **PT08_S1_CO**: The value of PT08 sensor (CO).

### Example Request Body:
```json
{
  "PT08_S2_NMHC": 300.2,
  "PT08_S5_O3": 450.1,
  "PT08_S4_NO2": 600.5,
  "PT08_S1_CO": 700.3
}
Response Example:
json
Copy
{
  "predicted_AQI": 109.25
}
Publicly Available API Endpoint
You can interact with the API and test predictions via Swagger UI at the following publicly available URL:

Swagger UI Link
Note: Replace <your-api-url> with the actual publicly routable URL of your hosted API.

Demo Video
Watch the demo video of the API in action on YouTube. The video shows how to interact with the API and make predictions.

Demo Video Link

How to Run the Mobile App
Clone the Flutter project:

bash
Copy
git clone <your-repository-url>
cd aqi_prediction_app
Install dependencies:

bash
Copy
flutter pub get
Run the app:

Connect a device or start an emulator.
Run the Flutter app:
bash
Copy
flutter run
Use the App:

Open the app and enter the input values in the TextFields.
Press "Predict AQI" to see the predicted AQI displayed on the screen.
Requirements
Flutter SDK (for the mobile app).
FastAPI (for the backend API).
joblib (for loading the trained model).
scikit-learn (for model predictions).
pandas (for data handling).
To install required dependencies for the API:

bash
Copy
pip install fastapi joblib scikit-learn pandas uvicorn
To install required dependencies for the mobile app:

bash
Copy
flutter pub get
Running the FastAPI Backend
Start the FastAPI server:

If you're running the server locally or hosting it, use the following command:
bash
Copy
uvicorn api:app --reload
Access the Swagger UI at http://127.0.0.1:8000/docs
