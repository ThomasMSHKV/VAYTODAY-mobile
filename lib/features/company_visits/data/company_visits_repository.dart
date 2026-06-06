import 'package:flutter/foundation.dart';
import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/company_visits/domain/models/company_visit_model.dart';

class CompanyVisitsRepository {
  Future<bool> recordCompanyVisit(int companyId, {int? userId}) async {
    try {
      await ApiClient.dio.post(
        'company-visits',
        data: _buildVisitPayload(companyId, userId: userId),
      );
      return true;
    } catch (e) {
      debugPrint('COMPANY VISIT POST ERROR: $e');
      return false;
    }
  }

  Future<bool> updateCompanyVisit(
    int visitId,
    int companyId, {
    int? userId,
  }) async {
    try {
      await ApiClient.dio.put(
        'company-visits/$visitId',
        data: _buildVisitPayload(companyId, userId: userId),
      );
      return true;
    } catch (e) {
      debugPrint('COMPANY VISIT PUT ERROR: $e');
      return false;
    }
  }

  Future<Map<int, int>> getCompanyVisitCounts() async {
    final visits = await _getCompanyVisits();
    final counts = <int, int>{};

    for (final visit in visits) {
      if (visit.companyId == 0) continue;
      counts[visit.companyId] = (counts[visit.companyId] ?? 0) + 1;
    }

    return counts;
  }

  Future<List<CompanyVisitModel>> _getCompanyVisits() async {
    const limit = 1000;
    var offset = 0;
    var totalCount = 0;
    final visits = <CompanyVisitModel>[];

    do {
      final response = await ApiClient.dio.get(
        'company-visits',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      totalCount = _parseInt(response.data['count']);
      final results = response.data['results'] as List? ?? [];

      visits.addAll(
        results
            .whereType<Map<String, dynamic>>()
            .map(CompanyVisitModel.fromJson),
      );

      offset += limit;
    } while (offset < totalCount);

    return visits;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> _buildVisitPayload(int companyId, {int? userId}) {
    final data = <String, dynamic>{
      'company': companyId,
      'ip_address': '0.0.0.0',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (userId != null) {
      data['user'] = userId;
    }

    return data;
  }
}
