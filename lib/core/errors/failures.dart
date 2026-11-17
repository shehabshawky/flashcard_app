abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}
