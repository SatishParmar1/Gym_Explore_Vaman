import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gym_model.g.dart';

@JsonSerializable()
class GymModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? website;
  final List<String>? amenities;
  final String? qrCode;
  final bool isPartner;

  const GymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.website,
    this.amenities,
    this.qrCode,
    this.isPartner = false,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) =>
      _$GymModelFromJson(json);

  Map<String, dynamic> toJson() => _$GymModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        latitude,
        longitude,
        phoneNumber,
        website,
        amenities,
        qrCode,
        isPartner,
      ];
}

@JsonSerializable()
class GymStatusModel extends Equatable {
  final String gymId;
  final int currentOccupancy;
  final int maxCapacity;
  final double occupancyPercentage;
  final String status; // empty, moderate, busy, packed
  final DateTime lastUpdated;
  final Map<String, bool>? equipmentAvailability;

  const GymStatusModel({
    required this.gymId,
    required this.currentOccupancy,
    required this.maxCapacity,
    required this.occupancyPercentage,
    required this.status,
    required this.lastUpdated,
    this.equipmentAvailability,
  });

  factory GymStatusModel.fromJson(Map<String, dynamic> json) =>
      _$GymStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$GymStatusModelToJson(this);

  String get statusEmoji {
    switch (status.toLowerCase()) {
      case 'empty':
        return '🟢';
      case 'moderate':
        return '🟡';
      case 'busy':
        return '🟠';
      case 'packed':
        return '🔴';
      default:
        return '⚪';
    }
  }

  String get statusDescription {
    switch (status.toLowerCase()) {
      case 'empty':
        return 'Perfect time to go!';
      case 'moderate':
        return 'Good time to workout';
      case 'busy':
        return 'Might need to wait for equipment';
      case 'packed':
        return 'Very crowded right now';
      default:
        return 'Status unknown';
    }
  }

  @override
  List<Object?> get props => [
        gymId,
        currentOccupancy,
        maxCapacity,
        occupancyPercentage,
        status,
        lastUpdated,
        equipmentAvailability,
      ];
}
