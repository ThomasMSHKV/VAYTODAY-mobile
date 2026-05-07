import 'package:VayToday/features/company_detail/domain/models/company_assortment_item.dart';
import 'package:VayToday/features/company_detail/domain/models/company_detail_model.dart';

class CompanyDetailMockData {
  const CompanyDetailMockData._();

  static const CompanyDetailModel company = CompanyDetailModel(
    title: 'Viva premium bakery & cafe',
    category: 'Кафе, рестораны',
    subcategory: 'Свежая выпечка',
    imageUrls: [
      'https://images.unsplash.com/photo-1565958011703-44f9829ba187',
      'https://images.unsplash.com/photo-1551024506-0bccd828d307',
      'https://images.unsplash.com/photo-1488477181946-6428a0291777',
      'https://images.unsplash.com/photo-1517433367423-c7e5b0f35086',
    ],
    rating: 5.0,
    reviewsCount: 3,
    workingTime: '9:00–21:00',
    organizationTitle: 'Кафе-пекарня VIVA',
    description:
        'Стандарты качества в VIVA бескомпромиссны и являются нашим конкурентным преимуществом. Тщательно отобранные, лучшие натуральные продукты и ручной труд профессиональных мастеров - вот гарантия производства продукта высокого качества. Сервис высокого качества VIVA это результат того, что мы ищем индивидуальный подход к каждому гостю.',
    address: 'Назрань, Магас',
    assortment: [
      CompanyAssortmentItem(
        title: 'Десерт VIVA premium',
        imageUrl:
            'https://images.unsplash.com/photo-1565958011703-44f9829ba187',
        subtitle: '140 г',
        price: '700 ₽',
      ),
      CompanyAssortmentItem(
        title: 'Сырный десерт',
        imageUrl: 'https://images.unsplash.com/photo-1551024506-0bcчёcd828d307',
        subtitle: '170 г',
        price: '500 ₽',
      ),
      CompanyAssortmentItem(
        title: 'Мороженое',
        imageUrl:
            'https://images.unsplash.com/photo-1488477181946-6428a0291777',
        subtitle: '200 г',
        price: '450 ₽',
      ),
    ],
  );
}
