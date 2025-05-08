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

  // 统一时区的日期处理函数
  static DateTime parseServerDate(String dateString) {
    // 如果日期字符串为空，返回当前时间或null，取决于您的需求
    if (dateString.isEmpty) {
      return DateTime.now(); // 或者返回null
    }

    // 假设服务器发送的是GMT+8时间但没有时区标记
    // 添加+0800时区标记以明确这是新加坡时间
    String dateWithTimezone = "$dateString +0800";
    try {
      return DateTime.parse(dateWithTimezone);
    } catch (e) {
      print("Error parsing date: $dateString, error: $e");
      return DateTime.now(); // 或其他错误处理方式
    }
  }
}
