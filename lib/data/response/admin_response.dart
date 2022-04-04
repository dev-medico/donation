class AdminResponse {
  String? password;
  String? role;
  String? gender;
  String? name;
  String? email;

  AdminResponse({this.password, this.role, this.gender, this.name, this.email});

  AdminResponse.fromJson(Map<String, dynamic> json) {
    password = json['password'];
    role = json['role'];
    gender = json['gender'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['password'] = this.password;
    data['role'] = this.role;
    data['gender'] = this.gender;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}
