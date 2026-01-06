import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/diet/diet_bloc.dart';
import '../../blocs/diet/diet_event.dart';
import '../../blocs/diet/diet_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/meal_model.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<DietBloc>().add(DietLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'DIET TRACKER',
          style: GoogleFonts.sairaExtraCondensed(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.sairaExtraCondensed(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: GoogleFonts.sairaExtraCondensed(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'TODAY'),
            Tab(text: 'LOG'),
            Tab(text: 'TEMPLATES'),
            Tab(text: 'WATER'),
          ],
        ),
      ),
      body: BlocBuilder<DietBloc, DietState>(
        builder: (context, state) {
          if (state is DietLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'LOADING...',
                    style: GoogleFonts.sairaExtraCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is DietError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'ERROR',
                      style: GoogleFonts.sairaExtraCondensed(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.barlow(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DietBloc>().add(DietLoadRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'RETRY',
                        style: GoogleFonts.sairaExtraCondensed(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DietLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(state),
                _buildLogTab(state),
                _buildTemplatesTab(state),
                _buildWaterTab(),
              ],
            );
          }

          if (state is DietFoodSearchResult) {
            return _buildSearchResults(state);
          }

          return Center(
            child: Text(
              'Start tracking your diet!',
              style: GoogleFonts.barlow(
                fontSize: 16,
                color: AppColors.textMuted,
              ),
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.fireGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showQuickLogDialog();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTodayTab(DietLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie Summary Card
          _buildCalorieSummaryCard(state),
          const SizedBox(height: 16),

          // Macro Breakdown
          _buildMacroBreakdown(state),
          const SizedBox(height: 24),

          // Today's Meals
          Text(
            'Today\'s Meals',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (state.todayMeals.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.restaurant, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('No meals logged today'),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Log your first meal'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...state.todayMeals.map((meal) => _buildMealCard(meal)),
        ],
      ),
    );
  }

  Widget _buildCalorieSummaryCard(DietLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${state.totalCalories.toInt()} / ${state.targetCalories.toInt()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.caloriesPercentage,
                minHeight: 16,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  state.caloriesPercentage > 1
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.caloriesRemaining >= 0
                      ? '${state.caloriesRemaining.toInt()} remaining'
                      : '${(-state.caloriesRemaining).toInt()} over',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: state.caloriesRemaining >= 0
                            ? AppColors.textSecondary
                            : AppColors.error,
                      ),
                ),
                Text(
                  '${(state.caloriesPercentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBreakdown(DietLoaded state) {
    final total = state.totalProtein + state.totalCarbs + state.totalFats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMacroItem(
                    'Protein',
                    state.totalProtein,
                    AppColors.protein,
                    total > 0 ? state.totalProtein / total : 0,
                  ),
                ),
                Expanded(
                  child: _buildMacroItem(
                    'Carbs',
                    state.totalCarbs,
                    AppColors.carbs,
                    total > 0 ? state.totalCarbs / total : 0,
                  ),
                ),
                Expanded(
                  child: _buildMacroItem(
                    'Fats',
                    state.totalFats,
                    AppColors.fats,
                    total > 0 ? state.totalFats / total : 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String name, double value, Color color, double percentage) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${value.toInt()}g',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealModel meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            _getMealIcon(meal.mealType),
            color: AppColors.primary,
          ),
        ),
        title: Text(meal.foodName),
        subtitle: Text(
          '${meal.mealType.toUpperCase()} • ${meal.quantity.toInt()} ${meal.unit}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${meal.calories.toInt()} cal',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'P:${meal.protein.toInt()}g C:${meal.carbs.toInt()}g F:${meal.fats.toInt()}g',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        onLongPress: () {
          _showDeleteMealDialog(meal);
        },
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.nights_stay;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildLogTab(DietLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search food...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: _startVoiceInput,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      // TODO: Implement camera scanning
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (query) {
              context.read<DietBloc>().add(DietSearchFood(query: query));
            },
          ),
          const SizedBox(height: 24),

          // Recent Foods
          Text(
            'Recent Foods',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...state.recentFoods.map((food) => _buildFoodItem(food)),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodItemModel food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(food.name),
        subtitle: Text(food.category),
        trailing: Text('${food.caloriesPer100g.toInt()} cal/100g'),
        onTap: () {
          _showAddMealDialog(food);
        },
      ),
    );
  }

  Widget _buildSearchResults(DietFoodSearchResult state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchController..text = state.query,
            decoration: InputDecoration(
              hintText: 'Search food...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<DietBloc>().add(DietLoadRequested());
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (query) {
              context.read<DietBloc>().add(DietSearchFood(query: query));
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Results for "${state.query}"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (state.results.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No foods found'),
              ),
            )
          else
            ...state.results.map((food) => _buildFoodItem(food)),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab(DietLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal Templates',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save your frequently eaten meals for quick logging',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          if (state.mealTemplates.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.bookmark_border, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('No templates yet'),
                    const SizedBox(height: 8),
                    const Text(
                      'Long press on any meal to save as template',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...state.mealTemplates.map((template) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(template.name),
                    subtitle: Text('${template.meals.length} items • ${template.totalCalories.toInt()} cal'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        context.read<DietBloc>().add(DietLogFromTemplate(template: template));
                      },
                      child: const Text('Log'),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildWaterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Water Tracker',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Water Progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 64,
                    color: AppColors.info,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '5 / 8 glasses',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 5 / 8,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.info),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWaterButton('🥛', '1 Glass', 1),
                      _buildWaterButton('🍶', '500ml', 2),
                      _buildWaterButton('💧', '1L', 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(String emoji, String label, double glasses) {
    return InkWell(
      onTap: () {
        context.read<DietBloc>().add(DietLogWater(amount: glasses));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _showQuickLogDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Log',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickLogChip('Breakfast', Icons.wb_sunny),
                  _buildQuickLogChip('Lunch', Icons.restaurant),
                  _buildQuickLogChip('Dinner', Icons.nights_stay),
                  _buildQuickLogChip('Snack', Icons.cookie),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLogChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        Navigator.pop(context);
        _tabController.animateTo(1);
      },
    );
  }

  void _showAddMealDialog(FoodItemModel food) {
    double quantity = 1;
    String selectedMealType = 'lunch';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Log ${food.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedMealType,
                decoration: const InputDecoration(labelText: 'Meal Type'),
                items: ['breakfast', 'lunch', 'dinner', 'snack']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedMealType = value!);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 0.5) setState(() => quantity -= 0.5);
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Expanded(
                    child: Text(
                      '${quantity.toStringAsFixed(1)} serving',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => quantity += 0.5);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${(food.caloriesPer100g * quantity).toInt()} calories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final meal = MealModel(
                  id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
                  userId: 'user_1',
                  mealType: selectedMealType,
                  foodName: food.name,
                  calories: food.caloriesPer100g * quantity,
                  protein: food.proteinPer100g * quantity,
                  carbs: food.carbsPer100g * quantity,
                  fats: food.fatsPer100g * quantity,
                  quantity: quantity,
                  unit: 'serving',
                  loggedAt: DateTime.now(),
                );
                context.read<DietBloc>().add(DietLogMeal(meal: meal));
                Navigator.pop(context);
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteMealDialog(MealModel meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DietBloc>().add(DietDeleteMeal(mealId: meal.id!));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _startVoiceInput() {
    // TODO: Implement voice input using speech_to_text
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input coming soon!'),
      ),
    );
  }
}
