import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(AronaApp());
}

class AronaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'アロナ助手',
      home: AronaHomePage(),
    );
  }
}

class AronaHomePage extends StatefulWidget {
  @override
  _AronaHomePageState createState() => _AronaHomePageState();
}

class _AronaHomePageState extends State<AronaHomePage> {
  String userInput = "";
  List<Map<String, String>> conversation = [];
  TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  Future<void> handleSend() async {
    if (userInput.isEmpty) return;

    setState(() {
      isLoading = true;
      conversation.add({"role": "user", "content": userInput}); // 加入使用者訊息
      aronaReply = "アロナが考え中...（アロナ思考中...）"; // 顯示正在思考
    });

    String apiKey = "sk-e95e3fd35f07492e8228ead26e78b706"; // 🔹 請換成你的 API Key
    String apiUrl = "https://api.deepseek.com/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [
            {"role": "system", "content": "你是アロナ，Blue Archive 的 AI 助手。"},
            {"role": "user", "content": userInput}
          ]
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          aronaReply = jsonResponse["choices"][0]["message"]["content"];
          conversation.add({"role": "assistant", "content": aronaReply}); // 加入アロナ回應
        });
      } else {
        setState(() {
          aronaReply = "エラーが発生しました。（發生錯誤）";
        });
      }
    } catch (e) {
      setState(() {
        aronaReply = "ネットワークエラー（網路錯誤）";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("アロナ助手"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 顯示對話紀錄
            Expanded(
              child: ListView.builder(
                itemCount: conversation.length,
                itemBuilder: (context, index) {
                  var message = conversation[index];
                  return ListTile(
                    title: Text(
                      message["content"] ?? "",
                      style: TextStyle(
                        fontWeight: message["role"] == "user" ? FontWeight.bold : FontWeight.normal,
                        color: message["role"] == "user" ? Colors.blue : Colors.black,
                      ),
                    ),
                    subtitle: message["role"] == "assistant" ? Text("アロナ的回應") : null,
                  );
                },
              ),
            ),

            // 輸入框
            TextField(
              controller: _controller,
              onChanged: (text) {
                userInput = text;
              },
              decoration: InputDecoration(
                labelText: "請輸入您想說的話",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : handleSend,
              child: isLoading ? CircularProgressIndicator() : Text("送出給アロナ"),
            ),
          ],
        ),
      ),
    );
  }
}
