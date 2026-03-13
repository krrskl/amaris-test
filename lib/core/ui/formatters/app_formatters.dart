String formatCop(int amount) {
  final raw = amount.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < raw.length; index++) {
    final reverseIndex = raw.length - index;
    buffer.write(raw[index]);

    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }

  return 'COP $buffer';
}

String formatTimestamp(DateTime timestamp) {
  final day = _twoDigits(timestamp.day);
  final month = _twoDigits(timestamp.month);
  final hour = _twoDigits(timestamp.hour);
  final minute = _twoDigits(timestamp.minute);

  return '$day/$month/${timestamp.year} - $hour:$minute';
}

String _twoDigits(int value) {
  return value >= 10 ? '$value' : '0$value';
}
