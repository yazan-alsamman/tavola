class UserPreferencesModel {
  const UserPreferencesModel({
    required this.notificationOptIn,
    required this.marketingOptIn,
  });

  final bool notificationOptIn;
  final bool marketingOptIn;

  UserPreferencesModel copyWith({
    bool? notificationOptIn,
    bool? marketingOptIn,
  }) {
    return UserPreferencesModel(
      notificationOptIn: notificationOptIn ?? this.notificationOptIn,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
    );
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      notificationOptIn: json['notificationOptIn'] == true,
      marketingOptIn: json['marketingOptIn'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'notificationOptIn': notificationOptIn,
      'marketingOptIn': marketingOptIn,
    };
  }
}
