




import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:traqtrace_app/data/services/notification_api_service.dart'
    as _i3;
import 'package:traqtrace_app/data/services/websocket_service.dart' as _i5;
import 'package:traqtrace_app/features/notifications/domain/models/notification_subscription.dart'
    as _i2;
import 'package:traqtrace_app/features/notifications/domain/models/realtime_notification.dart'
    as _i6;
















class _FakeNotificationSubscription_0 extends _i1.SmartFake
    implements _i2.NotificationSubscription {
  _FakeNotificationSubscription_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeNotificationStats_1 extends _i1.SmartFake
    implements _i2.NotificationStats {
  _FakeNotificationStats_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}




class MockNotificationApiService extends _i1.Mock
    implements _i3.NotificationApiService {
  MockNotificationApiService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<List<_i2.NotificationSubscription>> getSubscriptions({
    int? page = 0,
    int? size = 20,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getSubscriptions, [], {
              #page: page,
              #size: size,
            }),
            returnValue: _i4.Future<List<_i2.NotificationSubscription>>.value(
              <_i2.NotificationSubscription>[],
            ),
          )
          as _i4.Future<List<_i2.NotificationSubscription>>);

  @override
  _i4.Future<_i2.NotificationSubscription> createSubscription(
    _i2.CreateSubscriptionRequest? request,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#createSubscription, [request]),
            returnValue: _i4.Future<_i2.NotificationSubscription>.value(
              _FakeNotificationSubscription_0(
                this,
                Invocation.method(#createSubscription, [request]),
              ),
            ),
          )
          as _i4.Future<_i2.NotificationSubscription>);

  @override
  _i4.Future<_i2.NotificationSubscription> getSubscription(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#getSubscription, [id]),
            returnValue: _i4.Future<_i2.NotificationSubscription>.value(
              _FakeNotificationSubscription_0(
                this,
                Invocation.method(#getSubscription, [id]),
              ),
            ),
          )
          as _i4.Future<_i2.NotificationSubscription>);

  @override
  _i4.Future<_i2.NotificationSubscription> updateSubscription(
    String? id,
    _i2.CreateSubscriptionRequest? request,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updateSubscription, [id, request]),
            returnValue: _i4.Future<_i2.NotificationSubscription>.value(
              _FakeNotificationSubscription_0(
                this,
                Invocation.method(#updateSubscription, [id, request]),
              ),
            ),
          )
          as _i4.Future<_i2.NotificationSubscription>);

  @override
  _i4.Future<void> deleteSubscription(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#deleteSubscription, [id]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> pauseSubscription(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#pauseSubscription, [id]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> resumeSubscription(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#resumeSubscription, [id]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<List<_i2.WebhookNotification>> getWebhookHistory(
    String? subscriptionId, {
    int? page = 0,
    int? size = 20,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #getWebhookHistory,
              [subscriptionId],
              {#page: page, #size: size},
            ),
            returnValue: _i4.Future<List<_i2.WebhookNotification>>.value(
              <_i2.WebhookNotification>[],
            ),
          )
          as _i4.Future<List<_i2.WebhookNotification>>);

  @override
  _i4.Future<Map<String, dynamic>> testWebhook(String? webhookUrl) =>
      (super.noSuchMethod(
            Invocation.method(#testWebhook, [webhookUrl]),
            returnValue: _i4.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i4.Future<Map<String, dynamic>>);

  @override
  _i4.Future<Map<String, dynamic>> testEmail(String? emailAddress) =>
      (super.noSuchMethod(
            Invocation.method(#testEmail, [emailAddress]),
            returnValue: _i4.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i4.Future<Map<String, dynamic>>);

  @override
  _i4.Future<void> retryWebhook(String? notificationId) =>
      (super.noSuchMethod(
            Invocation.method(#retryWebhook, [notificationId]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<_i2.NotificationStats> getSubscriptionStats(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#getSubscriptionStats, [id]),
            returnValue: _i4.Future<_i2.NotificationStats>.value(
              _FakeNotificationStats_1(
                this,
                Invocation.method(#getSubscriptionStats, [id]),
              ),
            ),
          )
          as _i4.Future<_i2.NotificationStats>);

  @override
  _i4.Future<Map<String, dynamic>> getSystemStats() =>
      (super.noSuchMethod(
            Invocation.method(#getSystemStats, []),
            returnValue: _i4.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i4.Future<Map<String, dynamic>>);
}




class MockWebSocketService extends _i1.Mock implements _i5.WebSocketService {
  MockWebSocketService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Stream<_i6.RealtimeNotification> get notificationStream =>
      (super.noSuchMethod(
            Invocation.getter(#notificationStream),
            returnValue: _i4.Stream<_i6.RealtimeNotification>.empty(),
          )
          as _i4.Stream<_i6.RealtimeNotification>);

  @override
  _i4.Stream<bool> get connectionStream =>
      (super.noSuchMethod(
            Invocation.getter(#connectionStream),
            returnValue: _i4.Stream<bool>.empty(),
          )
          as _i4.Stream<bool>);

  @override
  bool get isConnected =>
      (super.noSuchMethod(Invocation.getter(#isConnected), returnValue: false)
          as bool);

  @override
  void initialize(String? baseUrl, String? accessToken) => super.noSuchMethod(
    Invocation.method(#initialize, [baseUrl, accessToken]),
    returnValueForMissingStub: null,
  );

  @override
  void connect() => super.noSuchMethod(
    Invocation.method(#connect, []),
    returnValueForMissingStub: null,
  );

  @override
  void disconnect() => super.noSuchMethod(
    Invocation.method(#disconnect, []),
    returnValueForMissingStub: null,
  );

  @override
  void subscribeToNotifications(String? subscriptionId) => super.noSuchMethod(
    Invocation.method(#subscribeToNotifications, [subscriptionId]),
    returnValueForMissingStub: null,
  );

  @override
  void updateAccessToken(String? newToken) => super.noSuchMethod(
    Invocation.method(#updateAccessToken, [newToken]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}
