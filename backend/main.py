from agents import RiskAssessmentAgent, GuidelineAgent, ControllerAgent
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random
from typing import Dict
import shap
import numpy as np

app = FastAPI(title="AI-CVD Risk Assessment API")

# ---------------- CORS ----------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------- DATA MODEL ----------------
class PatientData(BaseModel):
    age: int
    sex: int  # 1 = male, 0 = female
    cp: int  # chest pain type: 0-3
    trestbps: int  # resting blood pressure
    chol: int  # serum cholesterol in mg/dl
    fbs: int  # fasting blood sugar > 120 mg/dl
    restecg: int  # resting electrocardiographic results (0-2)
    thalach: int  # maximum heart rate achieved
    exang: int  # exercise induced angina (1 = yes; 0 = no)
    oldpeak: float  # ST depression induced by exercise
    slope: int  # the slope of the peak exercise ST segment (0-2)
    ca: int  # number of major vessels (0-4) colored by flourosopy
    thal: int  # 0 = normal; 1 = fixed defect; 2 = reversable defect


# ---------------- MOCK ML MODEL ----------------
class MockCVDRiskModel:
    """
    Sophisticated mock model that simulates ML prediction
    Based on actual medical risk factors
    """
    
    def __init__(self):
        # Feature weights based on medical literature
        self.weights = {
            'age': 0.12,
            'sex': 0.08,
            'cp': 0.15,
            'trestbps': 0.10,
            'chol': 0.09,
            'fbs': 0.05,
            'restecg': 0.07,
            'thalach': 0.08,
            'exang': 0.10,
            'oldpeak': 0.11,
            'slope': 0.08,
            'ca': 0.14,
            'thal': 0.13
        }
    
    def calculate_risk_score(self, data: PatientData) -> float:
        """
        Calculate a risk score based on weighted features
        Returns a probability between 0 and 1
        """
        risk_score = 0.0
        
        # Age factor (higher age = higher risk)
        age_normalized = min((data.age - 30) / 50, 1.0)
        risk_score += age_normalized * self.weights['age']
        
        # Sex factor (males have higher risk)
        risk_score += data.sex * self.weights['sex']
        
        # Chest pain type (type 0 = typical angina = highest risk)
        cp_risk = {0: 1.0, 1: 0.7, 2: 0.4, 3: 0.1}
        risk_score += cp_risk.get(data.cp, 0.5) * self.weights['cp']
        
        # Blood pressure (>140 is hypertension)
        bp_normalized = min((data.trestbps - 120) / 80, 1.0)
        risk_score += max(bp_normalized, 0) * self.weights['trestbps']
        
        # Cholesterol (>200 is concerning)
        chol_normalized = min((data.chol - 200) / 200, 1.0)
        risk_score += max(chol_normalized, 0) * self.weights['chol']
        
        # Fasting blood sugar
        risk_score += data.fbs * self.weights['fbs']
        
        # Resting ECG (2 = probable/definite left ventricular hypertrophy)
        ecg_risk = {0: 0.2, 1: 0.6, 2: 1.0}
        risk_score += ecg_risk.get(data.restecg, 0.5) * self.weights['restecg']
        
        # Max heart rate (lower = higher risk)
        hr_normalized = 1.0 - min((data.thalach - 100) / 120, 1.0)
        risk_score += max(hr_normalized, 0) * self.weights['thalach']
        
        # Exercise induced angina
        risk_score += data.exang * self.weights['exang']
        
        # ST depression (oldpeak)
        oldpeak_normalized = min(data.oldpeak / 4.0, 1.0)
        risk_score += oldpeak_normalized * self.weights['oldpeak']
        
        # Slope (0 = upsloping = best, 2 = downsloping = worst)
        slope_risk = {0: 0.2, 1: 0.6, 2: 1.0}
        risk_score += slope_risk.get(data.slope, 0.5) * self.weights['slope']
        
        # Number of major vessels (more vessels = higher risk)
        ca_normalized = data.ca / 4.0
        risk_score += ca_normalized * self.weights['ca']
        
        # Thalassemia (2 = reversible defect = highest risk)
        thal_risk = {0: 0.2, 1: 0.6, 2: 1.0, 3: 0.4}
        risk_score += thal_risk.get(data.thal, 0.5) * self.weights['thal']
        
        # Add small random noise to simulate model uncertainty
        noise = random.uniform(-0.05, 0.05)
        risk_score = max(0.0, min(1.0, risk_score + noise))
        
        return risk_score
    
    def get_risk_breakdown(self, data: PatientData) -> Dict[str, float]:
        """
        Return individual risk factor contributions
        """
        breakdown = {}
        
        # Calculate normalized contributions
        age_risk = min((data.age - 30) / 50, 1.0) * self.weights['age']
        breakdown['age'] = age_risk
        
        bp_risk = max(min((data.trestbps - 120) / 80, 1.0), 0) * self.weights['trestbps']
        breakdown['bp'] = bp_risk
        
        chol_risk = max(min((data.chol - 200) / 200, 1.0), 0) * self.weights['chol']
        breakdown['cholesterol'] = chol_risk
        
        hr_risk = (1.0 - min((data.thalach - 100) / 120, 1.0)) * self.weights['thalach']
        breakdown['heart_rate'] = max(hr_risk, 0)
        
        cp_risk = {0: 1.0, 1: 0.7, 2: 0.4, 3: 0.1}
        breakdown['chest_pain'] = cp_risk.get(data.cp, 0.5) * self.weights['cp']
        
        ecg_risk = {0: 0.2, 1: 0.6, 2: 1.0}
        breakdown['ecg'] = ecg_risk.get(data.restecg, 0.5) * self.weights['restecg']
        
        breakdown['vessels'] = (data.ca / 4.0) * self.weights['ca']
        
        thal_risk = {0: 0.2, 1: 0.6, 2: 1.0, 3: 0.4}
        breakdown['thalassemia'] = thal_risk.get(data.thal, 0.5) * self.weights['thal']
        
        breakdown['exercise'] = data.exang * self.weights['exang']
        
        return breakdown


# Initialize model
model = MockCVDRiskModel()

class SHAPExplainer:
    """Provides SHAP-based explanations for predictions"""
    
    def __init__(self, model):
        self.model = model
        # For mock model, we'll simulate SHAP values
        # When you add real model, use: self.explainer = shap.TreeExplainer(model)
        
    def explain_prediction(self, patient_features, feature_names):
        """Generate SHAP values for a prediction"""
        
        # Mock SHAP values (replace with real when you have trained model)
        # Real code: shap_values = self.explainer.shap_values(patient_features)
        
        # Simulated SHAP values based on feature importance
        shap_values = {
            'age': patient_features['age'] * 0.002,  # Positive = increases risk
            'sex': patient_features['sex'] * 0.05,
            'cp': (3 - patient_features['cp']) * 0.04,  # Lower cp = higher risk
            'trestbps': max(0, (patient_features['trestbps'] - 120) * 0.001),
            'chol': max(0, (patient_features['chol'] - 200) * 0.0004),
            'fbs': patient_features['fbs'] * 0.03,
            'restecg': patient_features['restecg'] * 0.02,
            'thalach': max(0, (160 - patient_features['thalach']) * 0.0008),
            'exang': patient_features['exang'] * 0.08,
            'oldpeak': patient_features['oldpeak'] * 0.03,
            'slope': patient_features['slope'] * 0.025,
            'ca': patient_features['ca'] * 0.04,
            'thal': patient_features['thal'] * 0.035
        }
        
        return {
            'shap_values': shap_values,
            'base_value': 0.3,  # Average risk in population
            'feature_contributions': sorted(
                shap_values.items(), 
                key=lambda x: abs(x[1]), 
                reverse=True
            )[:5]  # Top 5 contributors
        }

# FIND the /assess endpoint and MODIFY IT:
@app.post("/assess")
def assess_patient(data: PatientData):
    """Comprehensive assessment with risk breakdown"""
    risk_score = model.calculate_risk_score(data)
    breakdown = model.get_risk_breakdown(data)
    
    # ADD THIS: Create SHAP explainer
    explainer = SHAPExplainer(model)
    patient_dict = data.dict()
    shap_explanation = explainer.explain_prediction(patient_dict, list(patient_dict.keys()))
    
    # ... rest of your existing code for risk_level and recommendation ...
    
    # MODIFY the return statement to include SHAP:
    return {
        "risk_score": risk_score,
        "risk_level": risk_level,
        "recommendation": recommendation,
        "risk_breakdown": breakdown,
        "clinical_notes": clinical_notes,
        "shap_explanation": shap_explanation,  # ADD THIS LINE
        "model_version": "Mock ML Model v2.0 (Academic Prototype)",
        "note": "This is a simulated AI prediction for educational/research purposes only."
    }

@app.post("/assess")
def assess_patient(data: PatientData):
    """Comprehensive multi-agent assessment"""
    
    # Agent 1: ML Assessment
    ml_agent = RiskAssessmentAgent(model)
    ml_assessment = ml_agent.assess(data.dict())
    
    # Agent 2: Guideline Assessment
    guideline_agent = GuidelineAgent()
    guideline_assessment = guideline_agent.assess(data.dict())
    
    # Agent 3: Controller (conflict resolution)
    controller = ControllerAgent()
    final_decision = controller.reconcile(ml_assessment, guideline_assessment)
    
    # Generate breakdown and SHAP
    breakdown = model.get_risk_breakdown(data)
    explainer = SHAPExplainer(model)
    shap_explanation = explainer.explain_prediction(data.dict(), list(data.dict().keys()))
    
    # Determine final risk level
    risk_level = final_decision['final_risk_level']
    risk_score = final_decision['final_risk_score'] if final_decision['final_risk_score'] else ml_assessment['risk_score']
    
    # Generate recommendations based on final decision
    if risk_level == "Low":
        recommendation = (
            "✓ Patient shows low cardiovascular risk.\n\n"
            "Recommendations:\n"
            "• Continue regular annual checkups\n"
            "• Maintain healthy lifestyle\n"
            "• Monitor blood pressure and cholesterol"
        )
    elif risk_level == "Medium":
        recommendation = (
            "⚠ Patient shows moderate cardiovascular risk.\n\n"
            "Recommendations:\n"
            "• Schedule follow-up within 3-6 months\n"
            "• Implement lifestyle modifications\n"
            "• Regular monitoring of vital signs\n"
            "• Consider preventive medication if risk factors persist"
        )
    elif risk_level == "High":
        recommendation = (
            "⚠⚠ ALERT: Patient shows high cardiovascular risk.\n\n"
            "Urgent Recommendations:\n"
            "• Immediate medical evaluation required\n"
            "• Comprehensive cardiac workup\n"
            "• Consultation with cardiologist within 1-2 weeks\n"
            "• Aggressive lifestyle modifications\n"
            "• Medication therapy likely needed"
        )
    else:  # UNCERTAIN
        recommendation = (
            "⚠⚠ UNCERTAIN ASSESSMENT\n\n"
            "ML model and clinical guidelines show significant disagreement.\n"
            "Manual review by cardiologist is strongly recommended."
        )
    
    # Build clinical notes
    clinical_notes = []
    if data.age > 60:
        clinical_notes.append("Age is a significant risk factor")
    if data.trestbps > 140:
        clinical_notes.append("Elevated blood pressure detected")
    
    return {
        "risk_score": risk_score,
        "risk_level": risk_level,
        "recommendation": recommendation,
        "risk_breakdown": breakdown,
        "shap_explanation": shap_explanation,
        
        # Multi-agent results
        "agent_assessments": {
            "ml_agent": ml_assessment,
            "guideline_agent": guideline_assessment,
            "controller_decision": final_decision
        },
        
        "clinical_notes": clinical_notes,
        "model_version": "Multi-Agent System v2.0 (Academic Prototype)"
    }


# ---------------- HEALTH CHECK ----------------
@app.get("/")
def root():
    return {
        "message": "AI-CVD Risk Assessment API",
        "status": "running",
        "version": "2.0 (Mock ML Model)"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "model": "Mock ML Model (Academic Prototype)"
    }


# ---------------- PREDICTION ENDPOINT ----------------
@app.post("/predict")
def predict(data: PatientData):
    """
    Direct prediction endpoint
    """
    risk_score = model.calculate_risk_score(data)
    
    # Determine risk level
    if risk_score < 0.33:
        risk_level = "Low"
        recommendation = (
            "Patient shows low cardiovascular risk. "
            "Continue regular checkups and maintain healthy lifestyle habits."
        )
    elif risk_score < 0.66:
        risk_level = "Medium"
        recommendation = (
            "Patient shows moderate cardiovascular risk. "
            "Consider lifestyle modifications, regular monitoring, "
            "and potential preventive interventions. "
            "Consult with a cardiologist for detailed assessment."
        )
    else:
        risk_level = "High"
        recommendation = (
            "Patient shows high cardiovascular risk. "
            "Immediate medical evaluation recommended. "
            "Consider comprehensive cardiac workup including stress test, "
            "echocardiogram, and consultation with a cardiologist. "
            "Lifestyle modifications and medication may be necessary."
        )
    
    return {
        "risk_score": risk_score,
        "risk_level": risk_level,
        "recommendation": recommendation
    }


# ---------------- ASSESSMENT ENDPOINT (Enhanced) ----------------
@app.post("/assess")
def assess_patient(data: PatientData):
    """
    Comprehensive assessment with risk breakdown
    """
    risk_score = model.calculate_risk_score(data)
    breakdown = model.get_risk_breakdown(data)
    
    # Determine risk level
    if risk_score < 0.33:
        risk_level = "Low"
        recommendation = (
            "✓ Patient shows low cardiovascular risk.\n\n"
            "Recommendations:\n"
            "• Continue regular annual checkups\n"
            "• Maintain healthy lifestyle (balanced diet, regular exercise)\n"
            "• Monitor blood pressure and cholesterol levels\n"
            "• Avoid smoking and excessive alcohol consumption"
        )
    elif risk_score < 0.66:
        risk_level = "Medium"
        recommendation = (
            "⚠ Patient shows moderate cardiovascular risk.\n\n"
            "Recommendations:\n"
            "• Schedule follow-up within 3-6 months\n"
            "• Implement lifestyle modifications (diet, exercise, stress management)\n"
            "• Regular monitoring of vital signs\n"
            "• Consider preventive medication if risk factors persist\n"
            "• Consult with cardiologist for detailed risk assessment"
        )
    else:
        risk_level = "High"
        recommendation = (
            "⚠ ALERT: Patient shows high cardiovascular risk.\n\n"
            "Urgent Recommendations:\n"
            "• Immediate medical evaluation required\n"
            "• Comprehensive cardiac workup (ECG, stress test, echocardiogram)\n"
            "• Consultation with cardiologist within 1-2 weeks\n"
            "• Aggressive lifestyle modifications\n"
            "• Medication therapy likely needed\n"
            "• Close monitoring and regular follow-ups essential"
        )
    
    # Add clinical insights
    clinical_notes = []
    
    if data.age > 60:
        clinical_notes.append("Age is a significant risk factor")
    if data.trestbps > 140:
        clinical_notes.append("Elevated blood pressure detected")
    if data.chol > 240:
        clinical_notes.append("High cholesterol levels")
    if data.thalach < 120:
        clinical_notes.append("Reduced maximum heart rate")
    if data.ca > 2:
        clinical_notes.append("Multiple vessel involvement")
    if data.thal == 2:
        clinical_notes.append("Reversible thalassemia defect detected")
    if data.exang == 1:
        clinical_notes.append("Exercise-induced angina present")
    
    return {
        "risk_score": risk_score,
        "risk_level": risk_level,
        "recommendation": recommendation,
        "risk_breakdown": breakdown,
        "clinical_notes": clinical_notes,
        "model_version": "Mock ML Model v2.0 (Academic Prototype)",
        "note": "This is a simulated AI prediction for educational/research purposes only. "
                "Always consult with qualified healthcare professionals for actual medical decisions."
    }


# ---------------- BATCH ASSESSMENT ----------------
@app.post("/assess_batch")
def assess_batch(patients: list[PatientData]):
    """
    Assess multiple patients at once
    """
    results = []
    for patient in patients:
        result = assess_patient(patient)
        results.append(result)
    return {"results": results, "count": len(results)}


# ---------------- MODEL INFO ----------------
@app.get("/model/info")
def model_info():
    return {
        "model_type": "Mock Machine Learning Model",
        "purpose": "Academic/Research Simulation",
        "features": list(model.weights.keys()),
        "output": "Cardiovascular disease risk probability (0-1)",
        "note": "This is NOT a real trained model. It uses rule-based heuristics "
                "to simulate ML predictions for demonstration purposes."
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
