// ignore: file_names
class CommonMethod {
  // 根据日期字符串获取星期几
  static String getWeekday(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      switch (date.weekday) {
        case 1:
          return '(Mon)';
        case 2:
          return '(Tue)';
        case 3:
          return '(Wed)';
        case 4:
          return '(Thu)';
        case 5:
          return '(Fri)';
        case 6:
          return '(Sat)';
        case 7:
          return '(Sun)';
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }

  // 可以在这里添加更多的公共方法
}
