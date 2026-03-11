import 'package:flutter/material.dart';

enum MessagePanelType {
  error,
  warning,
  info
}

class MessagePanelWidget extends StatelessWidget {
  final String message;  
  final MessagePanelType type;  

  const MessagePanelWidget({
    super.key,
    required this.message,
    required this.type
  });

  @override
  Widget build(BuildContext context) {
    var borderColor = Colors.grey;
    var color = Colors.grey[50];

    switch (type) {
      case MessagePanelType.error:
        borderColor = Colors.red;
        color = Colors.red[50];
        break;
      case MessagePanelType.warning:
        borderColor = Colors.amber;
        color = Colors.amber[50];
        break;
      case MessagePanelType.info:
        borderColor = Colors.blue;
        color = Colors.blue[50];
        break;        
    }
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        message,
        style: TextStyle(color: borderColor),
      )
    );
  }

}