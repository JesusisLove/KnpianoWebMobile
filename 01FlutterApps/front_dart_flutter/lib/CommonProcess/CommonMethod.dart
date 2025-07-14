// ignore: file_names
class CommonMethod {
  // 根据日期字符串获取星期几
  static String getWeekday(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = parseServerDate(dateStr);
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

    /* 解释这里为什么要改成+0000
    非常非常重要的认识：Docker容器里的时间和Nas系统的时间是两个不同的系统时间，
    对于KnPiano工程来说，因为knpiano.jar是运行在docker容器里，所以，
    Knpiano里的代码取得日期是Docker容器的系统时间，而不是Nas的系统时间，
    这一点一定要明确切记切记

    正因为我把Docker容器的系统时间调整到新加坡的时间，又因为服务器设备也是在新加坡
    那么，TimeZone的时间差就为0，这就是为什么要改成+0000的原因。
    另外要说明的一点就是：Docker容器采用的不是GMT，而是UTC
    我的调查参考文档：https://www.notion.so/Nas-knpiano-jar-1eb1f881c50d800f8bc5ea706b2293f1
    */
    // String dateWithTimezone = "$dateString +0800";
    String dateWithTimezone = "$dateString +0000";

    try {
      return DateTime.parse(dateWithTimezone);
    } catch (e) {
      print("Error parsing date: $dateString, error: $e");
      return DateTime.now(); // 或其他错误处理方式
    }
  }
}
