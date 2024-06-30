import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/my_text_field.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String recieverUserEmail;
  final String recieverId;
  const ChatPage({super.key, required this.recieverId, required this.recieverUserEmail});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async{
    if(controller.text.isNotEmpty){
      await _chatService.sendMessage(widget.recieverId, controller.text);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recieverUserEmail),),
      body: Column(
        children: [
          Expanded(child: _buildMsgList()),
          _buildMsgInput(),
        ],
      ),
    );
  }

  Widget _buildMsgList(){
    return StreamBuilder(
      stream: _chatService.getMessages(_firebaseAuth.currentUser!.uid, widget.recieverId), 
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text('${snapshot.error}');
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Text('Loading..');
        }
        return ListView(
          children: snapshot.data!.docs.map((document)=>_buildMsgItem(document)).toList(),
        );
      }
    );
  }

  Widget _buildMsgItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)? Alignment.centerRight:Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(data['senderEmail']),
          ChatBubble(message: data['message']),
        ],
      ),
    );
  }

  Widget _buildMsgInput(){
    return Row(children: [
      Expanded(child: MyTextField(controller: controller, hintText: 'Enter Message', obscureText: false)),
      IconButton(onPressed: sendMessage, icon: const Icon(Icons.send))
    ],);
  }
}