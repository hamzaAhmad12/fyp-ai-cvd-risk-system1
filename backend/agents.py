from typing import Dict, List
from pydantic import BaseModel

class RiskAssessmentAgent:
    """Agent 1: ML-based risk prediction"""
    
    def __init__(self, model):
        self.model = model
    
    def assess(self, patient_data: Dict) -> Dict:
        """Assess risk using ML model"""
        risk_score = self.model.calculate_risk_score(patient_data)
        
        return {
            "source": "ML_MODEL",
            "risk_score": risk_score,
            "risk_level": self._categorize_risk(risk_score),
            "confidence": self._calculate_confidence(risk_score)
        }
    
    def _categorize_risk(self, score: float) -> str:
        if score < 0.33:
            return "Low"
        elif score < 0.66:
            return "Medium"
        else:
            return "High"
    
    def _calculate_confidence(self, score: float) -> float:
        # Distance from decision boundaries
        if score < 0.33:
            return 1.0 - (score / 0.33) * 0.3
        elif score < 0.66:
            return 0.7 + min(abs(score - 0.5), 0.16) / 0.16 * 0.2
        else:
            return 0.7 + ((score - 0.66) / 0.34) * 0.3


class GuidelineAgent:
    """Agent 2: Guideline-based assessment"""
    
    def __init__(self):
        # Simplified guideline rules
        self.rules = {
            'high_bp': lambda bp: bp > 140,
            'high_chol': lambda chol: chol > 240,
            'elderly': lambda age: age > 65,
            'exercise_angina': lambda exang: exang == 1,
            'multiple_vessels': lambda ca: ca > 2,
            'severe_thal': lambda thal: thal == 2
        }
    
    def assess(self, patient_data: Dict) -> Dict:
        """Assess risk using clinical guidelines"""
        
        risk_factors = []
        risk_score = 0
        
        # Check each guideline rule
        if self.rules['high_bp'](patient_data.get('trestbps', 0)):
            risk_factors.append('Hypertension (BP >140)')
            risk_score += 0.15
        
        if self.rules['high_chol'](patient_data.get('chol', 0)):
            risk_factors.append('High cholesterol (>240 mg/dL)')
            risk_score += 0.12
        
        if self.rules['elderly'](patient_data.get('age', 0)):
            risk_factors.append('Age >65 years')
            risk_score += 0.18
        
        if self.rules['exercise_angina'](patient_data.get('exang', 0)):
            risk_factors.append('Exercise-induced angina')
            risk_score += 0.20
        
        if self.rules['multiple_vessels'](patient_data.get('ca', 0)):
            risk_factors.append('Multiple vessel blockage')
            risk_score += 0.25
        
        if self.rules['severe_thal'](patient_data.get('thal', 0)):
            risk_factors.append('Reversible thalassemia defect')
            risk_score += 0.15
        
        # Cap at 1.0
        risk_score = min(risk_score, 1.0)
        
        return {
            "source": "GUIDELINES",
            "risk_score": risk_score,
            "risk_level": self._categorize_risk(risk_score),
            "risk_factors_identified": risk_factors,
            "guidelines_applied": [
                "AHA 2019 Hypertension Guidelines",
                "ESC 2021 CVD Prevention Guidelines",
                "WHO Cardiovascular Risk Assessment"
            ]
        }
    
    def _categorize_risk(self, score: float) -> str:
        if score < 0.30:
            return "Low"
        elif score < 0.65:
            return "Medium"
        else:
            return "High"


class ControllerAgent:
    """Agent 3: Conflict detection and resolution"""
    
    def reconcile(self, ml_result: Dict, guideline_result: Dict) -> Dict:
        """Compare and reconcile ML and guideline assessments"""
        
        ml_level = ml_result['risk_level']
        gl_level = guideline_result['risk_level']
        
        # Convert levels to numbers for comparison
        level_map = {"Low": 0, "Medium": 1, "High": 2}
        ml_num = level_map[ml_level]
        gl_num = level_map[gl_level]
        
        difference = abs(ml_num - gl_num)
        
        if difference == 0:
            # Perfect agreement
            return {
                "status": "AGREEMENT",
                "confidence": "HIGH",
                "final_risk_level": ml_level,
                "final_risk_score": ml_result['risk_score'],
                "message": "✓ ML model and clinical guidelines are in agreement",
                "conflicts": []
            }
        
        elif difference == 1:
            # Minor conflict
            avg_score = (ml_result['risk_score'] + guideline_result['risk_score']) / 2
            conflicts = self._identify_conflicts(ml_result, guideline_result)
            
            return {
                "status": "MINOR_CONFLICT",
                "confidence": "MEDIUM",
                "final_risk_level": self._resolve_minor_conflict(ml_level, gl_level),
                "final_risk_score": avg_score,
                "message": "⚠ Slight disagreement detected - using averaged assessment",
                "conflicts": conflicts
            }
        
        else:
            # Major conflict
            conflicts = self._identify_conflicts(ml_result, guideline_result)
            
            return {
                "status": "MAJOR_CONFLICT",
                "confidence": "LOW",
                "final_risk_level": "UNCERTAIN",
                "final_risk_score": None,
                "message": "⚠⚠ Significant disagreement - manual review strongly recommended",
                "conflicts": conflicts,
                "recommendation": "Consult cardiologist for comprehensive clinical evaluation"
            }
    
    def _resolve_minor_conflict(self, ml_level: str, gl_level: str) -> str:
        """Resolve minor conflicts by taking the higher risk"""
        level_map = {"Low": 0, "Medium": 1, "High": 2}
        levels = [ml_level, gl_level]
        return max(levels, key=lambda x: level_map[x])
    
    def _identify_conflicts(self, ml_result: Dict, guideline_result: Dict) -> List[str]:
        """Identify specific areas of disagreement"""
        conflicts = []
        
        ml_level = ml_result['risk_level']
        gl_level = guideline_result['risk_level']
        
        conflicts.append(f"ML Model suggests {ml_level} risk ({ml_result['risk_score']:.1%})")
        conflicts.append(f"Guidelines suggest {gl_level} risk ({guideline_result['risk_score']:.1%})")
        
        if 'risk_factors_identified' in guideline_result:
            if len(guideline_result['risk_factors_identified']) > 3:
                conflicts.append(f"Multiple guideline violations detected: {len(guideline_result['risk_factors_identified'])} factors")
        
        return conflicts