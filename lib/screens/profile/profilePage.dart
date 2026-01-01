import 'package:flutter/material.dart';
import 'package:research_driven_time_scheduler_mobile_app/controllers/surveyController.dart';
import 'package:research_driven_time_scheduler_mobile_app/controllers/taskController.dart';
import 'package:research_driven_time_scheduler_mobile_app/screens/survey/surveyStartPage.dart';
import 'package:research_driven_time_scheduler_mobile_app/services/notificationService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SurveyFirstController _surveyController = SurveyFirstController();
  final TaskController _taskController = TaskController();
  final NotificationService _notificationService = NotificationService();

  String _personality = '';
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    final personality = await _surveyController.getPersonality();
    
    setState(() {
      _personality = personality?.personality ?? 'Unknown';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile Header
        _buildProfileHeader(),
        const SizedBox(height: 24),

        // Personality Section
        _buildPersonalitySection(),
        const SizedBox(height: 16),

        // Settings Section
        _buildSettingsSection(),
        const SizedBox(height: 16),

        // Actions Section
        _buildActionsSection(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Time Scheduler User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Managing time wisely',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalitySection() {
    final personalityInfo = _getPersonalityInfo(_personality);
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Personality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                personalityInfo['icon'] as IconData,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              personalityInfo['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(personalityInfo['description'] as String),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable task reminders'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              if (!value) {
                _notificationService.cancelAllNotifications();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme settings coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.blue),
            title: const Text('Retake Personality Test'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showRetakeDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.green),
            title: const Text('Export Data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.orange),
            title: const Text('Clear All Tasks'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showClearTasksDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.purple),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Reset App'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showResetDialog(),
          ),
        ],
      ),
    );
  }// Continuation of ProfilePage class...

  void _showRetakeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retake Personality Test'),
        content: const Text(
          'Are you sure you want to retake the personality test? This will help us better understand your procrastination style.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _surveyController.clearPersonality();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SurveyStartpage(),
                  ),
                );
              }
            },
            child: const Text('Retake'),
          ),
        ],
      ),
    );
  }

  void _showClearTasksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _taskController.clearAllTasks();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All tasks cleared!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Scheduler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            Text(
              'A research-driven time management app that helps you understand your procrastination patterns and manage your time more effectively.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text(
          'This will delete all your data including tasks and personality results. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _surveyController.clearAll();
              await _surveyController.clearPersonality();
              await _taskController.clearAllTasks();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SurveyStartpage(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPersonalityInfo(String personality) {
    switch (personality.toLowerCase()) {
      case 'mood':
        return {
          'title': 'Mood-Driven Procrastinator',
          'icon': Icons.favorite,
          'description': 'You need the right emotional state to start tasks',
        };
      case 'overwhelm':
        return {
          'title': 'Overwhelmed Procrastinator',
          'icon': Icons.psychology,
          'description': 'Large tasks feel mentally overwhelming to you',
        };
      case 'reward':
        return {
          'title': 'Reward-Seeking Procrastinator',
          'icon': Icons.emoji_events,
          'description': 'You prioritize immediate gratification',
        };
      case 'perfection':
        return {
          'title': 'Perfectionist Procrastinator',
          'icon': Icons.stars,
          'description': 'Fear of imperfection prevents you from starting',
        };
      case 'drifter':
        return {
          'title': 'Structure-Needing Procrastinator',
          'icon': Icons.compass_calibration,
          'description': 'You struggle with maintaining routines',
        };
      default:
        return {
          'title': 'Classic Procrastinator',
          'icon': Icons.access_time,
          'description': 'You work best under deadline pressure',
        };
    }
  }
}