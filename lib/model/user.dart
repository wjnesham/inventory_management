import 'package:jaguar_orm/jaguar_orm.dart';

class PantryUser {
  @Column(isNullable: false)
  String email;
  @Column(isNullable: false)
  String salt;
  @Column(isNullable: false)
  String password;
  @Column(isNullable: false)
  String name;
  @Column(isNullable: false)
  int itemPageSize;
  @Column(isNullable: false)
  bool darknessBoolean;

  @PrimaryKey(auto: false, isNullable: false)
  String uid;

  PantryUser(
      {this.uid, this.email, this.salt, this.password, this.name, this.itemPageSize, this.darknessBoolean});

  static const String idName = "uid";
  static const String emailName = "email";
  static const String saltName = "salt";
  static const String passwordName = "password";
  static const String nameName = "name";
}
