import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepSeek Demo',
      home: DeepSeekExample(),
    );
  }
}

class DeepSeekExample extends StatefulWidget {
  @override
  _DeepSeekExampleState createState() => _DeepSeekExampleState();
}

class _DeepSeekExampleState extends State<DeepSeekExample> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";

  Future<void> _sendToDeepSeek(String input) async {
    final url = Uri.parse("https://api.deepseek.com/chat/completions");
    final headers = {
      'Authorization': 'Bearer sk-e95e3fd35f07492e8228ead26e78b706',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "model": "deepseek-chat",
      "messages": [
        {
          "role": "system",
          "content": "你是《蔚藍檔案》的アロナ，是一位溫柔可愛的AI助手，使用日文回答，並附上繁體中文字幕。"
        },
        {
          "role": "user",
          "content": input
        }
      ]
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data["choices"][0]["message"]["content"];
      setState(() {
        _response = reply;
      });
    } else {
      setState(() {
        _response = "出錯啦：${response.statusCode}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DeepSeek 測試")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "輸入你要說的話"),
            ),
            ElevatedButton(
              onPressed: () => _sendToDeepSeek(_controller.text),
              child: Text("送出到 DeepSeek"),
            ),
            SizedBox(height: 20),
            Text("DeepSeek 回應："),
            Text(_response),
          ],
        ),
      ),
    );
  }
}
