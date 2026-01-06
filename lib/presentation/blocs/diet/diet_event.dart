import 'package:equatable/equatable.dart';
import '../../../data/models/meal_model.dart';

abstract class DietEvent extends Equatable {
  const DietEvent();

  @override
  List<Object?> get props => [];
}

class DietLoadRequested extends DietEvent {}

class DietSearchFood extends DietEvent {
  final String query;

  const DietSearchFood({required this.query});

  @override
  List<Object?> get props => [query];
}

class DietLogMeal extends DietEvent {
  final MealModel meal;

  const DietLogMeal({required this.meal});

  @override
  List<Object?> get props => [meal];
}

class DietDeleteMeal extends DietEvent {
  final String mealId;

  const DietDeleteMeal({required this.mealId});

  @override
  List<Object?> get props => [mealId];
}

class DietLogWater extends DietEvent {
  final double amount; // in glasses

  const DietLogWater({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class DietVoiceInput extends DietEvent {
  final String voiceText;

  const DietVoiceInput({required this.voiceText});

  @override
  List<Object?> get props => [voiceText];
}

class DietSaveTemplate extends DietEvent {
  final String name;
  final List<MealModel> meals;

  const DietSaveTemplate({
    required this.name,
    required this.meals,
  });

  @override
  List<Object?> get props => [name, meals];
}

class DietLogFromTemplate extends DietEvent {
  final MealTemplateModel template;

  const DietLogFromTemplate({required this.template});

  @override
  List<Object?> get props => [template];
}
