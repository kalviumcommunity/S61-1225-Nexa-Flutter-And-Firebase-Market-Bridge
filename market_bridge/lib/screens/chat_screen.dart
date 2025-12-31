import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String farmerName;
  const ChatScreen({Key? key, required this.farmerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $farmerName'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ChatBubble(
                    text: 'Hi, I am interested in your produce.',
                    isMe: false,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ChatBubble(
                    text: 'Hello! How can I help you?',
                    isMe: true,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2196F3)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  const ChatBubble({Key? key, required this.text, required this.isMe})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF2196F3).withOpacity(0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}
