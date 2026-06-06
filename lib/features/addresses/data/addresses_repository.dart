import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/addresses/domain/models/address_model.dart';

class AddressesRepository {
  static List<AddressModel>? _cachedAddresses;

  Future<List<AddressModel>> getAddresses() async {
    if (_cachedAddresses != null) {
      return _cachedAddresses!;
    }

    final response = await ApiClient.dio.get(
      'address',
      queryParameters: {'limit': 1000, 'offset': 0},
    );

    final results = response.data['results'] as List? ?? [];

    final addresses = results
        .whereType<Map<String, dynamic>>()
        .map(AddressModel.fromJson)
        .toList();

    _cachedAddresses = addresses;

    return addresses;
  }

  Future<AddressModel?> getAddressById(int? addressId) async {
    if (addressId == null) return null;

    final addresses = await getAddresses();

    for (final address in addresses) {
      if (address.id == addressId) {
        return address;
      }
    }

    return null;
  }
}
