import 'dart:async';

class TransactionsUpdatedEvent {
  const TransactionsUpdatedEvent();
}

class UsernameUpdatedEvent {
  const UsernameUpdatedEvent();
}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  EventBus._internal();
  factory EventBus() => _instance;

  final _transactionsUpdatedController =
      StreamController<TransactionsUpdatedEvent>.broadcast();
  final _usernameUpdatedController =
      StreamController<UsernameUpdatedEvent>.broadcast();

  Stream<TransactionsUpdatedEvent> get onTransactionsUpdated =>
      _transactionsUpdatedController.stream;
  Stream<UsernameUpdatedEvent> get onUsernameUpdated =>
      _usernameUpdatedController.stream;

  void notifyTransactionsUpdated() {
    _transactionsUpdatedController.add(const TransactionsUpdatedEvent());
  }

  void notifyUsernameUpdated() {
    _usernameUpdatedController.add(const UsernameUpdatedEvent());
  }

  void dispose() {
    _transactionsUpdatedController.close();
    _usernameUpdatedController.close();
  }
}
