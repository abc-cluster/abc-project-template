#!/usr/bin/env sh

# LOCAL execution
pip install fastapi[all] h2o
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080


curl -X POST -H "Content-Type: application/json" \
  -d '{"feature1": 1.0, "feature2": 2.0}' \
  $(waypoint url)/predict
