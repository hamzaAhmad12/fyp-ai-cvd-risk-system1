import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final double riskScore = (result['risk_score'] ?? 0.5).toDouble();
    final String riskLevel = result['risk_level'] ?? 'Unknown';
    final String recommendation = result['recommendation'] ?? '';
    final Map<String, dynamic> breakdown = result['risk_breakdown'] ?? {};

    // Determine color based on risk level
    Color riskColor;
    IconData riskIcon;
    
    if (riskLevel == 'Low') {
      riskColor = Colors.green;
      riskIcon = Icons.check_circle;
    } else if (riskLevel == 'Medium') {
      riskColor = Colors.orange;
      riskIcon = Icons.warning;
    } else if (riskLevel == 'High') {
      riskColor = Colors.red;
      riskIcon = Icons.error;
    } else {
      // UNCERTAIN
      riskColor = Colors.grey;
      riskIcon = Icons.help_outline;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Main Risk Card
                Card(
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          riskColor.withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          riskIcon,
                          size: 80,
                          color: riskColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cardiovascular Risk Assessment',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Risk Score Display
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: riskColor, width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Risk Score',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(riskScore * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: riskColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: riskColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  riskLevel.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Risk Bar
                        _buildRiskBar(riskScore),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Multi-Agent Assessment Card (NEW - ADDED)
                if (result['agent_assessments'] != null) ...[
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.groups, color: Color(0xFF0E7490)),
                              const SizedBox(width: 12),
                              const Text(
                                'Multi-Agent Analysis',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildAgentComparison(result['agent_assessments']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Risk Breakdown Card
                if (breakdown.isNotEmpty) ...[
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.analytics, color: Color(0xFF0E7490)),
                              const SizedBox(width: 12),
                              const Text(
                                'Risk Factor Breakdown',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ...breakdown.entries.map((entry) {
                            return _buildRiskFactor(
                              entry.key,
                              entry.value.toDouble(),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // SHAP Explanation Card (NEW - ADDED)
                if (result['shap_explanation'] != null) ...[
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology, color: Color(0xFF0E7490)),
                              const SizedBox(width: 12),
                              const Text(
                                'AI Explanation: Why This Prediction?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Top factors influencing the risk assessment:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._buildSHAPContributions(result['shap_explanation']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Recommendations Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medical_services, color: Color(0xFF0E7490)),
                            const SizedBox(width: 12),
                            const Text(
                              'Clinical Recommendations',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          recommendation.isNotEmpty 
                              ? recommendation 
                              : 'No specific recommendations at this time.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This is a mock AI prediction for academic purposes. Always consult with a healthcare professional.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
                          'New Assessment',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E7490),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement save/export functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Export feature coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Export Report'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0E7490)],
          ),
        ),
      ),
      title: const Text(
        'Assessment Results',
        style: TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRiskBar(double score) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Level Indicator',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Colors.green,
                    Colors.yellow,
                    Colors.orange,
                    Colors.red,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: score * (constraints.maxWidth - 24) - 12,
                    top: -8,
                    child: Container(
                      width: 24,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text('Medium', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text('High', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRiskFactor(String factor, double contribution) {
    final percentage = (contribution * 100).toStringAsFixed(1);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatFactorName(factor),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E7490),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: contribution,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getContributionColor(contribution),
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // NEW METHOD: Build SHAP Contributions
  List<Widget> _buildSHAPContributions(Map<String, dynamic> shapData) {
    if (shapData['feature_contributions'] == null) return [];
    
    List contributions = shapData['feature_contributions'];
    
    return contributions.map((contrib) {
      String feature = contrib[0];
      double value = contrib[1].toDouble();
      bool increases = value > 0;
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              increases ? Icons.arrow_upward : Icons.arrow_downward,
              color: increases ? Colors.red : Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatFeatureName(feature),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: value.abs() / 0.1,  // Normalize for display
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      increases ? Colors.red : Colors.green,
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              increases ? 'Increases Risk' : 'Decreases Risk',
              style: TextStyle(
                fontSize: 12,
                color: increases ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // NEW METHOD: Build Agent Comparison
  Widget _buildAgentComparison(Map<String, dynamic> agents) {
    final mlAgent = agents['ml_agent'];
    final guidelineAgent = agents['guideline_agent'];
    final controller = agents['controller_decision'];
    
    return Column(
      children: [
        // ML Agent Result
        _buildAgentRow(
          'ML Model',
          mlAgent['risk_level'],
          mlAgent['risk_score'].toDouble(),
          Icons.computer,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        
        // Guideline Agent Result
        _buildAgentRow(
          'Clinical Guidelines',
          guidelineAgent['risk_level'],
          guidelineAgent['risk_score'].toDouble(),
          Icons.medical_services,
          Colors.green,
        ),
        const SizedBox(height: 16),
        
        // Controller Decision
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor(controller['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(controller['status']),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(controller['status']),
                    color: _getStatusColor(controller['status']),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller['status'].toString().replaceAll('_', ' '),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(controller['status']),
                      ),
                    ),
                  ),
                  // Confidence badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(controller['status']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller['confidence'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                controller['message'],
                style: const TextStyle(fontSize: 14),
              ),
              if (controller['conflicts'] != null && 
                  (controller['conflicts'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Conflicts Detected:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(controller['conflicts'] as List).map((conflict) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            conflict.toString(), 
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // NEW METHOD: Build Agent Row
  Widget _buildAgentRow(String name, String level, double score, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$level Risk',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(score * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // NEW METHOD: Get Status Color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'AGREEMENT':
        return Colors.green;
      case 'MINOR_CONFLICT':
        return Colors.orange;
      case 'MAJOR_CONFLICT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // NEW METHOD: Get Status Icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'AGREEMENT':
        return Icons.check_circle;
      case 'MINOR_CONFLICT':
        return Icons.warning;
      case 'MAJOR_CONFLICT':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _formatFactorName(String factor) {
    final Map<String, String> factorNames = {
      'age': 'Age Factor',
      'bp': 'Blood Pressure',
      'cholesterol': 'Cholesterol Level',
      'heart_rate': 'Heart Rate',
      'chest_pain': 'Chest Pain Type',
      'ecg': 'ECG Results',
      'vessels': 'Vessel Blockage',
      'thalassemia': 'Thalassemia',
      'exercise': 'Exercise Response',
      // Add SHAP feature names
      'sex': 'Sex/Gender',
      'cp': 'Chest Pain Type',
      'trestbps': 'Resting Blood Pressure',
      'chol': 'Cholesterol',
      'fbs': 'Fasting Blood Sugar',
      'restecg': 'Resting ECG',
      'thalach': 'Max Heart Rate',
      'exang': 'Exercise Angina',
      'oldpeak': 'ST Depression',
      'slope': 'ST Slope',
      'ca': 'Major Vessels',
      'thal': 'Thalassemia Type',
    };
    return factorNames[factor] ?? factor.toUpperCase();
  }

  Color _getContributionColor(double contribution) {
    if (contribution < 0.3) return Colors.green;
    if (contribution < 0.6) return Colors.orange;
    return Colors.red;
  }
}