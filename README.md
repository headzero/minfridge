# MINFRIDGE (하루한칸) MVP Client

Flutter MVP skeleton based on your requirements.

## Implemented
- Multi-fridge tabs (add/rename/delete)
- Item add/edit/delete with reason (`소진/폐기`)
- Gauge-based fridge occupancy visualization
- Storage-day color stages (`3/7/14/28/29+`)
- Recommendation flow with repository abstraction
  - Pre-generation window policy modeled in scheduler
  - Morning read-only behavior with fallback failure UI
  - Manual refresh cap (3/day)
- Recommendation history page
- Exit-time optional feedback dialog
- Ad banner placeholders (home + recommendation)

## Architecture
- State management: `Provider` (`ChangeNotifier`)
- Repository: `RecipeRepository`
  - Current: `MockRecipeRepository` (JSON mock)
  - Later: replace with real LLM API repository

## Run
```bash
cd /Users/young/Documents/workspace/minfridge
flutter run
```

## Firebase (later hookup)
- Current code safely tries `Firebase.initializeApp()`.
- Complete setup when ready:
1. Install FlutterFire CLI
2. Run `flutterfire configure`
3. Enable Firebase Auth (Google/Apple), Realtime DB, Analytics
4. Wire login/sync repository implementations

Detailed checklist: `lib/src/repositories/firebase_guide.md`

## Next recommended implementation
1. Persist local state (`shared_preferences` or local DB)
2. Replace mock recipe repository with API-backed repository
3. Implement local notifications at scheduled times
4. Add Realtime DB sync and merge logic
