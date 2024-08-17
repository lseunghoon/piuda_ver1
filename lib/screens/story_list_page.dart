import 'package:flutter/material.dart';
import 'package:piuda_ui/widgets/bottom_navigator.dart';

class StoryListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이야기책'),
        centerTitle: true,
        leading: Icon(Icons.notifications),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '나만의 이야기',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildTimeSlotButton(context, '시간대 1', true),
                  _buildTimeSlotButton(context, '시간대 2', false),
                  _buildTimeSlotButton(context, '시간대 3', false),
                ],
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.green,
                size: 40,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildTimeSlotButton(BuildContext context, String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.white,
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
          // 시간대 버튼 클릭 시의 동작 추가
        },
      ),
    );
  }
}