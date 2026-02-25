import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:minfridge/src/repositories/mock_recipe_repository.dart';
import 'package:minfridge/src/services/recommendation_scheduler.dart';
import 'package:minfridge/src/state/app_state.dart';
import 'package:minfridge/src/ui/app.dart';

void main() {
  testWidgets('app renders home title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(
          recipeRepository: MockRecipeRepository(),
          scheduler: RecommendationScheduler(),
        ),
        child: const MinFridgeApp(),
      ),
    );

    expect(find.text('하루한칸'), findsOneWidget);
  });
}
