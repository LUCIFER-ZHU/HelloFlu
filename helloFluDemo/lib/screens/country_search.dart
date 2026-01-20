import 'package:flutter/material.dart';
import '../widgets/folding_cell.dart';
import '../config/colors.dart';
import '../models/covid_models.dart';

/// 国家搜索代理（SearchDelegate）
///
/// 提供搜索国家的功能
/// 支持实时搜索建议和结果显示
class CountrySearchDelegate extends SearchDelegate {
  /// 所有国家的数据列表
  final List<dynamic> countries;

  CountrySearchDelegate(this.countries);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      // 清空搜索框按钮
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // 返回按钮
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // 过滤匹配搜索结果
    final suggestionsList = countries
        .where((element) =>
            element['country']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

    return _buildSuggestionsList(context, suggestionsList);
  }

  @override
  String get searchFieldLabel => AppConstants.searchHint;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: AppColors.primary,
      textTheme: Theme.of(context).textTheme.apply(),
      scaffoldBackgroundColor: AppColors.black,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 过滤搜索建议（实时搜索）
    final suggestionsList = countries
        .where((element) =>
            element['country']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

    return _buildSuggestionsList(context, suggestionsList);
  }

  /// 构建搜索建议/结果列表
  Widget _buildSuggestionsList(
      BuildContext context, List<dynamic> suggestionsList) {
    if (suggestionsList.isEmpty) {
      return Center(
        child: Text(
          '未找到匹配的国家',
          style: TextStyle(color: AppColors.white),
        ),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(10),
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) {
        final countryData = suggestionsList[index] as Map<String, dynamic>;
        final countryStats = CountryStats.fromJson(countryData);

        return CountryFoldingCell(
          countryName: countryStats.country,
          flagUrl: countryStats.flag ?? '',
          totalCases: countryStats.cases.toString(),
          todayCases: countryStats.todayCases.toString(),
          totalDeaths: countryStats.deaths.toString(),
          todayDeaths: countryStats.todayDeaths.toString(),
          recovered: countryStats.recovered.toString(),
          critical: countryStats.critical.toString(),
          casesPerOneMillion: countryStats.casesPerOneMillion
              .toStringAsFixed(1),
        );
      },
    );
  }
}
