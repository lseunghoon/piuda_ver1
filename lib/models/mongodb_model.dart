// import 'package:mongo_dart/mongo_dart.dart';
//
// class MongoDBService {
//   static final MongoDBService _singleton = MongoDBService._internal();
//   late Db _db;
//   late DbCollection _usersCollection;
//
//   factory MongoDBService() {
//     return _singleton;
//   }
//
//   MongoDBService._internal();
//
//   Future<void> connect() async {
//     // MongoDB Atlas에서 복사한 Connection String 사용
//     _db = Db('mongodb+srv://prop30909:LAdDMTT8cYzPi2ws@cluster0.nlmrcsp.mongodb.net/imagedb?retryWrites=true&w=majority&appName=Cluster0');
//     await _db.open();
//     _usersCollection = _db.collection('users');
//   }
//
//   Future<void> insertUser(Map<String, dynamic> userData) async {
//     await _usersCollection.insert(userData);
//   }
//
//   Future<void> close() async {
//     await _db.close();
//   }
// }

import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/material.dart';

class MongoDBService {
  static final MongoDBService _singleton = MongoDBService._internal();
  late Db _db;
  late DbCollection _usersCollection;

  factory MongoDBService() {
    return _singleton;
  }

  MongoDBService._internal();

  Future<void> connect() async {
    // MongoDB Atlas에서 복사한 Connection String 사용
    _db = Db('mongodb+srv://prop30909:LAdDMTT8cYzPi2ws@cluster0.nlmrcsp.mongodb.net/imagedb?retryWrites=true&w=majority&appName=Cluster0');
    await _db.open();
    _usersCollection = _db.collection('users');
  }

  Future<void> insertUser(Map<String, dynamic> userData) async {
    await _usersCollection.insert(userData);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _usersCollection.find().toList();
  }

  Future<void> close() async {
    await _db.close();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final mongoDBService = MongoDBService();
  await mongoDBService.connect();

  // Fetch all users and print to terminal
  List<Map<String, dynamic>> users = await mongoDBService.getAllUsers();
  for (var user in users) {
    print(user);
  }

  await mongoDBService.close();
}