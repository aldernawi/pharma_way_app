import '../../core/utils/storage_service.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  AuthRepositoryImpl(this._remoteDataSource, this._storageService);

  Future<UserModel> login(String email, String password) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );
      
      final response = await _remoteDataSource.login(request);
      
      if (response.success && response.data != null) {
        // Save token and user data
        await _storageService.saveToken(response.data!.token);
        await _storageService.saveUserData(response.data!.user.toJson());
        
        return response.data!.user;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> register(RegisterRequest request) async {
    try {
      final response = await _remoteDataSource.register(request);
      
      if (response.success && response.data != null) {
        // Save token and user data
        await _storageService.saveToken(response.data!.token);
        await _storageService.saveUserData(response.data!.user.toJson());
        
        return response.data!.user;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      await _storageService.clearAll();
    } catch (e) {
      // Even if API call fails, clear local data
      await _storageService.clearAll();
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await _storageService.getUserData();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  Future<UserModel> refreshProfile() async {
    try {
      final user = await _remoteDataSource.getProfile();
      await _storageService.saveUserData(user.toJson());
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final user = await _remoteDataSource.updateProfile(request);
      await _storageService.saveUserData(user.toJson());
      return user;
    } catch (e) {
      rethrow;
    }
  }
}
