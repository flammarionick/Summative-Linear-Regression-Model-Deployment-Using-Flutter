from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd

# Load the trained model
model = joblib.load("best_aqi_model.pkl")

# Define FastAPI app
app = FastAPI(title="AQI Prediction API")

# CORS config
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define expected input schema
class AQIInput(BaseModel):
    PT08_S2_NMHC: float
    PT08_S1_CO: float
    PT08_S5_O3: float
    PT08_S4_NO2: float
    PT08_S3_NOx: float

@app.post("/predict")
def predict_aqi(data: AQIInput):
    # Match column names from training
    input_data = pd.DataFrame([{
        "PT08.S2(NMHC)": data.PT08_S2_NMHC,
        "PT08.S1(CO)": data.PT08_S1_CO,
        "PT08.S5(O3)": data.PT08_S5_O3,
        "PT08.S4(NO2)": data.PT08_S4_NO2,
        "PT08.S3(NOx)": data.PT08_S3_NOx,
    }])

    # Reorder exactly as trained
    ordered_cols = [
        "PT08.S2(NMHC)",
        "PT08.S1(CO)",
        "PT08.S5(O3)",
        "PT08.S4(NO2)",
        "PT08.S3(NOx)"
    ]
    input_data = input_data[ordered_cols]

    # Predict
    prediction = model.predict(input_data)
    prediction = max(prediction.tolist()[0], 0)

    return {"predicted_AQI": prediction}

# Run locally
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)