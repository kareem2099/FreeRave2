class CutLooseModel {
  final String message;

  CutLooseModel(this.message);

  factory CutLooseModel.fromJson(Map<String, dynamic> json) {
    return CutLooseModel(json['message']);
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}
