class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final String password;
  final String passkey;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.passkey,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'passkey': passkey,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
      passkey: json['passkey'],
    );
  }
}
