import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell.dart';
import 'package:number_display/number_display.dart';
import '../config/colors.dart';
import '../config/constants.dart';

/// 折叠单元格组件
///
/// 用于在国家列表中展示国家详情
/// 点击可以展开查看更多统计数据
class CountryFoldingCell extends StatelessWidget {
  /// 国家名称
  final String countryName;

  /// 国旗图片URL
  final String flagUrl;

  /// 累计确诊病例
  final String totalCases;

  /// 今日新增病例
  final String todayCases;

  /// 累计死亡人数
  final String totalDeaths;

  /// 今日新增死亡
  final String todayDeaths;

  /// 累计康复人数
  final String recovered;

  /// 危重病例数
  final String critical;

  /// 每百万人口的病例数
  final String casesPerOneMillion;

  const CountryFoldingCell({
    super.key,
    required this.countryName,
    required this.flagUrl,
    required this.totalCases,
    required this.todayCases,
    required this.totalDeaths,
    required this.todayDeaths,
    required this.recovered,
    required this.critical,
    required this.casesPerOneMillion,
  });

  /// 格式化数字显示
  String _formatNumber(String number) {
    try {
      final display = createDisplay(length: AppConstants.numberDisplayLength);
      return display(int.parse(number));
    } catch (e) {
      return number;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 为每个单元格创建唯一的key
    final _foldingCellKey = GlobalKey<SimpleFoldingCellState>();

    return Container(
      color: AppColors.listContainer,
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(bottom: 10),
      child: SimpleFoldingCell(
        key: _foldingCellKey,
        // 折叠状态时显示的内容
        frontWidget: _buildFrontWidget(context, _foldingCellKey),

        // 展开时的上半部分内容
        innerTopWidget: _buildInnerTopWidget(),

        // 展开时的下半部分内容
        innerBottomWidget: _buildInnerBottomWidget(context, _foldingCellKey),

        cellSize: Size(
          MediaQuery.of(context).size.width,
          AppConstants.foldingCellHeight,
        ),
        padding: EdgeInsets.all(AppConstants.listItemSpacing),
        animationDuration: Duration(
          milliseconds: AppConstants.foldingAnimationDuration,
        ),
        borderRadius: 10,
      ),
    );
  }

  /// 构建折叠状态的前端widget
  Widget _buildFrontWidget(
    BuildContext context,
    GlobalKey<SimpleFoldingCellState> foldingCellKey,
  ) {
    return GestureDetector(
      onTap: () {
        // 点击时切换折叠/展开状态
        foldingCellKey.currentState?.toggleFold();
      },
      child: Container(
        color: AppColors.foldingCellFront,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // 国旗图片
            ClipOval(
              child: Image.network(
                flagUrl,
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.width * 0.15,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 图片加载失败时显示占位图标
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: MediaQuery.of(context).size.width * 0.15,
                    color: AppColors.white.withOpacity(0.3),
                    child: Icon(
                      Icons.flag,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 20.0),

            // 国家名称和确诊病例数
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    countryName,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "总病例: ${_formatNumber(totalCases)}",
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 展开指示箭头
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建展开时的上部分widget
  Widget _buildInnerTopWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      color: AppColors.cardBackground,
      child: Column(
        children: [
          // 国家名称
          Text(
            countryName,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.0),

          // 详细统计数据（两列布局）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 左列
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatText("今日病例", todayCases),
                  SizedBox(height: 8),
                  _buildStatText("死亡", totalDeaths),
                  SizedBox(height: 8),
                  _buildStatText("每百万人口", casesPerOneMillion),
                ],
              ),

              SizedBox(width: 20.0),

              // 右列
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatText("康复", recovered),
                  SizedBox(height: 8),
                  _buildStatText("今日死亡", todayDeaths),
                  SizedBox(height: 8),
                  _buildStatText("危重", critical),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计文本
  Widget _buildStatText(String label, String value) {
    return Text(
      "$label: ${_formatNumber(value)}",
      style: TextStyle(
        color: AppColors.white,
        fontSize: 16.0,
      ),
    );
  }

  /// 构建展开时的下部分widget（关闭按钮）
  Widget _buildInnerBottomWidget(
    BuildContext context,
    GlobalKey<SimpleFoldingCellState> foldingCellKey,
  ) {
    return Builder(
      builder: (context) {
        return Container(
          color: AppColors.cardBackground,
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text(
                      "总病例",
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatNumber(totalCases),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ])),
              ),
              // 关闭按钮
              TextButton(
                onPressed: () {
                  foldingCellKey.currentState?.toggleFold();
                },
                child: Text(
                  "关闭",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.black,
                  shape: StadiumBorder(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
