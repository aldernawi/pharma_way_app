import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_helper.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.profile);
      return ApiHelper.extractData(
        response.data,
        (json) => UserModel.fromJson(json),
      ) ?? UserModel.fromJson({});
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.profile,
        data: request.toJson(),
      );
      return ApiHelper.extractData(
        response.data,
        (json) => UserModel.fromJson(json),
      ) ?? UserModel.fromJson({});
    } catch (e) {
      rethrow;
    }
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? email;
  final String? currentPassword;
  final String? password;
  final String? passwordConfirmation;

  UpdateProfileRequest({
    this.name,
    this.email,
    this.currentPassword,
    this.password,
    this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (currentPassword != null) data['current_password'] = currentPassword;
    if (password != null) data['password'] = password;
    if (passwordConfirmation != null) data['password_confirmation'] = passwordConfirmation;
    return data;
  }
}
