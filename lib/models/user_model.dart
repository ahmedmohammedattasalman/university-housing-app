class UserModel {
  final String id;
  final String email;
  final String userRole;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.userRole,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.isActive,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      userRole: json['user_role'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      profileImageUrl: json['profile_image_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_role': userRole,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'is_active': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? userRole,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
