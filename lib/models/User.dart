enum UserRole { client, pro }

class User {
  final int? id;
  final String name;
  final String email;
  final UserRole role;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromMap(Map<String, Object?> map) => User(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String,
    role: UserRole.values.byName(map['role'] as String),
  );
}