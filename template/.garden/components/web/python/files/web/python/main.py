#!/usr/bin/env python3

from fastapi import FastAPI, Request
from pydantic import BaseModel
import h2o
import os

app = FastAPI()

# Initialize H2O and load the pre-built model
h2o.init()
model_path = os.path.join(os.path.dirname(__file__), "model", "model.zip")
model = h2o.import_mojo(model_path)  # Use h2o.load_model if not a MOJO


class PredictRequest(BaseModel):
    # Define your input fields here, e.g.:
    feature1: float
    feature2: float
    # Add more features as needed


@app.post("/predict")
async def predict(request: PredictRequest):
    data_dict = request.dict()
    frame = h2o.H2OFrame([data_dict])
    pred = model.predict(frame)
    # Convert prediction to a serializable format
    result = pred.as_data_frame().to_dict(orient="records")
    return {"prediction": result}


@app.get("/")
async def root():
    return {"message": "H2O Model Inference API is running."}
