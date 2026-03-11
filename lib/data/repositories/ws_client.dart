import 'package:dio/dio.dart';

class WSClient {

  late Dio _httpClient;

  WSClient(String urlBasePath) {
    if (urlBasePath.trim().isEmpty) {
      throw Exception("urlBasePath can't empty or null");
    }

    BaseOptions options = BaseOptions(
      baseUrl: urlBasePath,
      connectTimeout: Duration(milliseconds: 5000),
    );
    _httpClient = Dio(options);
  } 

  void setAuthToken(String authToken) {

    if (_httpClient.options.headers.containsKey("Authorization")) {
      _httpClient.options.headers["Authorization"] = "Bearer $authToken";
    }
    else {
      _httpClient
        .options
        .headers
        .addAll(
          {
            "Authorization": "Bearer $authToken"
          });
    }
  }

  Future<dynamic> _request(String path, String method, Object? data, Map<String, dynamic>? queryParameters) async {
    try {
      var response = await _httpClient.request<dynamic>(
        path,
        data: data,
        options: Options(method: method),
        queryParameters: queryParameters
      );    

      return response.data;
    }
    on DioException catch(ex) {
      if (ex.response != null) {
        var error = ex.response?.data;
        throw error['MensagemErro'];
      }

      rethrow;
    }
    catch (ex) {
      rethrow;
    }    
  }

  Future<dynamic> put({required String path, Object? data, Map<String, dynamic>? queryParameters}) {
    return _request(path, 'PUT', data, queryParameters);
  }

  Future<dynamic> get({required String path, Object? data, Map<String, dynamic>? queryParameters}) {
    return _request(path, 'GET', data, queryParameters);
  }  

  Future<dynamic> post({required String path, Object? data, Map<String, dynamic>? queryParameters}) {
    return _request(path, 'POST', data, queryParameters);
  }  

  Future<dynamic> delete({required String path, Object? data, Map<String, dynamic>? queryParameters}) {
    return _request(path, 'DELETE', data, queryParameters);
  }  
}