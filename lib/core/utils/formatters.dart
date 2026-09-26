/// Lightweight date / file-size formatting.
///
/// Implemented locally so the UI layer stays dependency free. The FastAPI layer
/// will send ISO-8601 strings which are parsed with [DateTime.parse].
class AppFormat {
  const AppFormat._();

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// `12 Mar 2026`
  static String date(DateTime value) {
    final d = value;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// `12 Mar`
  static String dayMonth(DateTime value) {
    final d = value;
    return '${d.day} ${_months[d.month - 1]}';
  }

  /// `Today`, `Yesterday`, `12 Mar 2026`
  static String relativeDate(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final target = DateTime(value.year, value.month, value.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return date(value);
  }

  /// `just now`, `12m ago`, `3h ago`, `2d ago`
  static String relativeTime(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(value);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(value);
  }

  /// `14:32`
  static String time(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// `1.8 MB`
  static String fileSize(int bytes) {
    if (bytes < 0) return '0 KB';
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  }

  /// `12 min read`
  static String readingTime(int minutes) => '$minutes min read';

  /// `1,240`
  static String count(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final isFromEnd = text.length - i;
      if (i > 0 && isFromEnd % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}
