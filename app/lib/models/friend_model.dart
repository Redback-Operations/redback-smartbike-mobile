class FriendModel {
  final String name;
  final String surname;
  final String username;
  final String email;
  final String dob;
  final String phoneNumber;
  final String imagePath;

  FriendModel({
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    required this.dob,
    required this.phoneNumber,
    required this.imagePath,
  });

  // Factory constructor to create a Friend from JSON data
  factory FriendModel.fromJson(Map<String, dynamic> json, String baseURL) {
    return FriendModel(
      name: json['name'] as String,
      surname: json['surname'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      dob: json['dob'] ?? 'N/A',
      phoneNumber: json['phone_number'] ?? 'N/A',
      imagePath: json['image'] != null && json['image'].isNotEmpty
          ? '$baseURL${json['image']}'
          : '$baseURL/media/images/default.jpeg', // Fallback to a default image
    );
  }

  // Method to convert Friend instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'username': username,
      'email': email,
      'dob': dob,
      'phone_number': phoneNumber,
      'image_path': imagePath,
    };
  }
}
