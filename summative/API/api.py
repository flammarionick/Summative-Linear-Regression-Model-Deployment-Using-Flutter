from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
import json

# Load the trained model
model = joblib.load("best_aqi_model.pkl")

# Define the FastAPI app 
app = FastAPI(title="AQI Prediction API")

# CORS configuration: Allow all origins (can be restricted to specific URLs later)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this to your Flutter app's URL for production
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)

# Define the input data schema
class AQIInput(BaseModel):
    PT08_S2_NMHC: float
    PT08_S5_O3: float
    PT08_S4_NO2: float
    PT08_S1_CO: float

@app.post("/predict")
def predict_aqi(data: AQIInput):
    # Convert input data into a DataFrame
    input_data = pd.DataFrame([data.dict()])

    # Adjust feature names to match those used during training
    input_data.columns = [
        "PT08.S2(NMHC)", "PT08.S5(O3)", "PT08.S4(NO2)", "PT08.S1(CO)"
    ]

    # Make prediction
    prediction = model.predict(input_data)

    # Clip prediction to be at least 0
    prediction = max(prediction.tolist()[0], 0)  # Ensure the AQI is non-negative

    return {"predicted_AQI": prediction}

# Run the API using Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 