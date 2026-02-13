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
    final isAdmin = role == 'admin';

    final message = ChatMessage(
      id: '',
      senderId: user?.uid ?? 'unknown',
      senderName: isAdmin ? 'Support Agent' : 'Customer',
      message: _controller.text.trim(),
      timestamp: DateTime.now(),
      isAdmin: isAdmin,
    );

    _deliveryService.sendMessage(widget.deliveryId, message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).userRole;
    final isAdmin = role == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(isAdmin ? "Chatting with Customer" : "Chatting with Support", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
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
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "Start a conversation about this order",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    // If I am admin, my messages (isAdmin=true) are 'me'
                    // If I am customer, my messages (isAdmin=false) are 'me'
                    final isMe = isAdmin ? msg.isAdmin : !msg.isAdmin;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              Text(
                                msg.senderName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isMe ? Colors.white70 : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              msg.message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(msg.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white60 : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: const Color(0xFFF0F2F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
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
