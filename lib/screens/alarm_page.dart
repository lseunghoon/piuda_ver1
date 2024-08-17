import 'package:flutter/material.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Map<String, dynamic>> _alarms = [
    {'message': '안녕하세요, 오늘은 어떤 이야기를 말씀...', 'time': '19:53', 'expanded': false},
    {'message': '2년 전, 오늘 작성한 이야기를 들려드릴...', 'time': '20:32', 'expanded': false},
    {'message': '이주의 인기를 확인해보세요.', 'time': '18:21', 'expanded': false},
    {'message': '새로운 업데이트가 있습니다.', 'time': '15:45', 'expanded': false},
    {'message': '친구의 요청을 확인하세요.', 'time': '14:10', 'expanded': false},
  ];

  void _toggleExpand(int index) {
    setState(() {
      _alarms[index]['expanded'] = !(_alarms[index]['expanded'] ?? false);
    });
  }

  void _deleteAlarm(int index) {
    setState(() {
      _alarms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_alarms[index]['message']!),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteAlarm(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('알림이 삭제되었습니다.')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: GestureDetector(
                      onTap: () => _toggleExpand(index),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _alarms[index]['expanded'] == true
                                ? _alarms[index]['message'] // 확장 시 전체 메시지 표시
                                : _alarms[index]['message'].length > 30
                                ? _alarms[index]['message'].substring(0, 30) + '...'
                                : _alarms[index]['message'], // 축약 메시지 표시
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            _alarms[index]['time'],
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAlarm(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _alarms.clear();
                    });
                  },
                  child: Text(
                    '모두 삭제',
                    style: TextStyle(color: Colors.red, fontSize: 16),
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