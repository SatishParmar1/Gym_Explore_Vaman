// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      goal: json['goal'] as String?,
      activityLevel: json['activityLevel'] as String?,
      city: json['city'] as String?,
      gymId: json['gymId'] as String?,
      isGuest: json['isGuest'] as bool? ?? true,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] == null
          ? null
          : DateTime.parse(json['premiumExpiryDate'] as String),
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'profileImage': instance.profileImage,
      'age': instance.age,
      'gender': instance.gender,
      'height': instance.height,
      'weight': instance.weight,
      'targetWeight': instance.targetWeight,
      'goal': instance.goal,
      'activityLevel': instance.activityLevel,
      'city': instance.city,
      'gymId': instance.gymId,
      'isGuest': instance.isGuest,
      'isPremium': instance.isPremium,
      'premiumExpiryDate': instance.premiumExpiryDate?.toIso8601String(),
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };
