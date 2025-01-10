class User {
  String? userid;
  String? useremail;
  String? username;
  String? userphone;
  String? userpassword;
  String? userdatereg;
  String? useraddress;
  String? userprofileimage;
  String? userranking;
  String? userrole;

  User(
      {this.userid,
      this.useremail,
      this.username,
      this.userphone,
      this.userpassword,
      this.userdatereg,
      this.useraddress,
      this.userprofileimage,
      this.userranking,
      this.userrole});

  User.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    useremail = json['useremail'];
    username = json['username'];
    userphone = json['userphone'];
    userpassword = json['userpassword'];
    userdatereg = json['userdatereg'];
    useraddress = json['useraddress'];
    userprofileimage = json['userprofileimage'];
    userranking = json['userranking'];
    userrole = json['userrole'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['useremail'] = useremail;
    data['username'] = username;
    data['userphone'] = userphone;
    data['userpassword'] = userpassword;
    data['userdatereg'] = userdatereg;
    data['useraddress'] = useraddress;
    data['userprofileimage'] = userprofileimage;
    data['userranking'] = userranking;
    data['userrole'] = userrole;
    return data;
  }
}