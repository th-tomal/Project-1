enum UserRole {
  admin,
  teacher,
  student,
}

extension UserRoleX on UserRole {
  String get value => name; // returns lowercase
}