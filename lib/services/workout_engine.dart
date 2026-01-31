import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../config/env_config.dart';

class WorkoutEngine {
  static Future<Workout> suggestWorkoutAI({
    required UserProfile user,
    required List<Workout> history,
    int availableMinutes = 45,
  }) async {
    if (!EnvConfig.isGeminiConfigured) {
      debugPrint("Gemini API key not configured");
      return suggestWorkoutFallback(
        user: user,
        workoutHistory: history,
        errorMessage: 'Gemini API key missing',
      );
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: EnvConfig.geminiApiKey,
      );

      String goalText = _getGoalText(user.goal);
      String levelText = _getLevelText(user.experienceLevel);
      String equipmentText = _getEquipmentText(user.equipment);
      String scheduleText = _getScheduleText(user.preferredSchedule);

      final prompt = """
You are an elite fitness coach.

IMPORTANT:
- Respond ONLY with valid JSON
- sets, reps, restSeconds MUST be numbers (not strings)

Generate a workout for ${user.name}:
Goal: $goalText
Fitness Level: $levelText
Equipment: $equipmentText
Split: $scheduleText
Metrics: ${user.weight}kg, ${user.height}cm, Age ${user.age}
History: ${history.isEmpty ? "New User" : "Completed ${history.length} sessions"}

Required Duration: $availableMinutes minutes.

JSON Format:
{
"name": "Creative Name",
"difficulty": "$levelText",
"duration": "$availableMinutes mins",
"targetMuscleGroups": ["Primary", "Secondary"],
"exercises": [
{
"id": "ex_1",
"name": "Exercise Name",
"description": "Steps",
"targetMuscles": ["Muscle"],
"sets": 3,
"reps": 12,
"restSeconds": 60,
"tips": ["Tip"]
}
]
}
""";

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw Exception("Empty AI response");
      }

      final cleanJson =
          text.replaceAll('```json', '').replaceAll('```', '').trim();

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      // ✅ SAFE TYPE FIX FOR EXERCISES
      if (data['exercises'] != null && data['exercises'] is List) {
        for (var ex in data['exercises']) {
          ex['sets'] = _safeInt(ex['sets'], 3);
          ex['reps'] = _safeInt(ex['reps'], 10);
          ex['restSeconds'] = _safeInt(ex['restSeconds'], 60);
        }
      }

      data['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      data['scheduledDate'] = DateTime.now().toIso8601String();
      data['isCompleted'] = false;

      return Workout.fromMap(data);
    } catch (e) {
      debugPrint("Gemini Error: $e. Falling back to rule-based engine.");
      return suggestWorkoutFallback(
        user: user,
        workoutHistory: history,
        errorMessage: e.toString(),
      );
    }
  }

  // ✅ SAFE INT PARSER (KEY FIX)
  static int _safeInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static String _getGoalText(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.fatLoss:
        return "Fat Loss";
      case FitnessGoal.muscleGain:
        return "Muscle Gain";
      case FitnessGoal.strength:
        return "Strength";
      case FitnessGoal.generalFitness:
        return "General Fitness";
    }
  }

  static String _getLevelText(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return "Beginner";
      case ExperienceLevel.intermediate:
        return "Intermediate";
      case ExperienceLevel.advanced:
        return "Advanced";
    }
  }

  static String _getEquipmentText(EquipmentAvailability equipment) {
    switch (equipment) {
      case EquipmentAvailability.bodyweight:
        return "Bodyweight Only";
      case EquipmentAvailability.dumbbells:
        return "Dumbbells Only";
      case EquipmentAvailability.fullGym:
        return "Full Gym";
    }
  }

  static String _getScheduleText(PreferredSchedule schedule) {
    switch (schedule) {
      case PreferredSchedule.pushPullLegs:
        return "Push Pull Legs";
      case PreferredSchedule.upperLower:
        return "Upper Lower";
      case PreferredSchedule.broSplit:
        return "Bro Split";
      case PreferredSchedule.fullBody:
        return "Full Body";
    }
  }

  static Workout suggestWorkoutFallback({
    required UserProfile user,
    required List<Workout> workoutHistory,
    String? errorMessage,
  }) {
    return Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: errorMessage != null
          ? "Fallback (Error Occurred)"
          : "Dynamic Session (Fallback)",
      exercises: [
        Exercise(
          id: "fb_1",
          name: errorMessage != null ? "Error Log" : "Sample Exercise",
          description: errorMessage ?? "Rule-based selection",
          targetMuscles: ["Full Body"],
          sets: 3,
          reps: 12,
          restSeconds: 60,
          tips: ["Keep moving"],
        ),
      ],
      scheduledDate: DateTime.now(),
      difficulty: "All Levels",
      duration: "45 mins",
      targetMuscleGroups: ["Active Recovery"],
    );
  }
}
