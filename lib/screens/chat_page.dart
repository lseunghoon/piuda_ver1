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
  bool _isStoryButtonEnabled = false; // 자서전 만들기 버튼 활성화 상태를 관리
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

    // 녹음이 완료된 후, "답변을 기다리고 있습니다 . . ." 스낵바를 띄운다
    final waitingSnackBar = SnackBar(
      content: Text('답변을 기다리고 있습니다 . . .'),
      duration: Duration(days: 1), // 스낵바가 자동으로 사라지지 않도록 긴 시간 설정
    );
    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(waitingSnackBar);

    if (await File(_recordedFilePath).exists()) {
      print('File exists at $_recordedFilePath');

      // 녹음 파일을 업로드하고 STT 텍스트와 GPT 응답을 받아옴
      Map<String, String> response = await _uploadRecordingToFastAPI();
      String transcription = response['transcription']!;
      String gptResponse = response['gpt_response']!;

      // 메시지를 추가한 후 스낵바를 닫음
      _addMessage(transcription, true); // STT 결과를 사용자 메시지로 추가
      _addMessage(gptResponse, false); // GPT 답변을 추가

      snackBarController.close(); // 스낵바 닫기

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

      // 메시지가 추가되면 자서전 만들기 버튼을 활성화
      if (_conversationHistory[widget.imageId]!.isNotEmpty) {
        _isStoryButtonEnabled = true;
      }
    });

    // 메시지가 추가된 후 스크롤을 아래로 이동
    _scrollToBottom();
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

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _createStory() async {
    if (!_isStoryButtonEnabled) {
      _showSnackbar(context, '자서전을 만들기 전에 먼저 대화를 시작해주세요.');
      return; // 버튼이 비활성화 상태일 때는 스낵바를 띄우고 작동하지 않음
    }

    // 자서전 생성이 시작되면 버튼을 비활성화
    setState(() {
      _isStoryButtonEnabled = false;
    });

    // "자서전을 쓰고 있습니다 . . ." 스낵바를 띄운다
    final loadingSnackBar = SnackBar(
      content: Text('자서전을 쓰고 있습니다 . . .'),
      duration: Duration(days: 1), // 스낵바가 자동으로 사라지지 않도록 긴 시간 설정
    );
    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(loadingSnackBar);

    try {
      final result = await _storyService.makeStory(_conversationHistory[widget.imageId]!);
      print("Story creation result: $result");

      // 자서전 생성이 완료되면 기존 스낵바를 닫고 새로운 스낵바를 띄운다
      snackBarController.close(); // 기존 스낵바 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('자서전이 생성되었습니다!')),
      );
    } catch (e) {
      print("Failed to create story: $e");

      // 오류 발생 시 기존 스낵바를 닫고 오류 메시지를 띄운다
      snackBarController.close(); // 기존 스낵바 닫기
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
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 10), // 프로필 이미지와 상단 간격 조정
              Center(
                child: ClipOval(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // 원형으로 설정
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // ScrollController 추가
                  physics: AlwaysScrollableScrollPhysics(),
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: _isRecording ? _stopRecording : _startRecording,
                            child: Container(
                              padding: EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black,
                                    width: 1.0
                                ),
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
                        ],
                      ),
                      SizedBox(width: 40), // 두 버튼 사이의 간격 조절
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: _createStory, // 항상 호출 가능하지만 상태에 따라 다르게 반응
                            child: Container(
                              padding: EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black,
                                    width: 1.0
                                ),
                                color: _isStoryButtonEnabled ? Colors.orange : Colors.grey, // 활성화/비활성화 색상
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_messages.isEmpty) // 메시지가 없을 때만 표시
            Center(
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: Colors.black,
                          width: 1.0
                      )
                  ),
                  child: Column(
                    children: [
                      Text(
                        '< 알림 >',
                        style: TextStyle(color: Colors.black, fontSize: 24.0),
                        textAlign: TextAlign.center,),
                      SizedBox(height: 20),
                      Text(
                        '1. 녹음 버튼을 눌러 과거의 나와 대화를 시작합니다.',
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      Text(
                        '2. 목소리 복사를 위해 첫마디는 두세문장으로 길게 말씀해 주세요.',
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      Text(
                        '3. 자서전 만들기 버튼을 누르면 자서전이 생성됩니다.',
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )
              ),
            ),
        ],
      ),
    );
  }
}