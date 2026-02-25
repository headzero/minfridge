# Firebase setup guide (MVP)

## Services to enable
- Authentication: Google, Apple
- Realtime Database
- Analytics

## Why this set
- Auth: anonymous + social login merge flow
- Realtime DB: low-cost sync for fridges/items/recommendations
- Analytics: DAU, recommendation refresh/failure events

## Suggested schema
- users/{uid}/fridges/{fridgeId}
- users/{uid}/items/{itemId}
- users/{uid}/recommendations/{yyyy-mm-dd}
- users/{uid}/feedback/{yyyy-mm-dd}

## Client integration order
1. Initialize Firebase in `main.dart`
2. Add Auth flows (anonymous first, then link Google/Apple)
3. Upload/download fridge + item data
4. Sync recommendation history
5. Add Analytics events:
   - `recommendation_generated`
   - `recommendation_failed`
   - `manual_refresh_tapped`
   - `feedback_submitted`
