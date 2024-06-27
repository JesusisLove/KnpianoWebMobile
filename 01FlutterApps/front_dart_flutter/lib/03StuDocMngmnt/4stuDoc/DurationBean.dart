// ignore: file_names
class DurationBean {

  final int minutesPerLsn;

  DurationBean({required this.minutesPerLsn});

  factory DurationBean.fromString(String durationString) {
    return DurationBean(
      minutesPerLsn: int.parse(durationString),
    );
  }

  @override
  String toString() => 'DurationBean(minutesPerLsn: $minutesPerLsn)';

}