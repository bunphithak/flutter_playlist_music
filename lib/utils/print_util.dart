import 'dart:convert';

void printFullJson(dynamic json, {String? description}) {
  const chunkSize = 800; // กำหนดขนาดของแต่ละบล็อก
  final jsonString = jsonEncode(json); // แปลง JSON เป็นสตริง
  print("----------------------Start $description ------------------------");
  for (var i = 0; i < jsonString.length; i += chunkSize) {
    print(jsonString.substring(i,
        i + chunkSize > jsonString.length ? jsonString.length : i + chunkSize));
  }
  print("----------------------End $description ------------------------");
}
