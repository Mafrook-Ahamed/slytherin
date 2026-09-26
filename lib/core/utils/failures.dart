/// Failure types shared by every repository.
///
/// The mock layer already throws these so the UI exercises the exact same error
/// paths it will use against FastAPI later.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No connectivity / request timed out.
class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

/// The server responded with an error.
class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Requested resource does not exist.
class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'We could not find what you asked for.']);
}

/// The request was rejected because of bad input.
class ValidationFailure extends AppFailure {
  const ValidationFailure(this.fieldErrors, [super.message = 'Invalid request.']);

  final Map<String, String> fieldErrors;
}

/// The user is not signed in.
class UnauthorisedFailure extends AppFailure {
  const UnauthorisedFailure([super.message = 'Please sign in to continue.']);
}

/// A single place to turn any failure into a friendly, user facing sentence.
class FailureMessages {
  const FailureMessages._();

  static String humanise(Object error) {
    if (error is AppFailure) {
      if (error is NetworkFailure) {
        return 'No internet connection. Check your network and try again.';
      }
      if (error is NotFoundFailure) {
        return 'We could not find what you were looking for.';
      }
      if (error is UnauthorisedFailure) {
        return 'Your session expired. Please sign in again.';
      }
      if (error is ServerFailure) {
        return 'Something went wrong on our side. Please try again.';
      }
      if (error is ValidationFailure) {
        return 'Please review the highlighted fields and try again.';
      }
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }

  /// Default title used by the reusable error widget.
  static String title(Object error) {
    if (error is NetworkFailure) return 'No Internet Connection';
    if (error is NotFoundFailure) return 'Not Found';
    if (error is UnauthorisedFailure) return 'Session Expired';
    if (error is ServerFailure) return 'Something went wrong';
    if (error is ValidationFailure) return 'Check your details';
    return 'Something went wrong';
  }
}
