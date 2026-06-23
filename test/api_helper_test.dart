import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_way/core/network/api_helper.dart';
import 'package:pharma_way/data/models/user_model.dart';

void main() {
  group('ApiHelper.extractList', () {
    test('extracts list from direct List response', () {
      final responseData = [
        {'id': 1, 'name': 'User 1', 'email': 'u1@test.com', 'role': 'pharmacy_admin'},
        {'id': 2, 'name': 'User 2', 'email': 'u2@test.com', 'role': 'pharmacy_admin'},
      ];

      final result = ApiHelper.extractList<UserModel>(
        responseData,
        (json) => UserModel.fromJson(json),
      );

      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[1].name, 'User 2');
    });

    test('extracts list from { "data": [...] } response', () {
      final responseData = {
        'data': [
          {'id': 1, 'name': 'User 1', 'email': 'u1@test.com', 'role': 'pharmacy_admin'},
        ],
      };

      final result = ApiHelper.extractList<UserModel>(
        responseData,
        (json) => UserModel.fromJson(json),
      );

      expect(result.length, 1);
      expect(result[0].id, 1);
    });

    test('extracts list from paginated { "data": { "data": [...] } } response', () {
      final responseData = {
        'data': {
          'data': [
            {'id': 1, 'name': 'User 1', 'email': 'u1@test.com', 'role': 'pharmacy_admin'},
            {'id': 2, 'name': 'User 2', 'email': 'u2@test.com', 'role': 'pharmacy_admin'},
            {'id': 3, 'name': 'User 3', 'email': 'u3@test.com', 'role': 'pharmacy_admin'},
          ],
        },
      };

      final result = ApiHelper.extractList<UserModel>(
        responseData,
        (json) => UserModel.fromJson(json),
      );

      expect(result.length, 3);
      expect(result[2].id, 3);
    });

    test('returns empty list for null or invalid data', () {
      final result = ApiHelper.extractList<UserModel>(
        null,
        (json) => UserModel.fromJson(json),
      );

      expect(result, isEmpty);
    });

    test('returns empty list for unexpected format', () {
      final result = ApiHelper.extractList<UserModel>(
        'unexpected string',
        (json) => UserModel.fromJson(json),
      );

      expect(result, isEmpty);
    });

    test('skips invalid items in list', () {
      final responseData = {
        'data': [
          {'id': 1, 'name': 'Valid', 'email': 'v@test.com', 'role': 'pharmacy_admin'},
          'not a map',
          {'id': 2, 'name': 'Also Valid', 'email': 'v2@test.com', 'role': 'pharmacy_admin'},
        ],
      };

      final result = ApiHelper.extractList<UserModel>(
        responseData,
        (json) => UserModel.fromJson(json),
      );

      expect(result.length, 2);
      expect(result[0].name, 'Valid');
      expect(result[1].name, 'Also Valid');
    });
  });

  group('ApiHelper.extractData', () {
    test('extracts single object from { "data": {...} } response', () {
      final responseData = {
        'data': {
          'id': 1,
          'name': 'Test User',
          'email': 'test@test.com',
          'role': 'pharmacy_admin',
        },
      };

      final result = ApiHelper.extractData<UserModel>(
        responseData,
        (json) => UserModel.fromJson(json),
      );

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.name, 'Test User');
    });

    test('extracts single object when response is the object itself', () {
      final responseData = {
        'id': 5,
        'name': 'Direct',
        'email': 'd@test.com',
        'role': 'company_admin',
      };

      final result = ApiHelper.extractData<UserModel>(
        responseData,
        (json) => UserModel.fromJson(json),
      );

      expect(result, isNotNull);
      expect(result!.id, 5);
      expect(result.isCompanyAdmin, isTrue);
    });

    test('returns null for invalid data', () {
      final result = ApiHelper.extractData<UserModel>(
        null,
        (json) => UserModel.fromJson(json),
      );

      expect(result, isNull);
    });

    test('returns null for string response', () {
      final result = ApiHelper.extractData<UserModel>(
        'just a string',
        (json) => UserModel.fromJson(json),
      );

      expect(result, isNull);
    });
  });
}
