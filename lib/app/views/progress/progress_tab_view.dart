import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/progress_controller.dart';

class ProgressTabView extends StatelessWidget {
  const ProgressTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(ProgressController());
    
    return Obx(() {
      if (controller.isLoading.value && controller.allSessions.isEmpty) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      return _buildContent(context, controller);
    });
  }

  Widget _buildContent(BuildContext context, ProgressController controller) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        _showCalendarDialog(context, controller);
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Weekly Summary Cards
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Workouts',
                          '${controller.totalWorkouts.value}',
                          'Completed',
                          Icons.fitness_center,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Calories',
                          '${controller.totalCalories.value}',
                          'Burned',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                      ),
                    ],
                  )),

              const SizedBox(height: 16),

              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Minutes',
                          '${controller.totalMinutes.value}',
                          'Total Time',
                          Icons.timer,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Streak',
                          '${controller.currentStreak.value} Days',
                          'Keep Going!',
                          Icons.local_fire_department,
                          Colors.red,
                        ),
                      ),
                    ],
                  )),

              const SizedBox(height: 32),

              // Weekly Activity Chart
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 16),

              Obx(() => Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _buildBarChart(controller),
                  )),

              const SizedBox(height: 32),

              // Recent Workouts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Workouts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'View All',
                        'Show all workout history',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Workout History List
              Obx(() {
                if (controller.recentSessions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No workouts yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a workout to see your progress!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.recentSessions
                      .map((session) => _buildWorkoutHistoryItem(
                            session.workoutTitle,
                            controller.formatDuration(session.durationSeconds),
                            '${session.caloriesBurned} kcal',
                            controller.formatDate(session.createdAt),
                            _getWorkoutColor(session.workoutTitle),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ProgressController controller) {
    final maxY = controller.weeklyWorkouts.reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxY > 60 ? maxY + 10 : 60).toDouble();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(
                  days[value.toInt()],
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          7,
          (index) => _buildBarGroup(index, controller.weeklyWorkouts[index]),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistoryItem(
    String title,
    String duration,
    String calories,
    String date,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.fitness_center, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    calories,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getWorkoutColor(String title) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[title.hashCode % colors.length];
  }

  void _showCalendarDialog(BuildContext context, ProgressController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workout Calendar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: controller.selectedDate.value,
                    selectedDayPredicate: (day) {
                      return isSameDay(controller.selectedDate.value, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      controller.loadSessionsForDate(selectedDay);
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (controller.hasWorkoutOnDate(day)) {
                          return Positioned(
                            bottom: 1,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  )),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.selectedDateSessions.isEmpty) {
                  return Text(
                    'No workouts on this date',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.selectedDateSessions.length} workout(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.selectedDateSessions
                        .map((session) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.fitness_center,
                                  color: Colors.blue),
                              title: Text(session.workoutTitle),
                              subtitle: Text(
                                  '${controller.formatDuration(session.durationSeconds)} • ${session.caloriesBurned} kcal'),
                            ))
                        .toList(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
