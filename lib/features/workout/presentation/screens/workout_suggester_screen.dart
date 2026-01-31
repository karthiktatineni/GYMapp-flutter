import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/workout_engine.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import '../../../../models/user_profile.dart';
import '../../../../models/workout.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutSuggesterScreen extends StatefulWidget {
  const WorkoutSuggesterScreen({super.key});

  @override
  State<WorkoutSuggesterScreen> createState() => _WorkoutSuggesterScreenState();
}

class _WorkoutSuggesterScreenState extends State<WorkoutSuggesterScreen> {
  int _selectedMinutes = 45;
  Workout? _suggestedWorkout;
  bool _isLoading = false;
  final DatabaseService _db = DatabaseService();

  void _generateWorkout(UserProfile user) async {
    setState(() => _isLoading = true);

    try {
      // Fetch history for better AI context
      final history = await _db.getWorkoutHistory(user.id).first;

      final workout = await WorkoutEngine.suggestWorkoutAI(
        user: user,
        history: history,
        availableMinutes: _selectedMinutes,
      );

      if (mounted) {
        setState(() {
          _suggestedWorkout = workout;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error generating workout: $e")),
        );
      }
    }
  }

  void _saveAndStart(String uid) async {
    if (_suggestedWorkout == null) return;
    await _db.saveWorkout(uid, _suggestedWorkout!);
    if (mounted) {
      Navigator.pushNamed(context, '/workout_detail',
          arguments: _suggestedWorkout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
          title: const Text("Workout Suggester"),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: FutureBuilder<UserProfile?>(
        future: user != null ? _db.getUserProfile(user.uid) : null,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final profile = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("How much time do you have?",
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      [20, 30, 45, 60].map((m) => _buildTimeOption(m)).toList(),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryGold))
                    : ElevatedButton(
                        onPressed: () => _generateWorkout(profile),
                        child: const Text("Generate AI Recommendation"),
                      ),
                const SizedBox(height: 32),
                if (_suggestedWorkout != null) _buildResultCard(user!.uid),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeOption(int minutes) {
    bool selected = _selectedMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _selectedMinutes = minutes),
      child: Container(
        width: 70,
        height: 50,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGold : AppTheme.cardGrey,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? null
              : Border.all(color: AppTheme.textGrey.withOpacity(0.3)),
        ),
        child: Center(
          child: Text("${minutes}m",
              style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildResultCard(String uid) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppTheme.cardGrey, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recommended For You",
              style: TextStyle(color: AppTheme.primaryGold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(_suggestedWorkout!.name,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInfoRow(
              Icons.timer, "Duration: ${_suggestedWorkout!.duration}"),
          _buildInfoRow(Icons.fitness_center,
              "Exercises: ${_suggestedWorkout!.exercises.length}"),
          _buildInfoRow(
              Icons.bolt, "Difficulty: ${_suggestedWorkout!.difficulty}"),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveAndStart(uid),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold),
              child: const Text("View & Start Plan"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textGrey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}
