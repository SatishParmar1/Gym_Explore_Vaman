// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GymModel _$GymModelFromJson(Map<String, dynamic> json) => GymModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      qrCode: json['qrCode'] as String?,
      isPartner: json['isPartner'] as bool? ?? false,
    );

Map<String, dynamic> _$GymModelToJson(GymModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phoneNumber': instance.phoneNumber,
      'website': instance.website,
      'amenities': instance.amenities,
      'qrCode': instance.qrCode,
      'isPartner': instance.isPartner,
    };

GymStatusModel _$GymStatusModelFromJson(Map<String, dynamic> json) =>
    GymStatusModel(
      gymId: json['gymId'] as String,
      currentOccupancy: (json['currentOccupancy'] as num).toInt(),
      maxCapacity: (json['maxCapacity'] as num).toInt(),
      occupancyPercentage: (json['occupancyPercentage'] as num).toDouble(),
      status: json['status'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      equipmentAvailability: (json['equipmentAvailability']
              as Map<String, dynamic>?)
          ?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
    );

Map<String, dynamic> _$GymStatusModelToJson(GymStatusModel instance) =>
    <String, dynamic>{
      'gymId': instance.gymId,
      'currentOccupancy': instance.currentOccupancy,
      'maxCapacity': instance.maxCapacity,
      'occupancyPercentage': instance.occupancyPercentage,
      'status': instance.status,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'equipmentAvailability': instance.equipmentAvailability,
    };
