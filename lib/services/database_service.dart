import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // MARK: User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    await _db
        .collection('users')
        .doc(profile.id)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  // MARK: Workouts
  Future<void> saveWorkout(String uid, Workout workout) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(workout.id)
        .set(workout.toMap());
  }

  Stream<List<Workout>> getWorkoutHistory(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Workout.fromMap(doc.data())).toList());
  }

  Future<void> updateWorkoutStatus(
      String uid, String workoutId, bool isCompleted) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(workoutId)
        .update({'isCompleted': isCompleted});
  }

  // MARK: Progress
  Future<void> updateStreak(String uid, int newStreak) async {
    await _db.collection('users').doc(uid).update({'streakCount': newStreak});
  }
}
