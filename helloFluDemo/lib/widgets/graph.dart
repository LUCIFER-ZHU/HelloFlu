import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/colors.dart';

/// 图表组件
///
/// 使用fl_chart库绘制折线图，显示COVID-19数据的趋势
class CovidGraph extends StatelessWidget {
  /// 时间线数据列表
  /// 每个元素包含 {'date': DateTime, 'value': int}
  final List<Map<String, dynamic>> timelineData;

  /// 图表标题
  final String title;

  /// 图表颜色
  final Color graphColor;

  const CovidGraph({
    super.key,
    required this.timelineData,
    required this.title,
    this.graphColor = AppColors.casesGraph,
  });

  @override
  Widget build(BuildContext context) {
    // 如果没有数据，返回空容器
    if (timelineData.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Text(
            '暂无数据',
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
    }

    // 准备图表数据点
    final List<FlSpot> spots = [];
    for (int i = 0; i < timelineData.length; i++) {
      final item = timelineData[i];
      spots.add(
        FlSpot(
          i.toDouble(),
          (item['value'] as num).toDouble(),
        ),
      );
    }

    return Column(
      children: [
        // 图表标题
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.03,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        SizedBox(height: 8),

        // 图表主体
        Container(
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height / 2.5,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(spots),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _calculateBottomInterval(spots.length),
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < timelineData.length) {
                        final date = timelineData[value.toInt()]['date'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.month}/${date.day}',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _calculateInterval(spots),
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatValue(value),
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: _getMinY(spots),
              maxY: _getMaxY(spots),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [graphColor.withOpacity(0.8), graphColor],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: graphColor,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        graphColor.withOpacity(0.3),
                        graphColor.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: AppColors.black.withOpacity(0.8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      if (spot.x.toInt() >= 0 &&
                          spot.x.toInt() < timelineData.length) {
                        final date =
                            timelineData[spot.x.toInt()]['date'] as DateTime;
                        return LineTooltipItem(
                          '${date.year}/${date.month}/${date.day}\n${spot.y.toInt()}',
                          TextStyle(color: AppColors.white),
                        );
                      }
                      return null;
                    }).toList();
                    },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 计算Y轴刻度间隔
  double _calculateInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final values = spots.map((s) => s.y).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    if (range == 0) return 1;
    final intervals = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000];
    for (final interval in intervals) {
      if (range / interval < 10) return interval.toDouble();
    }
    return (range / 10).ceil().toDouble();
  }

  /// 计算底部X轴刻度间隔
  double _calculateBottomInterval(int dataLength) {
    if (dataLength <= 10) return 1;
    if (dataLength <= 30) return 5;
    if (dataLength <= 60) return 10;
    if (dataLength <= 120) return 15;
    return 30;
  }

  /// 获取Y轴最小值
  double _getMinY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    return spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.9;
  }

  /// 获取Y轴最大值
  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    return spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1;
  }

  /// 格式化数值显示
  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }
}
