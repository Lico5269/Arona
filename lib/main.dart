import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(AronaAssistantApp());
}

class AronaAssistantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arona AI Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AronaHomePage(),
    );
  }
}

class AronaHomePage extends StatefulWidget {
  @override
  _AronaHomePageState createState() => _AronaHomePageState();
}

class _AronaHomePageState extends State<AronaHomePage> {
  String aronaReply = "アロナに質問してみて！（試著問問アロナ吧！）"; // 預設回應
  TextEditingController userInputController = TextEditingController();
  List<Map<String, String>> conversation = []; // 儲存對話紀錄

  // 送出使用者的問題並獲取 AI 回應
  Future<void> handleSend() async {
    String userMessage = userInputController.text;
    if (userMessage.isEmpty) return;

    setState(() {
      conversation.add({"role": "user", "content": userMessage});
      aronaReply = "アロナが考え中...（アロナ思考中...）"; // 顯示思考中
    });

    userInputController.clear(); // 清空輸入框

    try {
      var response = await http.post(
        Uri.parse("https://api.deepseek.com/v1/chat/completions"), // 你的 Deepseek API URL
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_DEEPSEEK_API_KEY", // 請替換成你的 API Key
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": conversation,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          aronaReply = jsonResponse["choices"][0]["message"]["content"];
          conversation.add({"role": "assistant", "content": aronaReply});
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('アロナ AI 助手')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: conversation.length,
                itemBuilder: (context, index) {
                  var message = conversation[index];
                  return ListTile(
                    title: Text(
                      message["content"] ?? "",
                      textAlign: message["role"] == "user"
                          ? TextAlign.right
                          : TextAlign.left,
                      style: TextStyle(
                        color: message["role"] == "user"
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              aronaReply,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: userInputController,
                    decoration: InputDecoration(hintText: "訊息..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: handleSend,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
