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

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Can restrict this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define the input data schema — all required training features
class AQIInput(BaseModel):
    PT08_S1_CO: float
    NMHC_GT: float
    C6H6_GT: float
    PT08_S2_NMHC: float
    NOx_GT: float
    PT08_S3_NOx: float
    NO2_GT: float
    PT08_S4_NO2: float
    PT08_S5_O3: float
    T: float
    RH: float
    AH: float

@app.post("/predict")
def predict_aqi(data: AQIInput):
    # Convert input to DataFrame
    input_data = pd.DataFrame([data.dict()])

    # Rename columns to match exactly how the model was trained
    input_data.columns = [
        "PT08.S1(CO)",
        "NMHC(GT)",
        "C6H6(GT)",
        "PT08.S2(NMHC)",
        "NOx(GT)",
        "PT08.S3(NOx)",
        "NO2(GT)",
        "PT08.S4(NO2)",
        "PT08.S5(O3)",
        "T",
        "RH",
        "AH"
    ]

    # Reorder columns to match training order (redundant if already correct)
    feature_order = [
        "PT08.S1(CO)",
        "NMHC(GT)",
        "C6H6(GT)",
        "PT08.S2(NMHC)",
        "NOx(GT)",
        "PT08.S3(NOx)",
        "NO2(GT)",
        "PT08.S4(NO2)",
        "PT08.S5(O3)",
        "T",
        "RH",
        "AH"
    ]
    input_data = input_data[feature_order]

    # Make prediction
    prediction = model.predict(input_data)

    # Ensure prediction is non-negative
    prediction = max(prediction.tolist()[0], 0)

    return {"predicted_AQI": prediction}

# Run the API locally
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
