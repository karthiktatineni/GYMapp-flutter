import 'package:uuid/uuid.dart';

enum Gender { male, female, other }
enum FitnessGoal { fatLoss, muscleGain, strength, generalFitness }
enum ExperienceLevel { beginner, intermediate, advanced }
enum EquipmentAvailability { bodyweight, dumbbells, fullGym }

class UserProfile {
  final String id;
  final String email;
  final String name;
  final int age;
  final Gender gender;
  final double height; // in cm
  final double weight; // in kg
  final FitnessGoal goal;
  final ExperienceLevel experienceLevel;
  final EquipmentAvailability equipment;
  final int streakCount;
  final double bmi;

  UserProfile({
    String? id,
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.goal,
    required this.experienceLevel,
    required this.equipment,
    this.streakCount = 0,
  })  : id = id ?? const Uuid().v4(),
        bmi = weight / ((height / 100) * (height / 100));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender.index,
      'height': height,
      'weight': weight,
      'goal': goal.index,
      'experienceLevel': experienceLevel.index,
      'equipment': equipment.index,
      'streakCount': streakCount,
      'bmi': bmi,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      age: map['age'],
      gender: Gender.values[map['gender']],
      height: map['height'],
      weight: map['weight'],
      goal: FitnessGoal.values[map['goal']],
      experienceLevel: ExperienceLevel.values[map['experienceLevel']],
      equipment: EquipmentAvailability.values[map['equipment']],
      streakCount: map['streakCount'] ?? 0,
    );
  }
}
