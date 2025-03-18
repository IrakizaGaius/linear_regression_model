import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, ValidationError
from typing import Annotated
from fastapi.middleware.cors import CORSMiddleware
import joblib
import uvicorn
import numpy as np

# Load the model and scaler
try:
    model_path = os.path.join(os.path.dirname(__file__), 'best_model.pkl')
    model_data = joblib.load(model_path)
    best_model = model_data['model']
    scaler = model_data['scaler']
    feature_names = model_data['feature_names']
except FileNotFoundError:
    raise RuntimeError("Model file 'best_model.pkl' not found.")
except Exception as e:
    raise RuntimeError(f"Error loading model: {e}")

# FastAPI app setup
app = FastAPI(title="GridGuardian Energy Prediction API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic model for input validation
class PredictionRequest(BaseModel):
    Household_Size: Annotated[int, Field(ge=1, le=20)]
    Appliance_Type_Air_Conditioning: Annotated[int, Field(ge=0, le=1, alias="Appliance_Type_Air Conditioning")]
    Appliance_Type_Dishwasher: Annotated[int, Field(ge=0, le=1)]
    Appliance_Type_Microwave: Annotated[int, Field(ge=0, le=1)]
    Appliance_Type_Washing_Machine: Annotated[int, Field(ge=0, le=1)]
    Appliance_Type_Fridge: Annotated[int, Field(ge=0, le=1)]
    Appliance_Type_TV: Annotated[int, Field(ge=0, le=1)]
    Appliance_Type_Computer: Annotated[int, Field(ge=0, le=1)]
    Appliance_Type_Oven: Annotated[int, Field(ge=0, le=1)]
    Appliance_Type_Heater: Annotated[int, Field(ge=0, le=1)]
    Appliance_Type_Lights: Annotated[int, Field(ge=0, le=1)]
    Season_Fall: Annotated[int, Field(ge=0, le=1)]
    Season_Spring: Annotated[int, Field(ge=0, le=1)]
    Season_Summer: Annotated[int, Field(ge=0, le=1)]
    Season_Winter: Annotated[int, Field(ge=0, le=1)]

@app.post("/predict")
def predict(request: PredictionRequest):
    try:
        # Convert request to array
        input_data = np.array([[
            request.Household_Size,
            request.Appliance_Type_Dishwasher, request.Appliance_Type_Microwave, request.Appliance_Type_Washing_Machine,
            request.Season_Spring, request.Season_Summer, request.Season_Winter, request.Appliance_Type_Fridge,
            request.Appliance_Type_TV, request.Appliance_Type_Computer, request.Appliance_Type_Oven,
            request.Appliance_Type_Heater, request.Appliance_Type_Lights, request.Appliance_Type_Air_Conditioning, request.Season_Fall
        ]])

        # Check feature length
        if input_data.shape[1] != len(feature_names):
            raise ValueError(f"Expected {len(feature_names)} features, but got {input_data.shape[1]}.")

        # Scale input data
        input_scaled = scaler.transform(input_data)

        # Make prediction
        prediction = best_model.predict(input_scaled)[0]
        return {"predicted_energy_consumption_kwh": round(prediction, 2)}

    except ValidationError as ve:
        raise HTTPException(status_code=422, detail=f"Validation Error: {ve}")
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=f"Input Error: {ve}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {e}")

if __name__ == "__main__":
    uvicorn.run("prediction:app", host="0.0.0.0", port=8000, reload=True)
