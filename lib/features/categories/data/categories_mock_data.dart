import 'package:VayToday/features/home/data/home_mock_data.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

final class CategoriesMockData {
  const CategoriesMockData._();

  static List<HomeCategory> get categories =>
      HomeMockData.categories.cast<HomeCategory>();
}
