import 'package:flutter/material.dart';
import 'package:piuda_ui/widgets/bottom_navigator.dart';

class PopularPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('인기 게시판', style: TextStyle(
            fontSize: 20
        )),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),

      body: ListView.builder(
        itemCount: 20, // Number of items
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 30, color: Colors.grey[700]),
            ),
            title: Text('제목'),
            subtitle: Text('내용 요약'),
            trailing: Text('${(index + 1) * 2}분 전'),
          );
        },
      ),

      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}