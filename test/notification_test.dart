import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_way/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('fromJson parses order notification with orderId in data', () {
      final json = {
        'id': 42,
        'type': 'order_created',
        'read_at': null,
        'created_at': '2025-06-23T10:00:00.000000Z',
        'data': {
          'title': 'طلب جديد',
          'body': 'تم إنشاء طلب جديد',
          'order_id': 15,
        },
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, '42');
      expect(notification.title, 'طلب جديد');
      expect(notification.body, 'تم إنشاء طلب جديد');
      expect(notification.type, 'order_created');
      expect(notification.isRead, isFalse);
      expect(notification.createdAt, '2025-06-23T10:00:00.000000Z');
      expect(notification.data, isNotNull);
      expect(notification.data!['order_id'], 15);
    });

    test('fromJson handles read notification', () {
      final json = {
        'id': 'notif-100',
        'type': 'general',
        'read_at': '2025-06-23T12:00:00.000000Z',
        'created_at': '2025-06-23T10:00:00.000000Z',
        'data': {
          'title': 'مرحبا',
          'body': 'أهلا بك',
        },
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, 'notif-100');
      expect(notification.isRead, isTrue);
    });

    test('fromJson handles missing data gracefully', () {
      final json = {
        'id': 1,
        'type': 'general',
        'read_at': null,
        'created_at': '',
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, '1');
      expect(notification.title, 'إشعار');
      expect(notification.body, '');
      expect(notification.data, isNull);
    });

    test('order_id can be extracted from notification data for navigation', () {
      final json = {
        'id': 1,
        'type': 'order_status_updated',
        'read_at': null,
        'created_at': '2025-06-23T10:00:00.000000Z',
        'data': {
          'title': 'تحديث حالة الطلب',
          'body': 'تم تحديث الطلب رقم 99',
          'order_id': 99,
        },
      };

      final notification = NotificationModel.fromJson(json);

      final orderId = notification.data?['order_id'];
      expect(orderId, isA<int>());
      expect(orderId, 99);
    });

    test('copyWith updates isRead correctly', () {
      final notification = NotificationModel(
        id: '1',
        title: 'Test',
        body: 'Body',
        type: 'general',
        isRead: false,
        createdAt: '2025-01-01',
      );

      final updated = notification.copyWith(isRead: true);

      expect(updated.isRead, isTrue);
      expect(updated.id, '1');
      expect(updated.title, 'Test');
    });
  });
}
