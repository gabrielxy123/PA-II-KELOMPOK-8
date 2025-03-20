class UserProfile {
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImage;

  UserProfile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['noTelp'] ?? '',
      profileImage: json['profile_image'] ?? '',
    );
  }
}
