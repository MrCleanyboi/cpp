import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ShopService {
  String get baseUrl => '${ApiConfig.baseUrl}/api/shop';

  Future<List<dynamic>> getShopItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load shop items');
      }
    } catch (e) {
      print('Error getting shop items: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> purchaseItem(String userId, String itemId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'item_id': itemId,
        }),
      );
      
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['detail'] ?? 'Failed to purchase item');
      }
    } catch (e) {
      print('Error purchasing item: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> equipItem(String userId, String itemId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equip'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'item_id': itemId,
        }),
      );
      
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['detail'] ?? 'Failed to equip item');
      }
    } catch (e) {
      print('Error equipping item: $e');
      rethrow;
    }
  }
}
