class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;
  ValidationException(this.errors) : super('Validation failed');

  @override
  String toString() {
    return errors.values
        .expand((e) => e is List ? e : [e.toString()])
        .join('\n');
  }
}

class RateLimitException extends ApiException {
  RateLimitException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
