import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:piuda_ui/service/audio_service.dart';

class ChatPage extends StatefulWidget {
  final String imageUrl; // 이미지 URL을 전달받기 위한 변수 추가

  ChatPage({required this.imageUrl}); // 생성자에서 이미지 URL을 받아옴

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatPage> {
  late FlutterSoundRecorder _recorder;
  late FlutterSoundPlayer _player;
  late String _recordedFilePath;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isRecordingCompleted = false;
  final AudioService _apiService = AudioService();

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    Directory tempDir = await getTemporaryDirectory();
    _recordedFilePath = '${tempDir.path}/recording.aac';
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  Future<void> _startRecording() async {
    await _recorder.startRecorder(toFile: _recordedFilePath);
    setState(() {
      _isRecording = true;
      _isRecordingCompleted = false;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _isRecordingCompleted = true;
    });

    if (await File(_recordedFilePath).exists()) {
      print('File exists at $_recordedFilePath');
      await _uploadRecordingToFastAPI();
    } else {
      print('녹음 파일이 없습니다.');
    }
  }

  Future<void> _uploadRecordingToFastAPI() async {
    try {
      final File file = File(_recordedFilePath);

      final List<int> audioData = await file.readAsBytes();
      final String filename = file.uri.pathSegments.last;

      await _apiService.uploadAudio(audioData, filename);

      print('Recording uploaded to FastAPI with filename: $filename');
    } catch (e) {
      print('Failed to upload recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_isRecordingCompleted) {
      await _player.startPlayer(fromURI: _recordedFilePath, whenFinished: () {
        setState(() {
          _isPlaying = false;
        });
      });
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _stopPlayback() async {
    await _player.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('과거의 나와 대화하기'),
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl), // 전달받은 이미지 URL로 이미지 표시
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '안녕하세요! 오늘 하루 어떠셨나요?',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: _isPlaying ? _stopPlayback : _playRecording,
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: _isRecordingCompleted ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}