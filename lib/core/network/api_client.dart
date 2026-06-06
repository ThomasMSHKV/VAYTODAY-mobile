import 'package:dio/dio.dart';

class ApiClient {
  const ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.vaytoday.ru/api/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'X-Api-Key': 'VsLRTUdG.nKbbnxEKjpIZHXaEx4qfVvVlQmhoF6re',
      },
    ),
  );
}
