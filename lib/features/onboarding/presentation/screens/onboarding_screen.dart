import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/user_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step Data
  int _age = 25;
  Gender _gender = Gender.male;
  double _height = 175;
  double _weight = 70;
  FitnessGoal _goal = FitnessGoal.generalFitness;
  ExperienceLevel _level = ExperienceLevel.beginner;
  EquipmentAvailability _equipment = EquipmentAvailability.fullGym;

  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Save and finish
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final profile = UserProfile(
        id: user.uid,
        email: user.email ?? "",
        name: user.displayName ?? user.email?.split('@')[0] ?? "User",
        age: _age,
        gender: _gender,
        height: _height,
        weight: _weight,
        goal: _goal,
        experienceLevel: _level,
        equipment: _equipment,
      );

      final db = DatabaseService();
      await db.saveUserProfile(profile);

      if (mounted) {
        // Wait a bit to ensure Firestore has updated
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e")),
        );
      }
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Step ${_currentStep + 1} of 5",
            style: const TextStyle(fontSize: 14, color: AppTheme.textGrey)),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentStep = i),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildBasicInfoStep(),
          _buildMetricsStep(),
          _buildGoalStep(),
          _buildExperienceStep(),
          _buildEquipmentStep(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGold))
            : ElevatedButton(
                onPressed: _nextPage,
                child: Text(_currentStep == 4 ? "Get Started" : "Continue"),
              ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return _buildStepContainer(
      title: "Tell us about yourself",
      subtitle: "Your personal details help us personalize your plan.",
      child: Column(
        children: [
          _buildLabel("Age"),
          NumberSelection(
              value: _age, onChanged: (v) => setState(() => _age = v)),
          const SizedBox(height: 32),
          _buildLabel("Gender"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGenderCard(Gender.male, Icons.male),
              _buildGenderCard(Gender.female, Icons.female),
              _buildGenderCard(Gender.other, Icons.transgender),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsStep() {
    return _buildStepContainer(
      title: "Your Body Metrics",
      subtitle: "Used for BMI and progress estimation.",
      child: Column(
        children: [
          _buildLabel("Height (cm)"),
          Slider(
              value: _height,
              min: 100,
              max: 250,
              divisions: 150,
              label: _height.round().toString(),
              onChanged: (v) => setState(() => _height = v),
              activeColor: AppTheme.primaryGold),
          Text("${_height.round()} cm",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildLabel("Weight (kg)"),
          Slider(
              value: _weight,
              min: 30,
              max: 200,
              divisions: 170,
              label: _weight.round().toString(),
              onChanged: (v) => setState(() => _weight = v),
              activeColor: AppTheme.primaryGold),
          Text("${_weight.round()} kg",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Text(
              "BMI: ${(_weight / ((_height / 100) * (_height / 100))).toStringAsFixed(1)}",
              style: const TextStyle(color: AppTheme.primaryGold)),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return _buildStepContainer(
      title: "What represents your goal?",
      subtitle: "We'll tailor the workouts to your target.",
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildSelectableCard(
              FitnessGoal.fatLoss, "Fat Loss", Icons.local_fire_department),
          _buildSelectableCard(
              FitnessGoal.muscleGain, "Muscle Gain", Icons.fitness_center),
          _buildSelectableCard(FitnessGoal.strength, "Strength", Icons.bolt),
          _buildSelectableCard(
              FitnessGoal.generalFitness, "General", Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return _buildStepContainer(
      title: "Experience Level",
      subtitle: "How familiar are you with training?",
      child: Column(
        children: [
          _buildLevelCard(
              ExperienceLevel.beginner, "Beginner", "Just starting out"),
          _buildLevelCard(ExperienceLevel.intermediate, "Intermediate",
              "1-2 years experience"),
          _buildLevelCard(
              ExperienceLevel.advanced, "Advanced", "3+ years experience"),
        ],
      ),
    );
  }

  Widget _buildEquipmentStep() {
    return _buildStepContainer(
      title: "Available Equipment",
      subtitle: "So we know what exercises to suggest.",
      child: Column(
        children: [
          _buildEquipmentOption(EquipmentAvailability.bodyweight, "Bodyweight",
              "No equipment needed"),
          _buildEquipmentOption(EquipmentAvailability.dumbbells,
              "Dumbbells Only", "Limited weights"),
          _buildEquipmentOption(EquipmentAvailability.fullGym, "Full Gym",
              "Everything available"),
        ],
      ),
    );
  }

  // Helper UI methods
  Widget _buildStepContainer(
      {required String title,
      required String subtitle,
      required Widget child}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 32),
            child,
            const SizedBox(height: 24), // Bottom padding for scroll
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: AppTheme.textGrey, fontWeight: FontWeight.bold)));

  Widget _buildGenderCard(Gender g, IconData icon) {
    bool selected = _gender == g;
    return GestureDetector(
      onTap: () => setState(() => _gender = g),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGold : AppTheme.cardGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            Icon(icon, color: selected ? Colors.black : Colors.white, size: 32),
      ),
    );
  }

  Widget _buildSelectableCard(FitnessGoal g, String title, IconData icon) {
    bool selected = _goal == g;
    return GestureDetector(
      onTap: () => setState(() => _goal = g),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGold : AppTheme.cardGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.black : AppTheme.primaryGold,
                size: 40),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(ExperienceLevel l, String title, String sub) {
    bool selected = _level == l;
    return GestureDetector(
      onTap: () => setState(() => _level = l),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGold : AppTheme.cardGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text(sub,
                      style: TextStyle(
                          color:
                              selected ? Colors.black54 : AppTheme.textGrey)),
                ])),
            if (selected) const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentOption(
      EquipmentAvailability e, String title, String sub) {
    bool selected = _equipment == e;
    return GestureDetector(
      onTap: () => setState(() => _equipment = e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGold : AppTheme.cardGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text(sub,
                      style: TextStyle(
                          color:
                              selected ? Colors.black54 : AppTheme.textGrey)),
                ])),
            if (selected) const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

class NumberSelection extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const NumberSelection(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () => onChanged(value - 1),
            icon: const Icon(Icons.remove_circle_outline,
                size: 32, color: AppTheme.primaryGold)),
        const SizedBox(width: 24),
        Text(value.toString(),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
        const SizedBox(width: 24),
        IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_circle_outline,
                size: 32, color: AppTheme.primaryGold)),
      ],
    );
  }
}
