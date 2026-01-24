import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/body_measurement.dart';
import '../../services/body_measurement_service.dart';

class BodyMeasurementTrendsScreen extends StatefulWidget {
  const BodyMeasurementTrendsScreen({super.key});

  @override
  State<BodyMeasurementTrendsScreen> createState() =>
      _BodyMeasurementTrendsScreenState();
}

class _BodyMeasurementTrendsScreenState
    extends State<BodyMeasurementTrendsScreen> {
  final _service = Get.find<BodyMeasurementService>();
  List<BodyMeasurement> history = [];
  String selectedMetric = 'Weight';
  bool isLoading = true;

  final metrics = [
    'Weight',
    'Chest',
    'Waist',
    'Hips',
    'Biceps',
    'Thighs',
    'Calves',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    history = await _service.loadHistory();
    setState(() => isLoading = false);
  }

  double? _getValue(BodyMeasurement measurement, String metric) {
    switch (metric) {
      case 'Weight':
        return measurement.weight;
      case 'Chest':
        return measurement.chest;
      case 'Waist':
        return measurement.waist;
      case 'Hips':
        return measurement.hips;
      case 'Biceps':
        return measurement.biceps;
      case 'Thighs':
        return measurement.thighs;
      case 'Calves':
        return measurement.calves;
      default:
        return null;
    }
  }

  String _getUnit(String metric) {
    return metric == 'Weight' ? 'kg' : 'cm';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        backgroundColor: isDark ? Colors.black : const Color(0xFF50C878),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMetricSelector(),
                  const SizedBox(height: 24),
                  _buildStatCards(),
                  const SizedBox(height: 24),
                  _buildChart(),
                  const SizedBox(height: 24),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No measurements yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add measurements to see your progress',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          final isSelected = metric == selectedMetric;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(metric),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => selectedMetric = metric);
                }
              },
              backgroundColor: Colors.grey[800],
              selectedColor: const Color(0xFF4A90E2),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards() {
    final values = history
        .map((m) => _getValue(m, selectedMetric))
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final latest = values.first;
    final oldest = values.last;
    final change = latest - oldest;
    final changePercent = (change / oldest * 100).abs();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current',
            latest.toStringAsFixed(1),
            _getUnit(selectedMetric),
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Change',
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
            _getUnit(selectedMetric),
            change < 0 ? Colors.green : Colors.orange,
            subtitle: '${changePercent.toStringAsFixed(1)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 14),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart() {
    final values = history
        .map((m) => _getValue(m, selectedMetric))
        .where((v) => v != null)
        .cast<double>()
        .toList()
        .reversed
        .toList();

    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range * 0.2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF4A90E2), size: 20),
              const SizedBox(width: 8),
              Text(
                '$selectedMetric Trend',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: range > 0 ? range / 4 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[700]!, strokeWidth: 0.5);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: values.length > 5 ? 2 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= history.length) {
                          return const SizedBox.shrink();
                        }
                        final date = history.reversed.toList()[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM d').format(date),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: range > 0 ? range / 4 : 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (values.length - 1).toDouble(),
                minY: minValue - padding,
                maxY: maxValue + padding,
                lineBarsData: [
                  LineChartBarData(
                    spots: values
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF50C878)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF4A90E2),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4A90E2).withOpacity(0.3),
                          const Color(0xFF4A90E2).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF4A90E2), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Measurement History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length > 10 ? 10 : history.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Colors.grey),
            itemBuilder: (context, index) {
              final measurement = history[index];
              final value = _getValue(measurement, selectedMetric);
              final previousValue = index < history.length - 1
                  ? _getValue(history[index + 1], selectedMetric)
                  : null;

              double? change;
              if (value != null && previousValue != null) {
                change = value - previousValue;
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF4A90E2).withOpacity(0.2),
                  child: Text(
                    DateFormat('d').format(measurement.date),
                    style: const TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  DateFormat('MMM d, yyyy').format(measurement.date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: value != null
                    ? Text(
                        '${value.toStringAsFixed(1)} ${_getUnit(selectedMetric)}',
                        style: TextStyle(color: Colors.grey[400]),
                      )
                    : Text(
                        'No data',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                trailing: change != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: change < 0
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: change < 0 ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
