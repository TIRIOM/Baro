class UserModel {
  final String id;
  final String name;
  final String email;
  int credit;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.credit = 100,
  });
}
