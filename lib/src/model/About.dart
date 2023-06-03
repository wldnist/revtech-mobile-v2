class AboutModel extends Object {
  String? title;
  String? url;

  AboutModel(
    this.title,
    this.url,
  );

  AboutModel.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    url = json["url"];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
      };
}
