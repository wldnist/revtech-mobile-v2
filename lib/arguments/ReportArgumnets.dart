import '../../traccar_gennissi.dart';

class ReportArguments {
  final int id;
  final String from;
  final String to;
  final String name;
  final Device device;
  ReportArguments(this.id, this.from, this.to, this.name, this.device);
}
