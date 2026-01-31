class Exercise {
  final String id;
  final String name;
  final String description;
  final List<String> targetMuscles;
  final int sets;
  final int reps;
  final String? timeBased; // e.g., "30s"
  final int restSeconds;
  final String? videoUrl;
  final List<String> tips;
  bool isCompleted;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.targetMuscles,
    required this.sets,
    required this.reps,
    this.timeBased,
    required this.restSeconds,
    this.videoUrl,
    required this.tips,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetMuscles': targetMuscles,
      'sets': sets,
      'reps': reps,
      'timeBased': timeBased,
      'restSeconds': restSeconds,
      'videoUrl': videoUrl,
      'tips': tips,
      'isCompleted': isCompleted,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      targetMuscles: List<String>.from(map['targetMuscles']),
      sets: map['sets'],
      reps: map['reps'],
      timeBased: map['timeBased'],
      restSeconds: map['restSeconds'],
      videoUrl: map['videoUrl'],
      tips: List<String>.from(map['tips']),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class Workout {
  final String id;
  final String name;
  final List<Exercise> exercises;
  final DateTime scheduledDate;
  final String difficulty; // Beginner, Intermediate, Advanced
  final String duration; // e.g., "45 mins"
  final List<String> targetMuscleGroups;
  bool isCompleted;

  Workout({
    required this.id,
    required this.name,
    required this.exercises,
    required this.scheduledDate,
    required this.difficulty,
    required this.duration,
    required this.targetMuscleGroups,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'difficulty': difficulty,
      'duration': duration,
      'targetMuscleGroups': targetMuscleGroups,
      'isCompleted': isCompleted,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      exercises:
          (map['exercises'] as List).map((e) => Exercise.fromMap(e)).toList(),
      scheduledDate: DateTime.parse(map['scheduledDate']),
      difficulty: map['difficulty'],
      duration: map['duration'],
      targetMuscleGroups: List<String>.from(map['targetMuscleGroups']),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
