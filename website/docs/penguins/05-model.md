---
sidebar_position: 6
title: 5. Train a model
---

# Step 5 — Train a classifier

We'll train baseline + candidate models, log to MLflow (planted), and store
artifacts in `data/models/`.

## Standard model substages

`data:models` provides:

```
data/models/
├── 061_baseline/       # simple baselines (logistic regression, dummy)
├── 062_candidate/      # main models being evaluated
├── 063_ensemble/       # ensembles
├── 064_optimized/      # tuned versions
└── 065_production/     # final chosen model
```

## Baseline: logistic regression

```python
# scripts/train_baseline.py
from pathlib import Path
import pandas as pd
import joblib
import mlflow
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report

TRAIN = "data/model-input/052_train/penguins_train.csv"
VAL   = "data/model-input/053_validation/penguins_val.csv"
OUT   = Path("data/models/061_baseline/logreg.joblib")

mlflow.set_experiment("penguins-classifier")

with mlflow.start_run(run_name="baseline-logreg"):
    train = pd.read_csv(TRAIN)
    val   = pd.read_csv(VAL)
    feat_cols = [c for c in train.columns if c != "species"]

    X_tr, y_tr = train[feat_cols], train["species"]
    X_val, y_val = val[feat_cols], val["species"]

    # Drop sex/island/year for now; just numeric features
    numeric = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm",
               "body_mass_g", "bill_ratio", "body_density_proxy"]
    X_tr, X_val = X_tr[numeric], X_val[numeric]

    clf = LogisticRegression(max_iter=1000, multi_class="multinomial")
    clf.fit(X_tr, y_tr)

    val_acc = accuracy_score(y_val, clf.predict(X_val))
    print(f"Validation accuracy: {val_acc:.4f}")

    mlflow.log_metric("val_accuracy", val_acc)
    mlflow.log_param("model", "LogisticRegression")
    mlflow.log_param("max_iter", 1000)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(clf, OUT)
    mlflow.log_artifact(str(OUT))
    print(f"Saved {OUT}")
```

```bash
python scripts/train_baseline.py
```

## Candidate: random forest

```python
# scripts/train_candidate.py
from pathlib import Path
import pandas as pd
import joblib
import mlflow
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report

# (same boilerplate as above; only the model changes)

with mlflow.start_run(run_name="candidate-rf"):
    # ... same data loading ...
    clf = RandomForestClassifier(n_estimators=200, random_state=42)
    clf.fit(X_tr, y_tr)
    val_acc = accuracy_score(y_val, clf.predict(X_val))
    mlflow.log_metric("val_accuracy", val_acc)
    mlflow.log_param("model", "RandomForestClassifier")
    mlflow.log_param("n_estimators", 200)
    OUT = Path("data/models/062_candidate/rf.joblib")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(clf, OUT)
```

## Compare in MLflow UI

```bash
just track-start    # opens MLflow UI on http://localhost:5000
```

You'll see the runs side by side with metrics. Random forest should win at
~0.99 val accuracy vs logreg ~0.97.

## Generate predictions on test set

```python
# scripts/evaluate.py
import pandas as pd
import joblib
from sklearn.metrics import (
    accuracy_score, classification_report, confusion_matrix
)

clf = joblib.load("data/models/062_candidate/rf.joblib")
test = pd.read_csv("data/model-input/051_test/penguins_test.csv")
X = test[["bill_length_mm", "bill_depth_mm", "flipper_length_mm",
          "body_mass_g", "bill_ratio", "body_density_proxy"]]
y = test["species"]

preds = clf.predict(X)
probs = clf.predict_proba(X)

# Save to data/model-output/
pd.DataFrame({"true": y, "pred": preds}).to_csv(
    "data/model-output/071_predictions/test_preds.csv", index=False)

prob_df = pd.DataFrame(probs, columns=clf.classes_)
prob_df["true"] = y.values
prob_df.to_csv("data/model-output/072_probabilities/test_probs.csv", index=False)

# Evaluation metrics
report_text = classification_report(y, preds)
with open("data/model-output/073_evaluation/test_report.txt", "w") as f:
    f.write(report_text)

print(f"Test accuracy: {accuracy_score(y, preds):.4f}")
print(report_text)
```

```bash
python scripts/evaluate.py
```

## Confusion matrix figure

```python
# scripts/plot_cm.py
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import ConfusionMatrixDisplay

preds = pd.read_csv("data/model-output/071_predictions/test_preds.csv")
fig, ax = plt.subplots(figsize=(6, 5))
ConfusionMatrixDisplay.from_predictions(preds["true"], preds["pred"], ax=ax,
                                         cmap="Blues")
ax.set_title("Penguins species — confusion matrix (test set)")
fig.tight_layout()
out = Path("data/08_reporting/082_figures/cm_rf.png")
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out, dpi=150)
print(f"Saved {out}")
```

```bash
python scripts/plot_cm.py
```

## Wire it all into DVC

```yaml
# dvc.yaml (append)
stages:
  split:
    cmd: python scripts/split_data.py
    deps:
      - data/features/044_scaled/penguins_features_scaled.csv
      - scripts/split_data.py
    outs:
      - data/model-input/051_test/penguins_test.csv
      - data/model-input/052_train/penguins_train.csv
      - data/model-input/053_validation/penguins_val.csv
  train:
    cmd: |
      python scripts/train_baseline.py
      python scripts/train_candidate.py
    deps:
      - data/model-input/052_train/penguins_train.csv
      - data/model-input/053_validation/penguins_val.csv
      - scripts/train_baseline.py
      - scripts/train_candidate.py
    outs:
      - data/models/061_baseline/logreg.joblib
      - data/models/062_candidate/rf.joblib
  evaluate:
    cmd: |
      python scripts/evaluate.py
      python scripts/plot_cm.py
    deps:
      - data/models/062_candidate/rf.joblib
      - data/model-input/051_test/penguins_test.csv
    outs:
      - data/model-output/071_predictions/test_preds.csv
      - data/model-output/072_probabilities/test_probs.csv
      - data/model-output/073_evaluation/test_report.txt
      - data/08_reporting/082_figures/cm_rf.png
```

```bash
dvc repro
git add dvc.lock scripts/
git commit -m "model: train rf classifier + eval + cm figure"
```

[Next: Build the report →](./report)
