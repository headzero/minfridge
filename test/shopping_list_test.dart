import 'package:flutter_test/flutter_test.dart';

import 'package:minfridge/src/models/food_item.dart';
import 'package:minfridge/src/models/shopping_item.dart';
import 'package:minfridge/src/repositories/mock_recipe_repository.dart';
import 'package:minfridge/src/services/recommendation_scheduler.dart';
import 'package:minfridge/src/state/app_state.dart';

void main() {
  AppState build() => AppState(
    recipeRepository: MockRecipeRepository(),
    scheduler: RecommendationScheduler(),
  );

  test('장보기 항목 추가 및 같은 이름 중복 방지', () {
    final state = build();
    state.addShoppingItem('우유');
    state.addShoppingItem(' 우유 '); // 공백/대소문자 무시, 중복 아님
    expect(state.shoppingList.where((e) => e.name.trim() == '우유').length, 1);
  });

  test('빈 이름은 추가되지 않는다', () {
    final state = build();
    state.addShoppingItem('   ');
    expect(state.shoppingList, isEmpty);
  });

  test('토글로 담음/해제, 미체크 카운트 반영', () {
    final state = build();
    state.addShoppingItem('계란');
    expect(state.pendingShoppingCount, 1);
    state.toggleShoppingItem(state.shoppingList.first);
    expect(state.pendingShoppingCount, 0);
    expect(state.shoppingList.first.checked, isTrue);
  });

  test('이미 담은(체크된) 항목을 다시 추가하면 체크가 풀려 되살아난다', () {
    final state = build();
    state.addShoppingItem('두부');
    state.toggleShoppingItem(state.shoppingList.first);
    expect(state.shoppingList.first.checked, isTrue);
    state.addShoppingItem('두부');
    expect(state.shoppingList.length, 1);
    expect(state.shoppingList.first.checked, isFalse);
  });

  test('담은 항목 비우기는 체크된 항목만 제거', () {
    final state = build();
    state.addShoppingItem('사과');
    state.addShoppingItem('바나나');
    state.toggleShoppingItem(state.shoppingList.first);
    state.clearCheckedShoppingItems();
    expect(state.shoppingList.length, 1);
    expect(state.shoppingList.first.checked, isFalse);
  });

  test('소진(consumed) 재료는 장보기 후보로 자동 추가, 폐기는 아님', () {
    final state = build();
    state.addItem(
      name: '두유',
      type: FoodType.ingredient,
      quantity: 1,
      startedAt: DateTime.now(),
    );
    state.addItem(
      name: '상한우유',
      type: FoodType.ingredient,
      quantity: 1,
      startedAt: DateTime.now(),
    );
    final items = state.activeItemsInSelectedFridge;
    state.deleteItem(items.firstWhere((e) => e.name == '두유'), reason: 'consumed');
    state.deleteItem(items.firstWhere((e) => e.name == '상한우유'), reason: 'discarded');

    final names = state.shoppingList.map((e) => e.name).toList();
    expect(names, contains('두유'));
    expect(names, isNot(contains('상한우유')));
    expect(
      state.shoppingList.firstWhere((e) => e.name == '두유').source,
      ShoppingSource.consumed,
    );
  });

  test('장보기 목록이 export-import 세션 왕복으로 보존된다', () {
    final source = build();
    source.addShoppingItem('김');
    source.addShoppingItem('계란');
    source.toggleShoppingItem(source.shoppingList.first);

    final session = source.exportSessionState();
    final restored = build();
    restored.importSessionState(session);

    expect(restored.shoppingList.length, 2);
    expect(
      restored.shoppingList.firstWhere((e) => e.name == '김').checked,
      isTrue,
    );
  });
}
