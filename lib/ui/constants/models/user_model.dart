class UserModel {
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final String? password;

  UserModel({
    this.email,
    this.fullName,
    this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
    );
  }
}