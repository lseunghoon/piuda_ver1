import 'package:flutter/material.dart';
import 'package:piuda_ui/widgets/bottom_navigator.dart';
import 'package:provider/provider.dart';

class StoryListPage extends StatelessWidget {
  final List<String> ageRanges = [
    '나의 20대',
    '나의 30대',
    '나의 40대',
    '나의 50대',
    '나의 60대',
    '나의 70대',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedAgeRange = context.watch<SelectedAgeRangeProvider>().selectedAgeRange;

    return Scaffold(
      appBar: AppBar(
        title: Text('이야기책'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // 알림 페이지로 이동
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 기능 추가
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '김석희 님의 이야기',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: ageRanges.length,
                itemBuilder: (context, index) {
                  return _buildAgeRangeButton(
                    context,
                    ageRanges[index],
                    selectedAgeRange == ageRanges[index],
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.blue,
                size: 40,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildAgeRangeButton(
      BuildContext context, String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      height: MediaQuery.of(context).size.height * 0.13,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: ListTile(
        title: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        onTap: () {
          // 연령대 선택 시 프로바이더를 통해 상태 관리
          context.read<SelectedAgeRangeProvider>().setSelectedAgeRange(label);
          // 연령대별 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgeDetailPage(ageRange: label),
            ),
          );
        },
      ),
    );
  }
}

class SelectedAgeRangeProvider extends ChangeNotifier {
  String _selectedAgeRange = '나의 20대';

  String get selectedAgeRange => _selectedAgeRange;

  void setSelectedAgeRange(String ageRange) {
    _selectedAgeRange = ageRange;
    notifyListeners();
  }
}

class AgeDetailPage extends StatelessWidget {
  final String ageRange;

  AgeDetailPage({required this.ageRange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ageRange),
        centerTitle: true,
      ),
      body: Center(
        child: Text('$ageRange 이야기 페이지'),
      ),
    );
  }
}