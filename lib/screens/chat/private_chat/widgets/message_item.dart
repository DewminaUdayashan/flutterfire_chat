import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:flutter/material.dart';

import '../../../../models/message.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.outgoingMessage,
    required this.msg,
  });

  final bool outgoingMessage;
  final Message msg;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          outgoingMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(!outgoingMessage ? 50 : 0),
              topRight: Radius.circular(!outgoingMessage ? 50 : 0),
              topLeft: Radius.circular(outgoingMessage ? 50 : 0),
              bottomLeft: Radius.circular(outgoingMessage ? 50 : 0),
            ),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: outgoingMessage
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                textAlign: outgoingMessage ? TextAlign.right : TextAlign.left,
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                msg.sentAt.time,
                textAlign: outgoingMessage ? TextAlign.right : TextAlign.left,
                style: const TextStyle(fontSize: 10, color: Colors.black45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
