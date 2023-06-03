
class ReportEventArgument {
  final int eventId;
  final int positionId;
  final Map<String, dynamic> attributes;
  final String type;
  final String name;
  ReportEventArgument(
      this.eventId, this.positionId, this.attributes, this.type, this.name);
}
