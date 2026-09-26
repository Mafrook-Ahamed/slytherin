/// Form validation helpers shared by login, register and profile editing.
class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[\w.!#$%&*+/=?^`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Enter your full name';
    if (v.length > 60) return 'Name is too long';
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// 0.0 – 1.0 password strength, used by the register screen meter.
  static double passwordStrength(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 0;
    var score = 0;
    if (v.length >= 6) score += 0.25;
    if (v.length >= 10) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(v)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(v)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  static String passwordStrengthLabel(String? value) {
    final score = passwordStrength(value);
    if (score < 0.3) return 'Weak';
    if (score < 0.6) return 'Fair';
    if (score < 0.85) return 'Good';
    return 'Strong';
  }
}
