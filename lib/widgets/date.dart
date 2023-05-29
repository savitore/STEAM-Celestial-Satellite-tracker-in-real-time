import 'package:intl/intl.dart';

String parseDateString(String value) {

  final date = DateFormat.yMMMMd('en_US');
  return date.format(DateTime.parse(value));

}

