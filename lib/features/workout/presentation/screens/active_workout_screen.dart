import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/workout.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _currentExerciseIndex = 0;
  int _secondsRemaining = 60;
  bool _isResting = false;
  Timer? _timer;
  late Workout _workout;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Workout) {
        _workout = args;
      } else {
        // Fallback or error handling
        _workout = Workout(
          id: 'error',
          name: 'Workout',
          exercises: [],
          scheduledDate: DateTime.now(),
          difficulty: 'N/A',
          duration: '0m',
          targetMuscleGroups: [],
        );
      }
      _initialized = true;
    }
  }

  void _startRest() {
    if (!mounted) return;
    final exercise = _workout.exercises[_currentExerciseIndex];
    setState(() {
      _isResting = true;
      _secondsRemaining = exercise.restSeconds;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _nextExercise();
      }
    });
  }

  void _nextExercise() async {
    if (!mounted) return;

    // Stop any running timer
    _timer?.cancel();

    if (_currentExerciseIndex < _workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _isResting = false;
      });
      // Save progress to DB so user can see where they are
      await _saveWorkoutProgress();
    } else {
      _finishWorkout();
    }
  }

  Future<void> _saveWorkoutProgress() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final db = DatabaseService();
    if (authService.user != null) {
      // Save the entire workout state to Firestore
      await db.saveWorkout(authService.user!.uid, _workout);
    }
  }

  void _finishWorkout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final db = DatabaseService();
    if (authService.user != null) {
      await db.updateWorkoutStatus(authService.user!.uid, _workout.id, true);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout Completed! Great job!")),
      );
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_workout.exercises.isEmpty) {
      return Scaffold(body: Center(child: Text("No exercises found")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_workout.name),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)),
        ],
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(
            child: _isResting ? _buildRestUI() : _buildExerciseUI(),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    double progress = (_currentExerciseIndex + 1) / _workout.exercises.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.cardGrey,
            color: AppTheme.primaryGold,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
              "Exercise ${_currentExerciseIndex + 1} of ${_workout.exercises.length}",
              style: const TextStyle(color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildExerciseUI() {
    final exercise = _workout.exercises[_currentExerciseIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardGrey,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
                child: Icon(Icons.fitness_center,
                    size: 64, color: AppTheme.primaryGold)),
          ),
          const SizedBox(height: 24),
          Text(exercise.name,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text("${exercise.sets} Sets x ${exercise.reps} Reps",
              style:
                  const TextStyle(color: AppTheme.primaryGold, fontSize: 18)),
          const SizedBox(height: 16),
          Text(exercise.description,
              style: const TextStyle(color: AppTheme.textWhite)),
          const SizedBox(height: 12),
          Text("Tips: ${exercise.tips.join('. ')}",
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRestUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("REST TIME",
              style: TextStyle(fontSize: 20, color: AppTheme.textGrey)),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _secondsRemaining /
                      (_workout.exercises[_currentExerciseIndex].restSeconds),
                  strokeWidth: 10,
                  color: AppTheme.primaryGold,
                  backgroundColor: AppTheme.cardGrey,
                ),
              ),
              Text("$_secondsRemaining",
                  style: const TextStyle(
                      fontSize: 64, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          TextButton(
              onPressed: () => setState(() => _secondsRemaining += 15),
              child: const Text("+15 SEC")),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () => _nextExercise(),
              icon: const Icon(Icons.skip_next, color: AppTheme.textGrey)),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isResting
                  ? () =>
                      _nextExercise() // Skip rest now correctly goes to next exercise
                  : _startRest,
              child: Text(_isResting ? "Skip Rest" : "Done with Exercise"),
            ),
          ),
        ],
      ),
    );
  }
}
