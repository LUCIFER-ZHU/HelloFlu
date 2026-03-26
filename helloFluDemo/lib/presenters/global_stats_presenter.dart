/// 全球统计页展示数据转换器
///
/// 集中处理页面展示所需的格式化、容错与时间线转换逻辑，
/// 避免 Screen 承担过多数据加工责任。
class GlobalStatsPresenter {
  GlobalStatsPresenter._();

  /// 格式化大数字
  static String formatNumber(dynamic number) {
    if (number == null) return '0';
    final num numValue =
        number is num ? number : num.tryParse(number.toString()) ?? 0;

    if (numValue >= 1000000) {
      return '${(numValue / 1000000).toStringAsFixed(1)}M';
    } else if (numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(1)}K';
    }

    return numValue.toString();
  }

  /// 格式化更新时间
  static String formatUpdateTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final int intValue =
        timestamp is int ? timestamp : int.tryParse(timestamp.toString()) ?? 0;
    if (intValue <= 0) {
      return '';
    }

    final DateTime date = DateTime.fromMillisecondsSinceEpoch(intValue);
    return date.toString().substring(0, 19);
  }

  /// 提取历史时间线
  static Map<String, dynamic>? getTimeline(dynamic historicalData) {
    if (historicalData is! Map<String, dynamic>) {
      return null;
    }

    final dynamic timeline = historicalData['timeline'];
    if (timeline is! Map<String, dynamic> || timeline.isEmpty) {
      return null;
    }

    return timeline;
  }

  /// 转换时间线数据格式
  static List<Map<String, dynamic>> transformTimelineData(
    dynamic timelineData,
  ) {
    if (timelineData is! Map<String, dynamic> || timelineData.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
    timelineData.forEach((dynamic key, dynamic value) {
      final DateTime? parsedDate = _parseDate(key?.toString());
      final int? parsedValue = _parseValue(value);

      if (parsedDate == null || parsedValue == null) {
        return;
      }

      result.add(<String, dynamic>{
        'date': parsedDate,
        'value': parsedValue,
      });
    });

    result.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      return (a['date'] as DateTime).compareTo(b['date'] as DateTime);
    });

    return _sampleTimeline(result);
  }

  static DateTime? _parseDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }

    final List<String> dateParts = rawDate.split('/');
    if (dateParts.length != 3) {
      return null;
    }

    try {
      final int month = int.parse(dateParts[0]);
      final int day = int.parse(dateParts[1]);
      final int year = 2000 + int.parse(dateParts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  static int? _parseValue(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static List<Map<String, dynamic>> _sampleTimeline(
    List<Map<String, dynamic>> data,
  ) {
    const int maxDataPoints = 100;
    if (data.length <= maxDataPoints) {
      return data;
    }

    final double step = data.length / maxDataPoints;
    final List<Map<String, dynamic>> sampled = <Map<String, dynamic>>[];
    for (int i = 0; i < maxDataPoints; i++) {
      final int index = (i * step).floor();
      if (index < data.length) {
        sampled.add(data[index]);
      }
    }

    if (sampled.isEmpty || sampled.last != data.last) {
      sampled.add(data.last);
    }

    return sampled;
  }
}
