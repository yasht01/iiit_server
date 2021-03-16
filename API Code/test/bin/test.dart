import 'dart:convert';
import 'package:http/http.dart' as http;
import 'server.dart' as server;
import 'Aprof.dart';

// Future<List<Map<String, dynamic>>>
Future<void> getAprof() async {
  final url = 'http://localhost:3000/listPage/Aprof';
  final response = await http.get(url);

  final jsonResponse = json.decode(response.body.toString());
  final dataList = AprofList.fromJson(jsonResponse['list']).list;
  print(dataList[0].name);
}

void main() async {
  await server.start();
  await getAprof();
  // print(data);
}
