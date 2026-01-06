import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;
  final int? age;
  final String? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final double? targetWeight;
  final String? goal; // weight_loss, muscle_gain, maintain
  final String? activityLevel;
  final String? city;
  final String? gymId;
  final bool isGuest;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final int currentStreak;
  final int longestStreak;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.targetWeight,
    this.goal,
    this.activityLevel,
    this.city,
    this.gymId,
    this.isGuest = true,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? targetWeight,
    String? goal,
    String? activityLevel,
    String? city,
    String? gymId,
    bool? isGuest,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    int? currentStreak,
    int? longestStreak,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      city: city ?? this.city,
      gymId: gymId ?? this.gymId,
      isGuest: isGuest ?? this.isGuest,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        profileImage,
        age,
        gender,
        height,
        weight,
        targetWeight,
        goal,
        activityLevel,
        city,
        gymId,
        isGuest,
        isPremium,
        premiumExpiryDate,
        currentStreak,
        longestStreak,
        createdAt,
        lastLoginAt,
      ];
}
