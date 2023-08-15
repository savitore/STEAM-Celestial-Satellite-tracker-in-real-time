import 'package:intl/intl.dart';

String parseDateString(String value) {

  final date = DateFormat.yMMMMd('en_US');
  return date.format(DateTime.parse(value));

}

String parseDateHourString(String value) {

  final date = DateFormat.yMMMMd('en_US');
  final hour = DateFormat.jm();
  return '${date.format(DateTime.parse(value))} ${hour.format(DateTime.parse(value))}';

}