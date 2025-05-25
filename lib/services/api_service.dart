import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clothing.dart';

class ApiService {
  final String _baseUrl =
      "https://tpm-api-tugas-872136705893.us-central1.run.app/api";

  Future<List<Clothing>> getAllClothes() async {
    final response = await http.get(Uri.parse('$_baseUrl/clothes'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 'Success' && responseData['data'] != null) {
        final List<dynamic> clothesJson = responseData['data'];
        return clothesJson.map((json) => Clothing.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load clothes');
      }
    } else {
      throw Exception(
        'Failed to load clothes - Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Clothing> getClothById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/clothes/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 'Success' && responseData['data'] != null) {
        return Clothing.fromJson(responseData['data']);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to load cloth details',
        );
      }
    } else if (response.statusCode == 404) {
      throw Exception('Clothing not found 👕');
    } else {
      throw Exception(
        'Failed to load cloth details - Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> addCloth(Clothing clothing) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/clothes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(clothing.toJson()),
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    if (response.statusCode == 201 && responseBody['status'] == 'Success') {
      return responseBody;
    } else {
      throw Exception(
        responseBody['message'] ??
            'Failed to add cloth. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> updateCloth(int id, Clothing clothing) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/clothes/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(clothing.toJson()),
    );
    final Map<String, dynamic> responseBody = json.decode(response.body);
    if (response.statusCode == 200 && responseBody['status'] == 'Success') {
      return responseBody;
    } else {
      throw Exception(
        responseBody['message'] ??
            'Failed to update cloth. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> deleteCloth(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/clothes/$id'));

    final Map<String, dynamic> responseBody = json.decode(response.body);
    if (response.statusCode == 200 && responseBody['status'] == 'Success') {
      return responseBody;
    } else if (response.statusCode == 404) {
      throw Exception('Clothing not found 👕');
    } else {
      throw Exception(
        responseBody['message'] ??
            'Failed to delete cloth. Status Code: ${response.statusCode}',
      );
    }
  }
}
