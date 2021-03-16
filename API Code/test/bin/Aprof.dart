class Aprof {
  final String userId;
  final String name;
  final String dept;
  final String education;
  final String DoJ;

  Aprof({this.userId, this.name, this.dept, this.education, this.DoJ});

  factory Aprof.fromJson(Map<String, dynamic> json) {
    return Aprof(
        userId: json['userId'],
        name: json['name'],
        dept: json['dept'],
        education: json['education'],
        DoJ: json['DoJ']);
  }
}

class AprofList {
  final List<Aprof> list;

  AprofList({
    this.list,
  });

  factory AprofList.fromJson(List<dynamic> parsedJson) {
    var list = <Aprof>[];
    list = parsedJson.map((i) => Aprof.fromJson(i)).toList();

    return AprofList(
      list: list,
    );
  }
}
