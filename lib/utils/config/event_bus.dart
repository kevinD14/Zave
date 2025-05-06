import 'dart:async';

class TransactionsUpdatedEvent {
  const TransactionsUpdatedEvent();
}

class UsernameUpdatedEvent {
  const UsernameUpdatedEvent();
}

class CategoriesUpdatedEvent {
  const CategoriesUpdatedEvent();
}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  EventBus._internal();
  factory EventBus() => _instance;

  final _transactionsUpdatedController =
      StreamController<TransactionsUpdatedEvent>.broadcast();
  final _usernameUpdatedController =
      StreamController<UsernameUpdatedEvent>.broadcast();
  final _categoriesUpdatedController =
    StreamController<CategoriesUpdatedEvent>.broadcast();

  Stream<TransactionsUpdatedEvent> get onTransactionsUpdated =>
      _transactionsUpdatedController.stream;
  Stream<UsernameUpdatedEvent> get onUsernameUpdated =>
      _usernameUpdatedController.stream;
  Stream<CategoriesUpdatedEvent> get onCategoriesUpdated =>
    _categoriesUpdatedController.stream;

  void notifyTransactionsUpdated() {
    _transactionsUpdatedController.add(const TransactionsUpdatedEvent());
  }

  void notifyUsernameUpdated() {
    _usernameUpdatedController.add(const UsernameUpdatedEvent());
  }

  void notifyCategoriesUpdated() {
    _categoriesUpdatedController.add(const CategoriesUpdatedEvent());
  }

  void dispose() {
    _transactionsUpdatedController.close();
    _usernameUpdatedController.close();
    _categoriesUpdatedController.close();
  }
}
