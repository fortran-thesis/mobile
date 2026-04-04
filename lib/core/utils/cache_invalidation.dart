import 'dart:async';

enum InvalidationEntity {
  moldReport,
  moldCase,
  userProfile,
  notification,
}

enum InvalidationOperation {
  create,
  update,
  delete,
}

class CacheInvalidationEvent {
  final InvalidationEntity entity;
  final InvalidationOperation operation;
  final String? id;
  final String? relatedId;
  final DateTime occurredAt;

  const CacheInvalidationEvent({
    required this.entity,
    required this.operation,
    this.id,
    this.relatedId,
    required this.occurredAt,
  });
}

class CacheInvalidationHub {
  CacheInvalidationHub._();

  static final CacheInvalidationHub instance = CacheInvalidationHub._();

  final StreamController<CacheInvalidationEvent> _controller =
      StreamController<CacheInvalidationEvent>.broadcast();

  Stream<CacheInvalidationEvent> get stream => _controller.stream;

  void emit(CacheInvalidationEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  Future<void> dispose() async {
    if (_controller.isClosed) return;
    await _controller.close();
  }
}