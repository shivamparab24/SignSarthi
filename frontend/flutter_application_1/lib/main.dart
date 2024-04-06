import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
// import 'dart:io';

void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GesturePage(),
    );
  }
}

class GesturePage extends StatefulWidget {
  @override
  _GesturePageState createState() => _GesturePageState();
}

class _GesturePageState extends State<GesturePage> {
  TextEditingController _textEditingController = TextEditingController();
  String _displayText = '';
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isInitialized = false;

//   Future<void> saveFile(List<int> bytes, String savePath) async {
//   var file = File(savePath);
//   //await file.writeAsBytes(bytes);
//   await file.writeAsBytes(bytes, flush: true);
// }
  
  Future<void> _concatenateVideos() async {
    final String keywords = "Hello Word";
  

    //try {
      // final response = await http.get(Uri.parse('http://127.0.0.1:5000/'));
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/concatenate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'keywords': keywords,
        }),
      );

      if (response.statusCode == 200) {
        // Concatenated video received successfully
        // You can handle the downloaded file here
        // Assuming the server responds with the video fill
        // Handle the parsed data
        print(response.body);
        _initializeVideoPlayerFuture = _controller.initialize();
        isInitialized = true;
        _controller.play();

        // Save the video file locally
        print('Video file saved successfully!');
      } else {
        // Error handling
        print('Failed to concatenate videos: ${response}');
      }
    // } catch (e) {
    //   // Exception handling
    //   print('Exception while concatenating videos: $e');
    // }
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'http://127.0.0.1:5000/video',
    )..initialize().then((_) {
      setState(() {});
    });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gesture Display and Recorder'),
      ),
      body: Column(
        children: [
          Expanded(
            child: isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : CircularProgressIndicator(),
            ),
          GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // Update display text with gesture details
                  _displayText = 'Pan Update: ${details.localPosition}';
                });
              },
              child: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    _displayText,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Type something...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: _isListening ? Icon(Icons.stop) : Icon(Icons.mic),
                  onPressed: () {
                    // Toggle recording functionality
                    _concatenateVideos();
                    _toggleRecording();
                  },
                ),
              ],
            ),
          ),
        ]
           ),
  );
}

  void _toggleRecording() async {
    if (!_isListening) {
      bool micAvailable = await _speechToText.initialize();

      if (micAvailable) {
        setState(() {
          _isListening = true;
        });

        _speechToText.listen(
          listenFor: Duration(seconds: 20),
          onResult: (result) {
            setState(() {
              _textEditingController.text = result.recognizedWords;
              _isListening = false;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speechToText.stop();
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}