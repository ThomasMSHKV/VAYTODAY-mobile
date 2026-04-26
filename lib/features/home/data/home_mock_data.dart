import 'package:VayToday/features/home/domain/models/home_category.dart';
import 'package:VayToday/features/home/domain/models/popular_company.dart';
import 'package:VayToday/features/home/domain/models/recommendation_item.dart';

class HomeMockData {
  static const List<HomeCategory> categories = [
    HomeCategory(
      title: 'Питание',
      imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce',
    ),
    HomeCategory(
      title: 'Свадьба',
      imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc',
    ),
    HomeCategory(
      title: 'Такси',
      imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957',
    ),
    HomeCategory(
      title: 'Внешность',
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9',
    ),
    HomeCategory(
      title: 'Строительство',
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85',
    ),
    HomeCategory(
      title: 'Одежда',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518',
    ),
    HomeCategory(
      title: 'Медицина',
      imageUrl: 'https://images.unsplash.com/photo-1584515933487-779824d29309',
    ),
    HomeCategory(
      title: 'Хоз услуги',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
    ),
    HomeCategory(
      title: 'Образование',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
    ),
    HomeCategory(
      title: 'Питание',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
    ),
    HomeCategory(
      title: 'Спорт',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
    ),
    HomeCategory(
      title: 'Мебель',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
    ),
  ];

  static const List<RecommendationItem> recommendations = [
    RecommendationItem(
      title: 'Гранд Палас ресторан',
      category: 'Кафе и рестораны',
      imageUrl: 'https://images.unsplash.com/photo-1511818966892-d7d671e672a2',
    ),
    RecommendationItem(
      title: 'Royal Wedding Hall',
      category: 'Свадьба',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552',
    ),
    RecommendationItem(
      title: 'Premium Build',
      category: 'Строительство',
      imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
    ),
    RecommendationItem(
      title: 'Beauty Line',
      category: 'Внешность',
      imageUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f',
    ),
  ];

  static const List<PopularCompany> popularCompanies = [
    PopularCompany(
      title: 'Viva premium',
      category: 'Кафе и рестораны',
      imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe',
      rating: 5.0,
    ),
    PopularCompany(
      title: 'Айна визажист',
      category: 'Парикмахерские',
      imageUrl: 'https://images.unsplash.com/photo-1487412912498-0447578fcca8',
      rating: 5.0,
    ),
    PopularCompany(
      title: 'Альфа суши',
      category: 'Кафе и рестораны',
      imageUrl: 'https://images.unsplash.com/photo-1553621042-f6e147245754',
      rating: 4.9,
    ),
    PopularCompany(
      title: 'Lux Dental',
      category: 'Медицина',
      imageUrl: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09',
      rating: 4.8,
    ),
  ];
}
