import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:piuda_ui/service/audio_service.dart';
import 'package:piuda_ui/service/story_service.dart'; // StoryService 임포트

class ChatPage extends StatefulWidget {
  final String imageUrl;
  final String imageId; // 이미지 ID 추가

  ChatPage({required this.imageUrl, required this.imageId});

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
  final StoryService _storyService = StoryService(); // StoryService 인스턴스 생성

  Map<String, List<Map<String, dynamic>>> _conversationHistory = {}; // 이미지별 대화 내역 저장

  List<Map<String, dynamic>> get _messages =>
      _conversationHistory[widget.imageId] ?? []; // 현재 이미지의 대화 내역 가져오기

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeRecorder();

    if (_conversationHistory[widget.imageId] == null) {
      _conversationHistory[widget.imageId] = []; // 새로운 이미지 ID에 대해 대화 내역 초기화
    }
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

      // 녹음 파일을 업로드하고 STT 텍스트와 GPT 응답을 받아옴
      Map<String, String> response = await _uploadRecordingToFastAPI();
      String transcription = response['transcription']!;
      String gptResponse = response['gpt_response']!;

      _addMessage(transcription, true); // STT 결과를 사용자 메시지로 추가
      _addMessage(gptResponse, false); // GPT 답변을 추가

      // GPT 답변 음성 재생
      if (response['response_voice'] != null && response['response_voice']!.isNotEmpty) {
        await _apiService.playResponseVoice(response['response_voice']!);
      }

      _scrollToBottom(); // 새 메시지가 추가된 후 스크롤을 아래로 이동
    } else {
      print('녹음 파일이 없습니다.');
    }
  }

  Future<Map<String, String>> _uploadRecordingToFastAPI() async {
    try {
      final File file = File(_recordedFilePath);

      final List<int> audioData = await file.readAsBytes();
      final String filename = file.uri.pathSegments.last;

      // 서버에 업로드 및 STT 변환 텍스트 반환
      Map<String, String> response = await _apiService.uploadAudio(audioData, filename);

      print('Recording uploaded to FastAPI with transcription: ${response['transcription']}');
      return response; // 서버에서 받은 맵 반환
    } catch (e) {
      print('Failed to upload recording: $e');
      return {
        'transcription': '오류가 발생했습니다.',
        'gpt_response': '오류가 발생했습니다.',
        'response_voice': ''
      };
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

  void _addMessage(String text, bool isUserMessage) {
    setState(() {
      _conversationHistory[widget.imageId]!.add({
        "text": text,
        "isUserMessage": isUserMessage,
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _createStory() async {
    try {
      final result = await _storyService.makeStory(_conversationHistory[widget.imageId]!);
      print("Story creation result: $result");

      // 여기에서 결과 처리 (예: 알림 표시 등)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('자서전이 생성되었습니다 !')),
      );
    } catch (e) {
      print("Failed to create story: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("자서전 생성에 실패했습니다")),
      );
    }
  }

  final ScrollController _scrollController = ScrollController(); // ScrollController 추가

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _scrollController.dispose(); // ScrollController 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('과거의 나와 대화하기'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20), // 프로필 이미지와 상단 간격 조정
          Center(
            child: ClipOval(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4, // 원하는 너비로 설정
                height: MediaQuery.of(context).size.width * 0.4, // 높이도 동일하게 설정하여 원형 유지
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl), // 전달받은 이미지 URL로 이미지 표시
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // ScrollController 추가
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isUserMessage']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: message['isUserMessage']
                          ? Color(0xFF0F1C43)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: message['isUserMessage']
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
              children: [
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF0F1C43),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
                SizedBox(width: 40), // 두 버튼 사이의 간격 조절
                GestureDetector(
                  onTap: _createStory, // 이야기 생성 메서드 호출
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}