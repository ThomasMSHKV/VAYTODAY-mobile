import 'package:VayToday/features/companies/domain/models/company_model.dart';

class CompaniesMockData {
  const CompaniesMockData._();

  static const List<CompanyModel> companies = [
    CompanyModel(
      title: 'MD. KRISTAL',
      description:
          'Пошив свадебных платьев. Индивидуальный пошив любой сложности',
      city: 'Назрань',
      imageUrl: 'https://images.unsplash.com/photo-1594552072238-b8a33785b261',
      rating: 4.0,
    ),
    CompanyModel(
      title: 'Айна визажист - бровист',
      description: 'Стилист-визажист. Архитектура бровей',
      city: 'Сунжа',
      imageUrl: 'https://images.unsplash.com/photo-1487412912498-0447578fcca8',
      rating: 5.0,
    ),
    CompanyModel(
      title: 'Atelier milanovias',
      description: 'Мастерская по пошиву свадебных платьев',
      city: 'Магас',
      imageUrl: 'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65',
      rating: 0.0,
    ),
    CompanyModel(
      title: 'Barbie Couture',
      description: 'Свадебные платья, аксессуары, приданное и многое другое',
      city: 'Магас',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552',
      rating: 0.0,
    ),
  ];
}
