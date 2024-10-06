class TwoFactorAuthModel {
  final String method;
  final bool isEnabled;

  TwoFactorAuthModel({required this.method, required this.isEnabled});

  factory TwoFactorAuthModel.fromMap(Map<String, dynamic> map) {
    return TwoFactorAuthModel(
      method: map['method'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'isEnabled': isEnabled,
    };
  }

  TwoFactorAuthModel copyWith({String? method, bool? isEnabled}) {
    return TwoFactorAuthModel(
      method: method ?? this.method,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TwoFactorAuthModel &&
        other.method == method &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode => method.hashCode ^ isEnabled.hashCode;
}
