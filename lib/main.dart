import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/repositories/mock_recipe_repository.dart';
import 'src/services/recommendation_scheduler.dart';
import 'src/state/app_state.dart';
import 'src/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase setup can be completed later with platform-specific options.
  }

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState(
        recipeRepository: MockRecipeRepository(),
        scheduler: RecommendationScheduler(),
      )..bootstrap(),
      child: const MinFridgeApp(),
    ),
  );
}
