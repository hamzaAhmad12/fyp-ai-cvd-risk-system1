import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Text Controllers for numeric inputs
  final ageController = TextEditingController();
  final restingBpController = TextEditingController();
  final cholesterolController = TextEditingController();
  final maxHeartRateController = TextEditingController();
  final oldpeakController = TextEditingController();

  // Dropdown/Selection values
  int sex = 1; // 1 = male, 0 = female
  int chestPainType = 0; // 0-3
  bool fastingBloodSugar = false; // >120 mg/dl
  int restingECG = 0; // 0-2
  bool exerciseAngina = false;
  int slope = 0; // 0-2
  int ca = 0; // 0-4 (number of major vessels)
  int thal = 0; // 0-3

  bool loading = false;

  @override
  void dispose() {
    ageController.dispose();
    restingBpController.dispose();
    cholesterolController.dispose();
    maxHeartRateController.dispose();
    oldpeakController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.monitor_heart, size: 50, color: Color(0xFF0E7490)),
                            SizedBox(height: 12),
                            Text(
                              'Comprehensive Cardiovascular Assessment',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please fill in all patient parameters',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section 1: Demographics
                      _sectionHeader('Demographics'),
                      _buildNumericInput('Age (years)', ageController, 'age'),
                      _buildGenderSelector(),
                      const SizedBox(height: 24),

                      // Section 2: Vital Signs
                      _sectionHeader('Vital Signs'),
                      _buildNumericInput('Resting Blood Pressure (mm Hg)', restingBpController, 'bp'),
                      _buildNumericInput('Serum Cholesterol (mg/dl)', cholesterolController, 'chol'),
                      _buildNumericInput('Max Heart Rate Achieved (bpm)', maxHeartRateController, 'hr'),
                      const SizedBox(height: 24),

                      // Section 3: Clinical Findings
                      _sectionHeader('Clinical Findings'),
                      _buildChestPainSelector(),
                      _buildFastingBloodSugarSwitch(),
                      _buildRestingECGSelector(),
                      _buildExerciseAnginaSwitch(),
                      _buildNumericInput('ST Depression (oldpeak)', oldpeakController, 'oldpeak', isDecimal: true),
                      _buildSlopeSelector(),
                      const SizedBox(height: 24),

                      // Section 4: Advanced Diagnostics
                      _sectionHeader('Advanced Diagnostics'),
                      _buildCASelector(),
                      _buildThalSelector(),
                      const SizedBox(height: 32),

                      // Submit Button
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: loading ? null : _submitForm,
                            icon: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.analytics, color: Colors.white),
                            label: Text(
                              loading ? 'Analyzing...' : 'Run AI Risk Analysis',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E7490),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- APP BAR ----------
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
        'Clinical Risk Dashboard',
        style: TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------- SECTION HEADER ----------
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF0E7490),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF020617),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- NUMERIC INPUT ----------
  Widget _buildNumericInput(String label, TextEditingController controller, String hint, {bool isDecimal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter $hint',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  // ---------- GENDER SELECTOR ----------
  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sex',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Male'),
                  value: 1,
                  groupValue: sex,
                  onChanged: (v) => setState(() => sex = v!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Female'),
                  value: 0,
                  groupValue: sex,
                  onChanged: (v) => setState(() => sex = v!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- CHEST PAIN TYPE ----------
  Widget _buildChestPainSelector() {
    const types = [
      'Typical Angina',
      'Atypical Angina',
      'Non-Anginal Pain',
      'Asymptomatic'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chest Pain Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButtonFormField<int>(
              value: chestPainType,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: List.generate(
                types.length,
                (i) => DropdownMenuItem(value: i, child: Text(types[i])),
              ),
              onChanged: (v) => setState(() => chestPainType = v!),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- FASTING BLOOD SUGAR ----------
  Widget _buildFastingBloodSugarSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: const Text('Fasting Blood Sugar > 120 mg/dl'),
        value: fastingBloodSugar,
        onChanged: (v) => setState(() => fastingBloodSugar = v),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ---------- RESTING ECG ----------
  Widget _buildRestingECGSelector() {
    const ecgTypes = [
      'Normal',
      'ST-T Wave Abnormality',
      'Left Ventricular Hypertrophy'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resting ECG Results',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButtonFormField<int>(
              value: restingECG,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: List.generate(
                ecgTypes.length,
                (i) => DropdownMenuItem(value: i, child: Text(ecgTypes[i])),
              ),
              onChanged: (v) => setState(() => restingECG = v!),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- EXERCISE ANGINA ----------
  Widget _buildExerciseAnginaSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: const Text('Exercise Induced Angina'),
        value: exerciseAngina,
        onChanged: (v) => setState(() => exerciseAngina = v),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ---------- SLOPE SELECTOR ----------
  Widget _buildSlopeSelector() {
    const slopeTypes = [
      'Upsloping',
      'Flat',
      'Downsloping'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ST Segment Slope',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButtonFormField<int>(
              value: slope,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: List.generate(
                slopeTypes.length,
                (i) => DropdownMenuItem(value: i, child: Text(slopeTypes[i])),
              ),
              onChanged: (v) => setState(() => slope = v!),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- CA SELECTOR ----------
  Widget _buildCASelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Number of Major Vessels (0-4) colored by Fluoroscopy',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButtonFormField<int>(
              value: ca,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: List.generate(
                5,
                (i) => DropdownMenuItem(value: i, child: Text('$i vessels')),
              ),
              onChanged: (v) => setState(() => ca = v!),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- THAL SELECTOR ----------
  Widget _buildThalSelector() {
    const thalTypes = [
      'Normal',
      'Fixed Defect',
      'Reversible Defect',
      'Not Described'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thalassemia',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButtonFormField<int>(
              value: thal,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: List.generate(
                thalTypes.length,
                (i) => DropdownMenuItem(value: i, child: Text(thalTypes[i])),
              ),
              onChanged: (v) => setState(() => thal = v!),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- SUBMIT ----------
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final payload = {
      "age": int.parse(ageController.text),
      "sex": sex,
      "cp": chestPainType,
      "trestbps": int.parse(restingBpController.text),
      "chol": int.parse(cholesterolController.text),
      "fbs": fastingBloodSugar ? 1 : 0,
      "restecg": restingECG,
      "thalach": int.parse(maxHeartRateController.text),
      "exang": exerciseAngina ? 1 : 0,
      "oldpeak": double.parse(oldpeakController.text),
      "slope": slope,
      "ca": ca,
      "thal": thal,
    };

    try {
      final result = await ApiService.assessPatient(payload);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => loading = false);
  }
}
