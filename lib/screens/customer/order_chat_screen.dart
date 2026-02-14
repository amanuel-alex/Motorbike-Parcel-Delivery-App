import 'package:flutter/material.dart';
import '../../core/models/chat_message.dart';
import '../../core/services/delivery_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OrderChatScreen extends StatefulWidget {
  final String deliveryId;
  final String title;

  const OrderChatScreen({super.key, required this.deliveryId, required this.title});

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final DeliveryService _deliveryService = DeliveryService();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final role = Provider.of<AuthProvider>(context, listen: false).userRole;

    String senderName = 'Unknown';
    if (role == 'admin') senderName = 'Support Agent';
    else if (role == 'rider') senderName = 'Rider';
    else senderName = 'Customer';

    final message = ChatMessage(
      id: '',
      senderId: user?.uid ?? 'unknown',
      senderName: senderName,
      message: _controller.text.trim(),
      timestamp: DateTime.now(),
      senderRole: role ?? 'customer',
    );

    _deliveryService.sendMessage(widget.deliveryId, message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final myRole = Provider.of<AuthProvider>(context).userRole;
    final myId = Provider.of<AuthProvider>(context).user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              myRole == 'admin' ? "Support Dashboard" : 
              myRole == 'rider' ? "Customer Support Chat" : "Support & Rider Chat", 
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.grey)
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _deliveryService.getChatMessages(widget.deliveryId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                          child: const Icon(Icons.chat_bubble_outline, size: 40, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text("No messages yet. Send a greeting!", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == myId;
                    
                    return _buildModernBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildModernBubble(ChatMessage msg, bool isMe) {
    Color bubbleColor;
    if (isMe) {
       bubbleColor = AppColors.primary;
    } else {
       // Different colors for different roles to distinguish who is speaking
       bubbleColor = msg.senderRole == 'admin' ? Colors.blueGrey[800]! : 
                    msg.senderRole == 'rider' ? Colors.blue[700]! : Colors.white;
    }

    final textColor = (isMe || msg.senderRole != 'customer') ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                "${msg.senderName} • ${msg.senderRole.toUpperCase()}",
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.message,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.3),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(msg.timestamp),
                      style: TextStyle(fontSize: 9, color: textColor.withOpacity(0.6)),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all, size: 12, color: textColor.withOpacity(0.6)),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, 
        right: 16, 
        top: 12, 
        bottom: MediaQuery.of(context).padding.bottom + 12
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type something...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
