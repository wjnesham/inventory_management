import 'dart:async';
import 'dart:convert';
import 'package:pantryfox/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jaguar_orm/jaguar_orm.dart';

/// The adapter
SqfliteAdapter _userAdapter;

class UsersSqflite {
  UserBean bean;

  init() async {
    if (_userAdapter == null) {
      _userAdapter = new SqfliteAdapter(await getDatabasesPath() + "/persnickDB.db", version: 1);
      //_adapter.
    }
    if (bean == null) {
      try {
        await _userAdapter.connect();
      } catch (e) {
        print("Cannot connect to database");
        print(e.toString());
      }
      bean = new UserBean();
    }
    await bean.createTable();
  }

  close() async {
    await _userAdapter.close();
  }
}

class UserBean {
  /// Field DSL for id column
  final StrField id = new StrField(PantryUser.idName);

  /// Field DSL for email column
  final StrField email = new StrField(PantryUser.emailName);

  /// Field DSL for salt column
  final StrField salt = new StrField(PantryUser.saltName);

  /// Field DSL for password column
  final StrField password = new StrField(PantryUser.passwordName);

  /// Table name for the model this bean manages
  String get tableName => 'users_new';

//  Future createTable() {
//    final st = Sql
//        .create(tableName, ifNotExists: true)
//        .addStr('id', primary: true, length: 50)
//        .addStr('email', length: 50)
//        .addStr('salt', length: 100)
//        .addStr('password', length: 100);
//    return st.exec(_adapter);
//
//  }

  Future<Null> createTable() async {
    final st = new Create(tableName, ifNotExists: true);
    st
        .addPrimaryStr('uid')
        .addStr('email', isNullable: true, length: 50)
        .addStr('salt', isNullable: true, length: 100)
        .addStr('password', isNullable: true, length: 100);

    await _userAdapter.createTable(st);
  }

  /// Inserts a new user into table
  Future insert(PantryUser user) async {
    //Insert inserter = new Insert(tableName);

    //inserter.set(id, user.id);
//    inserter.set(email, user.email);
//    inserter.set(salt, user.salt);
//    inserter.set(password, user.password);

    final insert = Insert(tableName).setValues({
      PantryUser.emailName: user.email,
      PantryUser.passwordName: user.password,
      PantryUser.saltName: user.salt,
      PantryUser.idName: user.uid
    });

    return await insert.exec(_userAdapter); //_adapter.insert(inserter);
  }

  /// Find user by email
  Future<PantryUser> findUser(String email) async {
    Find updater = new Find(tableName);

    // Await this?
    updater.where(this.email.eq(email.toLowerCase()));
    // If not found, return null.
    Map map = await _userAdapter.findOne(updater); // Don't know about this.

    PantryUser user = new PantryUser();
    if (map == null || updater == null || email == null) {
      // User not found.
      print('User not found!');
      user.password = "NULL";
      return user;
    }

    user.uid = map[PantryUser.idName]; // Unset?
    user.email = email;
    user.salt = map[PantryUser.saltName];
    user.password = map[PantryUser.passwordName]; // Entered in login screen.
//    print (user.password);

    return user; // User not found.
  }

//  String hashToString(String pass, String salt) {
////    String hashString = "";
////    for (int x in hash) {
////      hashString += x.toString();
////    }
//    return (pass+salt).hashCode.toString();
//  }

  /// Updates a user's password and salt by id
  Future<int> update(String id, String salt, String password) async {
    Update updater = new Update(tableName);
    updater.where(this.id.eq(id));

    updater.set(this.salt, salt);
    updater.set(this.password, password);

    return await _userAdapter.update(updater);
  }

  /// Finds one post by [id]
  Future<PantryUser> findOne(String id) async {
    Find updater = new Find(tableName);

    updater.where(this.id.eq(id));

    Map map = await _userAdapter.findOne(updater);

    PantryUser user = new PantryUser();
    user.uid = map['uid'];
    user.email = map['email'];
    user.salt = map['salt'];
    user.password = map['password'];

    return user;
  }

  /// Finds all users
  Future<List<PantryUser>> findAll() async {
    Find finder = new Find(tableName);

    List<Map> maps = (await _userAdapter.find(finder)).toList();

    List<PantryUser> posts = new List<PantryUser>();

    for (Map map in maps) {
      PantryUser user = new PantryUser();

      user.uid = map['uid'];
      user.email = map['email'];
      user.salt = map['salt'];
      user.password = map['password'];

      posts.add(user);
    }

    return posts;
  }

  /// Deletes a user by [id]
  Future<int> remove(String id) async {
    Remove deleter = new Remove(tableName);

    deleter.where(this.id.eq(id));

    return await _userAdapter.remove(deleter);
  }

  /// Deletes all posts
  Future<int> removeAll() async {
    Remove deleter = new Remove(tableName);

    return await _userAdapter.remove(deleter);
  }
}

class UserNetworkUtil {
  // next three lines makes this class a Singleton
  static UserNetworkUtil _instance = new UserNetworkUtil.internal();
  UserNetworkUtil.internal();
  factory UserNetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
    return http.get(url).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching get data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {Map headers, body, encoding}) {
    return http.post(url, body: body, headers: headers, encoding: encoding).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching post data");
      }
      return _decoder.convert(res);
    });
  }
}
