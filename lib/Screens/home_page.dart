import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flora_app/Screens/MessagesScreen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DialogFlowtter dialogFlowtter; //instance of DialogFlowtter
  final TextEditingController _textController =
      TextEditingController(); //controller for text field

  List<Map<String, dynamic>> messages = []; //list of messages

  @override
  void initState() {
    DialogFlowtter.fromFile()
        .then((instance) {
          dialogFlowtter = instance;
        })
        .catchError((error) {
          print("Error: $error");
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flora App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: MessagesScreen(messages: messages)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.blue[800],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: () {
                      sendMessage(_textController.text);
                      _textController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //function to send message to DialogFlow
  sendMessage(String text) async {
    if (dialogFlowtter == null) {
      print("DialogFlowtter is null");
    } else {
      //add user message to the list
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
      });
      //send message to DialogFlow
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(text: TextInput(text: text)),
      );
      if (response.message != null) {
        //add response message to the list
        setState(() {
          addMessage(response.message!);
        });
      }
    }
  }

  //function to add message to the list
  addMessage(Message message, [bool isUserMessage = false]) {
    {
      //add message to the list
      messages.add({'message': message, 'isUserMessage': isUserMessage});
    }
  }
}
