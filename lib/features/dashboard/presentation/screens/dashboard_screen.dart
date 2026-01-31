import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/user_profile.dart';
import '../../../../models/workout.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _db = DatabaseService();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    if (user == null)
      return const Scaffold(body: Center(child: Text("Not Logged In")));

    return Scaffold(
      body: FutureBuilder<UserProfile?>(
        future: _db.getUserProfile(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data!;

          return _currentIndex == 0
              ? _buildDashboardHome(profile)
              : _buildPlaceholderScreen(profile);
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboardHome(UserProfile profile) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(profile),
              const SizedBox(height: 32),
              _buildTodayWorkoutCard(context, profile),
              const SizedBox(height: 24),
              _buildWeeklySummary(profile),
              const SizedBox(height: 24),
              _buildStatsGrid(profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,",
                style: const TextStyle(color: AppTheme.textGrey)),
            Text(profile.name,
                style: GoogleFonts.outfit(
                    fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.cardGrey,
          child: Icon(Icons.person, color: AppTheme.primaryGold),
        ),
      ],
    );
  }

  Widget _buildTodayWorkoutCard(BuildContext context, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGold, AppTheme.secondaryGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("AI SUGGESTION",
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
              const Icon(FontAwesomeIcons.robot, color: Colors.black),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.goal == FitnessGoal.muscleGain
                ? "Hypertrophy Push"
                : "General Fitness Flow",
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text("Based on your ${profile.experienceLevel.name} experience",
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/suggester'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: AppTheme.primaryGold,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Get AI Plan"),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(UserProfile profile) {
    return StreamBuilder<List<Workout>>(
      stream: _db.getWorkoutHistory(profile.id),
      builder: (context, snapshot) {
        final workouts = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Activity",
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (workouts.isEmpty)
              const Text("No workouts yet. Start your journey!",
                  style: TextStyle(color: AppTheme.textGrey)),
            ...workouts.take(3).map((w) => ListTile(
                  leading: Icon(Icons.check_circle,
                      color: w.isCompleted
                          ? AppTheme.primaryGold
                          : AppTheme.cardGrey),
                  title: Text(w.name),
                  subtitle: Text("${w.duration} • ${w.difficulty}"),
                  trailing: Text(w.scheduledDate.toString().split(' ')[0]),
                )),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(UserProfile profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard("Streak", "${profile.streakCount} Days",
            Icons.local_fire_department, Colors.orange),
        _buildStatCard("Weight", "${profile.weight} kg", Icons.fitness_center,
            Colors.blue),
        _buildStatCard("BMI", profile.bmi.toStringAsFixed(1), Icons.show_chart,
            Colors.green),
        _buildStatCard("Goal", profile.goal.name, Icons.flag, Colors.pink),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.cardGrey, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(label,
                  style:
                      const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlaceholderScreen(UserProfile profile) {
    return Center(child: Text("Coming Soon for ${profile.name}"));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        if (i == 1) Navigator.pushNamed(context, '/suggester');
        if (i == 2) Navigator.pushNamed(context, '/progress');
        setState(() => _currentIndex = 0);
      },
      backgroundColor: AppTheme.backgroundBlack,
      selectedItemColor: AppTheme.primaryGold,
      unselectedItemColor: AppTheme.textGrey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Suggest"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Progress"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
