import 'package:intl/intl.dart';

extension IntExtension on int {
  String toCommaFormat() {
    final formatter = NumberFormat('#,###,###,###');
    return formatter.format(this);
  }
}
