import 'package:VayToday/features/categories/domain/models/subcategory_model.dart';

class SubcategoriesMockData {
  const SubcategoriesMockData._();

  static const Map<String, List<SubcategoryModel>> subcategoriesByCategory = {
    'Медицина': [
      SubcategoryModel(
        title: 'Стоматологи',
        imageUrl:
            'https://images.unsplash.com/photo-1629909613654-28e377c37b09',
      ),
      SubcategoryModel(
        title: 'Клиники',
        imageUrl:
            'https://images.unsplash.com/photo-1538108149393-fbbd81895907',
      ),
      SubcategoryModel(
        title: 'Травматологи',
        imageUrl:
            'https://images.unsplash.com/photo-1584515933487-779824d29309',
      ),
      SubcategoryModel(
        title: 'Остеопаты',
        imageUrl:
            'https://images.unsplash.com/photo-1576091160550-2173dba999ef',
      ),
    ],

    'Строительство': [
      SubcategoryModel(
        title: 'Мастера',
        imageUrl:
            'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
      ),
      SubcategoryModel(
        title: 'Плитка',
        imageUrl:
            'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c',
      ),
      SubcategoryModel(
        title: 'Кирпичи',
        imageUrl: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e',
      ),
      SubcategoryModel(
        title: 'Ремонт',
        imageUrl:
            'https://images.unsplash.com/photo-1581094794329-c8112a89af12',
      ),
    ],

    'Питание': [
      SubcategoryModel(
        title: 'Рестораны',
        imageUrl:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
      ),
      SubcategoryModel(
        title: 'Кафе',
        imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24',
      ),
      SubcategoryModel(
        title: 'Фастфуд',
        imageUrl: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330',
      ),
      SubcategoryModel(
        title: 'Доставка еды',
        imageUrl:
            'https://images.unsplash.com/photo-1526367790999-0150786686a2',
      ),
    ],
  };

  static List<SubcategoryModel> getByCategory(String categoryTitle) {
    return subcategoriesByCategory[categoryTitle] ?? _defaultSubcategories;
  }

  static const List<SubcategoryModel> _defaultSubcategories = [
    SubcategoryModel(
      title: 'Подкатегория 1',
      imageUrl: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
    ),
    SubcategoryModel(
      title: 'Подкатегория 2',
      imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab',
    ),
    SubcategoryModel(
      title: 'Подкатегория 3',
      imageUrl: 'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
    ),
    SubcategoryModel(
      title: 'Подкатегория 4',
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c',
    ),
  ];
}
