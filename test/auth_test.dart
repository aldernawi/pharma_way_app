import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_way/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'Test Pharmacy',
        'email': 'test@pharmacy.com',
        'role': 'pharmacy_admin',
        'pharmacy_id': 10,
        'pharmaceutical_company_id': null,
        'fcm_token': 'abc123',
        'created_at': '2025-01-01T00:00:00.000000Z',
        'updated_at': '2025-01-02T00:00:00.000000Z',
        'pharmacy': null,
        'pharmaceutical_company': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Test Pharmacy');
      expect(user.email, 'test@pharmacy.com');
      expect(user.role, 'pharmacy_admin');
      expect(user.pharmacyId, 10);
      expect(user.pharmaceuticalCompanyId, isNull);
      expect(user.fcmToken, 'abc123');
      expect(user.isPharmacyAdmin, isTrue);
      expect(user.isSuperAdmin, isFalse);
      expect(user.isCompanyAdmin, isFalse);
    });

    test('fromJson handles string pharmacy_id via parseInt converter', () {
      final json = {
        'id': 2,
        'name': 'Company User',
        'email': 'admin@company.com',
        'role': 'company_admin',
        'pharmacy_id': '20',
        'pharmaceutical_company_id': 5,
      };

      final user = UserModel.fromJson(json);

      expect(user.pharmacyId, 20);
      expect(user.pharmaceuticalCompanyId, 5);
      expect(user.isCompanyAdmin, isTrue);
    });

    test('toJson produces correct map', () {
      final user = UserModel(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        role: 'pharmacy_admin',
        pharmacyId: 5,
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test');
      expect(json['email'], 'test@test.com');
      expect(json['role'], 'pharmacy_admin');
      expect(json['pharmacy_id'], 5);
    });
  });

  group('AuthResponse', () {
    test('fromJson parses successful login response', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
          'user': {
            'id': 1,
            'name': 'Test User',
            'email': 'test@test.com',
            'role': 'pharmacy_admin',
          },
        },
      };

      final response = AuthResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, 'Login successful');
      expect(response.data, isNotNull);
      expect(response.data!.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
      expect(response.data!.user.id, 1);
      expect(response.data!.user.name, 'Test User');
    });

    test('fromJson handles failed login response', () {
      final json = {
        'success': false,
        'message': 'Invalid credentials',
        'data': null,
      };

      final response = AuthResponse.fromJson(json);

      expect(response.success, isFalse);
      expect(response.message, 'Invalid credentials');
      expect(response.data, isNull);
    });
  });

  group('LoginRequest', () {
    test('toJson produces correct map', () {
      final request = LoginRequest(
        email: 'test@test.com',
        password: 'password123',
        fcmToken: 'token123',
      );

      final json = request.toJson();

      expect(json['email'], 'test@test.com');
      expect(json['password'], 'password123');
      expect(json['fcm_token'], 'token123');
    });
  });
}
