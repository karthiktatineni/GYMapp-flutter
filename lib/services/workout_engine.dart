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
    // Validate API key configuration
    if (!EnvConfig.isGeminiConfigured) {
      throw Exception(
        'Gemini API key not configured. Use --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: EnvConfig.geminiApiKey,
      );

      // Map raw data to AI-friendly text
      String goalText = _getGoalText(user.goal);
      String levelText = _getLevelText(user.experienceLevel);
      String equipmentText = _getEquipmentText(user.equipment);
      String scheduleText = _getScheduleText(user.preferredSchedule);

      final prompt = """
      System: You are an elite fitness coach. Respond ONLY with valid JSON.
      
      Generate a workout for ${user.name}:
      - Goal: $goalText
      - Fitness Level: $levelText
      - Equipment: $equipmentText
      - Preferred Split: $scheduleText
      - Metrics: ${user.weight}kg, ${user.height}cm, Age ${user.age}
      - History: ${history.isEmpty ? "New User" : "Completed ${history.length} sessions"}
      
      Required Duration: $availableMinutes minutes.
      
      Response JSON structure:
      {
        "name": "Creative Name",
        "difficulty": "$levelText",
        "duration": "$availableMinutes mins",
        "targetMuscleGroups": ["Primary", "Secondary"],
        "exercises": [
          {
            "id": "ex_1",
            "name": "Exercise Name",
            "description": "Clear steps",
            "targetMuscles": ["Muscle"],
            "sets": 3,
            "reps": 12,
            "restSeconds": 60,
            "tips": ["Tip 1"]
          }
        ]
      }
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null) throw Exception("Empty AI response");

      final cleanJson =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      data['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      data['scheduledDate'] = DateTime.now().toIso8601String();
      data['isCompleted'] = false;

      return Workout.fromMap(data);
    } catch (e) {
      // Use debugPrint which is stripped in release builds
      debugPrint("Gemini Error: $e. Falling back to rule-based engine.");
      return suggestWorkoutFallback(user: user, workoutHistory: history);
    }
  }

  static String _getGoalText(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.fatLoss:
        return "Fat Loss (Burn calories)";
      case FitnessGoal.muscleGain:
        return "Muscle Gain (Build muscle)";
      case FitnessGoal.strength:
        return "Strength (Heavy lifting)";
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
        return "Full Gym Setup";
    }
  }

  static String _getScheduleText(PreferredSchedule schedule) {
    switch (schedule) {
      case PreferredSchedule.pushPullLegs:
        return "Push / Pull / Legs Split";
      case PreferredSchedule.upperLower:
        return "Upper / Lower Split";
      case PreferredSchedule.broSplit:
        return "Body Part Split (Bro Split)";
      case PreferredSchedule.fullBody:
        return "Full Body Workout";
    }
  }

  static Workout suggestWorkoutFallback({
    required UserProfile user,
    required List<Workout> workoutHistory,
  }) {
    return Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "Dynamic Session (Fallback)",
      exercises: [
        Exercise(
          id: "fb_1",
          name: "Sample Exercise",
          description: "Rule-based selection",
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
