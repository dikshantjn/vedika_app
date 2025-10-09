import 'package:dio/dio.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/MensuralPredictor.dart';

class HerPhasesService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Response<dynamic>> addHerPhases(MensuralPredictor payload) async {
    final String url = ApiEndpoints.herPhases;
    return await _dio.post(url, data: payload.toJson());
  }
}



