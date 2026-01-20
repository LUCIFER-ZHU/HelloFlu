import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/folding_cell.dart';
import '../widgets/drawer.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../models/covid_models.dart';
import 'country_search.dart';

/// 国家列表页面（Country List Screen）
///
/// 显示所有受影响国家的COVID-19数据
/// 支持点击查看详情和搜索功能
class CountryListScreen extends StatelessWidget {
  const CountryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 侧边栏
      drawer: const AppDrawer(),

      // 应用栏
      appBar: AppBar(
        title: Text(AppConstants.titleCountryList),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        actions: <Widget>[
          // 搜索按钮
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // 先获取数据，然后打开搜索页面
              final dataJson = await ApiService.getAllCountriesData();
              final countries = jsonDecode(dataJson) as List<dynamic>;

              if (context.mounted) {
                showSearch(
                  context: context,
                  delegate: CountrySearchDelegate(countries));
              }
            },
          ),
        ],
      ),

      // 主体内容
      body: FutureBuilder<String>(
        future: ApiService.getAllCountriesData(),
        builder: (context, snapshot) {
          // 状态1：数据加载中
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // 状态2：发生错误
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppConstants.errorNetworkConnection,
                style: TextStyle(color: AppColors.errorText),
              ),
            );
          }

          // 状态3：数据加载成功
          final countriesData = jsonDecode(snapshot.data!) as List<dynamic>;

          // 如果没有数据
          if (countriesData.isEmpty) {
            return Center(
              child: Text(
                  '暂无国家数据',
                  style: TextStyle(color: AppColors.white),
                ));
          }

          // 构建国家列表
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(10),
            itemCount: countriesData.length,
            itemBuilder: (context, index) {
              final countryData = countriesData[index] as Map<String, dynamic>;
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
        },
      ),
    );
  }
}
