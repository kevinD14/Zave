import 'dart:async';

// Evento que indica que las transacciones han sido actualizadas.
class TransactionsUpdatedEvent {
  const TransactionsUpdatedEvent();
}

// Evento que indica que el nombre de usuario ha sido actualizado.
class UsernameUpdatedEvent {
  const UsernameUpdatedEvent();
}

// Evento que indica que las categorías han sido actualizadas.
class CategoriesUpdatedEvent {
  const CategoriesUpdatedEvent();
}

// EventBus implementa el patrón singleton para la gestión de eventos globales en la app.
// Permite emitir y escuchar eventos como cambios en transacciones, usuario o categorías.
class EventBus {
  // Instancia única del EventBus (Singleton).
  static final EventBus _instance = EventBus._internal();
  EventBus._internal();
  factory EventBus() => _instance;

  // Controladores de streams para cada tipo de evento.
  final _transactionsUpdatedController =
      StreamController<TransactionsUpdatedEvent>.broadcast();
  final _usernameUpdatedController =
      StreamController<UsernameUpdatedEvent>.broadcast();
  final _categoriesUpdatedController =
      StreamController<CategoriesUpdatedEvent>.broadcast();

  // Stream para escuchar cuando las transacciones cambian.
  Stream<TransactionsUpdatedEvent> get onTransactionsUpdated =>
      _transactionsUpdatedController.stream;

  // Stream para escuchar cuando el nombre de usuario cambia.
  Stream<UsernameUpdatedEvent> get onUsernameUpdated =>
      _usernameUpdatedController.stream;

  // Stream para escuchar cuando las categorías cambian.
  Stream<CategoriesUpdatedEvent> get onCategoriesUpdated =>
      _categoriesUpdatedController.stream;

  // Notifica a todos los listeners que las transacciones han cambiado.
  void notifyTransactionsUpdated() {
    _transactionsUpdatedController.add(const TransactionsUpdatedEvent());
  }

  // Notifica a todos los listeners que el nombre de usuario ha cambiado.
  void notifyUsernameUpdated() {
    _usernameUpdatedController.add(const UsernameUpdatedEvent());
  }

  // Notifica a todos los listeners que las categorías han cambiado.
  void notifyCategoriesUpdated() {
    _categoriesUpdatedController.add(const CategoriesUpdatedEvent());
  }

  // Libera los recursos de los controladores de streams.
  void dispose() {
    _transactionsUpdatedController.close();
    _usernameUpdatedController.close();
    _categoriesUpdatedController.close();
  }
}
