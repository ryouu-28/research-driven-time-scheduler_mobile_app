import 'package:flutter/material.dart';
import 'package:research_driven_time_scheduler_mobile_app/controllers/taskController.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/taskModel.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final TaskController _taskController = TaskController();
  bool _isLoading = true;
  
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  Map<String, int> _priorityStats = {};
  Map<String, int> _categoryStats = {};
  List<Task> _recentTasks = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    final allTasks = await _taskController.getAllTasks();
    final completed = await _taskController.getCompletedTasks();
    final priorityStats = await _taskController.getTaskCountByPriority();
    final categoryStats = await _taskController.getTaskCountByCategory();

    setState(() {
      _totalTasks = allTasks.length;
      _completedTasks = completed.length;
      _pendingTasks = _totalTasks - _completedTasks;
      _priorityStats = priorityStats;
      _categoryStats = categoryStats;
      _recentTasks = allTasks.take(5).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tasks',
                  _totalTasks.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  _completedTasks.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _pendingTasks.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completion',
                  '${_totalTasks > 0 ? ((_completedTasks / _totalTasks) * 100).toInt() : 0}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Priority Distribution
          _buildSectionTitle('Priority Distribution'),
          const SizedBox(height: 12),
          _buildPriorityChart(),
          const SizedBox(height: 24),

          // Category Distribution
          _buildSectionTitle('Category Distribution'),
          const SizedBox(height: 12),
          _buildCategoryList(),
          const SizedBox(height: 24),

          // Recent Activity
          _buildSectionTitle('Recent Tasks'),
          const SizedBox(height: 12),
          ..._recentTasks.map((task) => _buildRecentTaskCard(task)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPriorityChart() {
    final high = _priorityStats['high'] ?? 0;
    final medium = _priorityStats['medium'] ?? 0;
    final low = _priorityStats['low'] ?? 0;
    final total = high + medium + low;

    if (total == 0) {
      return _buildEmptyState('No priority data available');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPriorityBar('High Priority', high, total, Colors.red),
            const SizedBox(height: 12),
            _buildPriorityBar('Medium Priority', medium, total, Colors.orange),
            const SizedBox(height: 12),
            _buildPriorityBar('Low Priority', low, total, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text('$count tasks', style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    if (_categoryStats.isEmpty) {
      return _buildEmptyState('No category data available');
    }

    return Card(
      child: Column(
        children: _categoryStats.entries.map((entry) {
          final color = _getCategoryColor(entry.key);
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(entry.key),
                color: color,
              ),
            ),
            title: Text(
              entry.key.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${entry.value}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isCompleted ? Colors.green : Colors.grey,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${task.category} • ${task.priority}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: _getPriorityColor(task.priority),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.purple;
      case 'study':
        return Colors.orange;
      case 'health':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'study':
        return Icons.school;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.category;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}