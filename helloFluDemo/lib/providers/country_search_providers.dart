import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'country_list_notifier.dart';

/// 当前国家列表搜索关键字
final StateProvider<String> countrySearchQueryProvider =
    StateProvider<String>((Ref ref) => '');

/// 基于原始国家列表和搜索关键字派生出的展示结果
final Provider<AsyncValue<List<dynamic>>> filteredCountriesProvider =
    Provider<AsyncValue<List<dynamic>>>((Ref ref) {
      final AsyncValue<List<dynamic>> countriesAsync = ref.watch(
        countriesProvider,
      );
      final String query = ref.watch(countrySearchQueryProvider);

      return countriesAsync.whenData((List<dynamic> countries) {
        final String trimmedQuery = query.trim().toLowerCase();
        if (trimmedQuery.isEmpty) {
          return countries;
        }

        return countries.where((dynamic country) {
          final Map<String, dynamic> countryMap =
              country as Map<String, dynamic>;
          final String countryName =
              countryMap['country']?.toString().toLowerCase() ?? '';
          return countryName.contains(trimmedQuery);
        }).toList();
      });
    });
