import 'package:flutter/material.dart';
import '../config/colors.dart';

/// 自定义侧边栏组件（Drawer）
///
/// 提供应用导航功能，允许用户在不同页面之间切换
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.black,
      child: ListView(
        // 重要：移除ListView的默认padding
        padding: EdgeInsets.zero,
        children: <Widget>[
          // 顶部区域 - 显示logo或标题
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 显示应用图标
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.white,
                  backgroundImage: const AssetImage('assets/logo.png'),
                ),
                SizedBox(height: 16),
                // 显示应用名称
                Text(
                  'COVID-19 Tracker',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 导航菜单项
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.cardBackground,
              child: Icon(
                Icons.home,
                color: AppColors.white,
              ),
            ),
            title: Text(
              '首页',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // 关闭侧边栏并导航到主页
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),

          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.cardBackground,
              child: Icon(
                Icons.bar_chart,
                color: AppColors.white,
              ),
            ),
            title: Text(
              '全球统计',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // 关闭侧边栏并导航到全球统计页
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/global-stats');
            },
          ),

          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.cardBackground,
              child: Icon(
                Icons.public,
                color: AppColors.white,
              ),
            ),
            title: Text(
              '受影响的国家',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // 关闭侧边栏并导航到国家列表页
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/countries');
            },
          ),

          Divider(
            color: AppColors.white.withValues(alpha: 0.3),
            thickness: 1,
          ),

          // 关于部分
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Icon(
                Icons.info,
                color: AppColors.white,
              ),
            ),
            title: Text(
              '关于',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // 关闭侧边栏
              Navigator.pop(context);
              // 显示关于对话框
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('关于本应用'),
                  content: Text(
                    '这是一个COVID-19疫情追踪应用\n\n'
                    '数据来源: disease.sh API\n'
                    '数据实时更新',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
