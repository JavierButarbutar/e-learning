import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../models/mapel_model.dart';

class MapelService {

  Future<List<MapelModel>> getMapel(String token) async {

    final response = await http.get(
      Uri.parse(ApiEndpoint.mapel),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {

      final List list = data['data'];

      return list
          .map((e) => MapelModel.fromJson(e))
          .toList();
    }

    throw Exception(data['message']);
  }
}