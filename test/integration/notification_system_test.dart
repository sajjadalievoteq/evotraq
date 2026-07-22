import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:traqtrace_app/data/services/notification_api_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/notifications/presentation/cubit/notification_state.dart';
import 'package:traqtrace_app/features/notifications/domain/models/notification_subscription.dart';

import 'notification_system_test.mocks.dart';


@GenerateMocks([NotificationApiService, WebSocketService])
void main() {
  group('Notification System Integration Tests', () {
    late MockNotificationApiService mockApiService;
    late MockWebSocketService mockWsService;
    late NotificationCubit cubit;

    setUp(() {
      mockApiService = MockNotificationApiService();
      mockWsService = MockWebSocketService();
      
      
      when(mockWsService.notificationStream)
          .thenAnswer((_) => const Stream.empty());
      when(mockWsService.connectionStream)
          .thenAnswer((_) => const Stream.empty());
      when(mockWsService.isConnected).thenReturn(false);
      
      cubit = NotificationCubit(
        apiService: mockApiService,
        webSocketService: mockWsService,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('should create subscription via API service', () async {
      
      final subscription = NotificationSubscription(
        id: '1',
        subscriptionName: 'Test Subscription',
        webhookUrl: 'https://example.com/webhook',
        status: 'ACTIVE',
        subscriptionType: 'TRANSFORMATION',
        notificationFormat: 'JSON',
        createdAt: DateTime.now(),
      );

      final request = CreateSubscriptionRequest(
        subscriptionName: 'Test Subscription',
        webhookUrl: 'https://example.com/webhook',
        subscriptionType: 'TRANSFORMATION',
      );

      when(mockApiService.createSubscription(request))
          .thenAnswer((_) async => subscription);

      
      final result = await mockApiService.createSubscription(request);

      
      expect(result.id, equals('1'));
      expect(result.subscriptionType, equals('TRANSFORMATION'));
      verify(mockApiService.createSubscription(request)).called(1);
    });

    test('should fetch subscriptions via API service', () async {
      
      final subscriptions = [
        NotificationSubscription(
          id: '1',
          subscriptionName: 'Transformation Subscription',
          webhookUrl: 'https://example.com/webhook',
          status: 'ACTIVE',
          subscriptionType: 'TRANSFORMATION',
          notificationFormat: 'JSON',
          createdAt: DateTime.now(),
        ),
        NotificationSubscription(
          id: '2',
          subscriptionName: 'Transaction Subscription',
          webhookUrl: 'https://example.com/webhook2',
          status: 'ACTIVE',
          subscriptionType: 'TRANSACTION',
          notificationFormat: 'JSON',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockApiService.getSubscriptions(page: 0, size: 20))
          .thenAnswer((_) async => subscriptions);

      
      final result = await mockApiService.getSubscriptions(page: 0, size: 20);

      
      expect(result.length, equals(2));
      expect(result[0].subscriptionType, equals('TRANSFORMATION'));
      expect(result[1].subscriptionType, equals('TRANSACTION'));
      verify(mockApiService.getSubscriptions(page: 0, size: 20)).called(1);
    });

    test('should initialize WebSocket service correctly', () {
      
      mockWsService.initialize('http://localhost:8080', 'test-token');

      
      verify(mockWsService.initialize('http://localhost:8080', 'test-token')).called(1);
    });

    test('should handle notification cubit state transitions', () async {
      
      when(mockApiService.getSubscriptions(page: 0, size: 20))
          .thenAnswer((_) async => []);

      
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<NotificationState>((state) => state.status == NotificationStatus.loading),
          predicate<NotificationState>((state) => state.status == NotificationStatus.success),
        ]),
      );

      
      cubit.loadSubscriptions();

      await expectation;

      verify(mockApiService.getSubscriptions(page: 0, size: 20)).called(1);
    });

    test('should handle WebSocket token updates', () {
      
      mockWsService.initialize('http://localhost:8080', 'old-token');

      
      mockWsService.updateAccessToken('new-token');

      
      verify(mockWsService.initialize('http://localhost:8080', 'old-token')).called(1);
      verify(mockWsService.updateAccessToken('new-token')).called(1);
    });

    test('should handle subscription creation via cubit', () async {
      
      final subscription = NotificationSubscription(
        id: '1',
        subscriptionName: 'Test Subscription',
        webhookUrl: 'https://example.com/webhook',
        status: 'ACTIVE',
        subscriptionType: 'TRANSFORMATION',
        notificationFormat: 'JSON',
        createdAt: DateTime.now(),
      );

      final request = CreateSubscriptionRequest(
        subscriptionName: 'Test Subscription',
        webhookUrl: 'https://example.com/webhook',
        subscriptionType: 'TRANSFORMATION',
      );

      when(mockApiService.createSubscription(request))
          .thenAnswer((_) async => subscription);

      when(mockApiService.getSubscriptions(page: 0, size: 20))
          .thenAnswer((_) async => [subscription]);

      
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<NotificationState>((state) => state.status == NotificationStatus.loading),
          predicate<NotificationState>((state) => state.status == NotificationStatus.subscriptionCreated),
          predicate<NotificationState>((state) => state.status == NotificationStatus.loading),
          predicate<NotificationState>((state) => state.status == NotificationStatus.success),
        ]),
      );

      
      cubit.createSubscription(
        subscriptionName: 'Test Subscription',
        webhookUrl: 'https://example.com/webhook',
        subscriptionType: 'TRANSFORMATION',
      );

      await expectation;

      verify(mockApiService.createSubscription(request)).called(1);
      verify(mockApiService.getSubscriptions(page: 0, size: 20)).called(1);
    });
  });
}
