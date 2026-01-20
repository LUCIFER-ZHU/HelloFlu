import 'package:flutter/material.dart';
import 'package:bezier_chart/bezier_chart.dart';
import '../config/colors.dart';

/// 图表组件
///
/// 使用bezier_chart库绘制折线图，显示COVID-19数据的趋势
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
      return Container(
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Text(
            '暂无数据',
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
    }

    // 获取数据的起始和结束日期
    final fromDate = timelineData.first['date'] as DateTime;
    final toDate = timelineData.last['date'] as DateTime;

    // 准备图表数据点
    final List<DataPoint<DateTime>> dataPoints = [];
    for (final item in timelineData) {
      dataPoints.add(
        DataPoint<DateTime>(
          value: (item['value'] as num).toDouble(),
          xAxis: item['date'] as DateTime,
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
          child: BezierChart(
            fromDate: fromDate,
            bezierChartScale: BezierChartScale.WEEKLY,
            toDate: toDate,
            selectedDate: toDate,
            series: [
              BezierLine(
                data: dataPoints,
                lineColor: graphColor,
                lineStrokeWidth: 4,
                pointColor: graphColor,
              ),
            ],
            config: BezierChartConfig(
              physics: BouncingScrollPhysics(),
              verticalIndicatorStrokeWidth: 3.0,
              verticalIndicatorColor: AppColors.white.withOpacity(0.15),
              showVerticalIndicator: true,
              verticalIndicatorFixedPosition: false,
              backgroundColor: AppColors.black,
              footerHeight: 30.0,
              displayYAxis: true,
              displayDataPointWhenNoLine: false,
              pinchZoom: true,
            ),
          ),
        ),
      ],
    );
  }
}
