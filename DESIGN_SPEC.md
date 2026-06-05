# 하루한칸 (MINFRIDGE) — 디자인 핸드오프 명세서

> Claude Design → Claude Code 핸드오프 문서.
> 대상: **Flutter + Material 3** (`provider`), 모바일 세로, 전 텍스트 한국어.
> 이 문서의 토큰/스펙을 `lib/src/ui/` 리뉴얼에 반영한다.
> 디자인 원본(인터랙티브): `하루한칸 — 홈 디자인 탐색.html` (디자인 캔버스).

---

## 0. 디자인 결정 요약

| 항목 | 결정 |
|---|---|
| 브랜드 톤 | **상큼한 연두초록** (primary `#6BA830`) |
| 타이포 | **Pretendard** (한국어 가독성 우선) |
| 아이콘 | **Material Symbols Outlined** (Flutter `Icons`로 매핑) |
| 신선도 표현 | 카드 전체 채색 ❌ → **상단 3px 컬러바 + 도트 + D-day 라벨** (색+라벨+아이콘 병행, 접근성) |
| 재고 구획 | 물리적 냉장고 형태(양문/4문 등)는 **모델링 안 함**. **논리적 칸**으로 처리 |
| 칸 정렬 | **토글 2모드**: `임박순`(신선도 존) ↔ `칸별`(냉장/냉동). **마지막 선택 영속화** |
| 보관 방식 | 아이템 속성 `store: 냉장/냉동/실온` 추가 → 유통기한 추정 + 칸 분류에 사용 |
| 다크 모드 | 토큰 정의 제공 (4장). 라이트 우선 구현 |

---

## 1. 컬러 토큰

### 1.1 라이트 (기본)

```
// 표면 / 잉크
bg          #F6FAEE   앱 배경 (연한 그린화이트)
surface     #FFFFFF   카드/시트 표면
sunken      #EDF4DF   인풋·세그먼트 트랙·트랙 배경
ink900      #27301C   제목/본문 강조
ink700      #46503A   본문
ink500      #8A9479   캡션/보조
ink400      #AEB89D   비활성/플레이스홀더
line        #E3ECD2   외곽선 (1px hairline)
lineSoft    #ECF2E1   카드 내부 구분선

// 브랜드 (연두초록)
brand       #6BA830   Primary (버튼·선택칩·강조)
brand700    #54871F   Pressed
brandTint   #E9F3D6   PrimaryContainer (탭 배경·강조 블록)
brandInk    #46751A   onPrimaryContainer (틴트 위 텍스트/아이콘)
```

### 1.2 신선도 시맨틱 (의미 고정 — 톤과 무관하게 유지)

| 키 | 의미 | main | tint | ink | 기준 |
|---|---|---|---|---|---|
| `fresh` | 여유 | `#3F9163` | `#E7F1EA` | `#2C6B45` | D-8↑ |
| `caution` | 주의 | `#CD9A1C` | `#FAF0D2` | `#856212` | D-4~7 |
| `soon` | 임박 | `#E97E2B` | `#FCE8D5` | `#9C4F12` | D-2~3 |
| `urgent` | 위급 | `#D6453A` | `#FBE1DD` | `#9C2A22` | D-1·지남 |

- **사용**: 타일 상단 3px 바 = `main`, 도트 = `main`, D-day 라벨 텍스트 = `ink`, 칩 배경 = `tint`.
- 색만으로 구분 금지 → 항상 **D-day 라벨(D-1/D-day/지남)** 동반.

### 1.3 보관 방식 (냉장/냉동/실온)

```
냉장 cold    아이콘 kitchen     (중립색 ink700)
냉동 frozen  아이콘 ac_unit     main #3E7CC2 / tint #E6EFF8 / ink #2A5A94  (한색=시원함)
실온 room    아이콘 countertops (중립색 ink700) — 옵션
```
- 냉동 아이템: 타일 우하단에 `ac_unit`(❄) 표시. 칸별 모드에서 `냉동칸` 헤더는 frost 톤.

### 1.4 점유율 게이지 / 끼니 색

```
gaugeOk     #5DA72C   목표(2/3) 이내
gaugeOver   #E97E2B   목표 초과 경고 (= soon orange)

끼니   아침 tint #FCEFE0 / dot #E59A3C / ink #9C6A2A
       점심 tint #E9F1E7 / dot #5BA46B / ink #3E7A4E
       저녁 tint #ECE8F3 / dot #7E6FB8 / ink #5A4E86
```

### 1.5 다크 (토큰만 — 라이트 우선)

```
bg #14180F · surface #1D2316 · sunken #272E1E
ink900 #ECF1E2 · ink700 #C2CBB4 · ink500 #8E997E · line #333B27
brand #9BD15E · brandTint #2A3A16 · brandInk #C7E89A
fresh #5FB985/#1E3326 · caution #E0B43A/#352B12 · soon #F0913F/#3A2613 · urgent #E85F52/#3A1E1A
frost #6BA6E0/#16263A · gaugeOver #F0913F
```

### 1.6 Flutter `ColorScheme` 매핑

```dart
ColorScheme.light(
  primary:            Color(0xFF6BA830),
  onPrimary:          Colors.white,
  primaryContainer:   Color(0xFFE9F3D6),
  onPrimaryContainer: Color(0xFF46751A),
  surface:            Colors.white,
  onSurface:          Color(0xFF27301C),
  onSurfaceVariant:   Color(0xFF8A9479),
  surfaceContainerLowest: Color(0xFFF6FAEE), // 앱 배경
  surfaceContainerHigh:   Color(0xFFEDF4DF), // sunken
  outline:            Color(0xFFCBD7B4),     // 더 진한 경계(필요 시)
  outlineVariant:     Color(0xFFE3ECD2),     // hairline
  error:              Color(0xFFD6453A),
)
```
신선도·보관·끼니·게이지 색은 `ColorScheme`에 없으므로 **`ThemeExtension<MinfridgeColors>`** 로 정의해 주입한다 (§7).

---

## 2. 타이포 (Pretendard)

| 역할 | size / weight | 비고 |
|---|---|---|
| 화면 제목 | 23 / 800, ls −0.6 | "하루한칸", "오늘의 추천" |
| 섹션 헤더 | 16 / 800 | "재고 19", 끼니 제목 |
| 존/칸 헤더 | 13.5 / 800 | "지금 먹어요", "냉동칸" |
| 본문 | 14.5 / 600 | 타일명·리스트 |
| 캡션 | 12.5 / 500~600, `ink500` | 서브텍스트 |
| 미세 라벨 | 10.5~11.5 / 700 | 카운트 칩·탭 라벨 |
| 수치 강조 | 26~30 / 800 | 게이지 %, D-day |

`pubspec.yaml`에 Pretendard 등록 후 `ThemeData.fontFamily = 'Pretendard'`.

---

## 3. 형태 토큰

```
radius:  카드 18 · 타일/인풋 11~12 · 버튼 14 · 칩 999 · 시트 상단 24
spacing: 4 · 8 · 12 · 16 (화면 좌우 패딩 16)
elevation(그림자):
  카드   0 1px 3px rgba(39,48,28,.05)
  버튼   0 6px 16px -8px (brand 70%)
  시트   0 -12px 40px rgba(24,16,10,.25)
  다이얼로그 0 24px 60px rgba(24,16,10,.35)
hit target ≥ 44px
```

---

## 4. 신선도 / 보관 로직 (디자인이 반영해야 하는 의미)

```
freshness(item):
  if item.expiresAt != null:               // 유통기한 우선
     d = daysUntilExpiry
     d<=1 → urgent | d<=3 → soon | d<=7 → caution | else fresh
  else:                                     // 보관일수 기반
     s = storageDays
     s<=3 → fresh | s<=14 → caution | s<=28 → soon | else urgent

ddayLabel(d): d<0 '지남' | d==0 'D-day' | else 'D-{d}'
서브텍스트: "수량 N개 · 보관 D일[ · 유통기한 D-n (예상)]"
'예상' 배지: expirySource == estimated 일 때만 (직접 입력이면 미표시)
보관 방식(store): 유통기한 자동 추정 입력값으로 사용 (냉동 = 장기). 칸별 분류 기준.
점유율: 총 quantity 합 / 30 (0~1 clamp). > 0.66 → 경고.
```

---

## 5. 컴포넌트 스펙 → Flutter 매핑

| 컴포넌트 | 사양 | Flutter |
|---|---|---|
| **재고 타일** `SmallTile` | 3열 그리드. 상단 3px 신선도 바 + 도트/​D-day, 이름(1줄 생략), 유형 아이콘+수량, 냉동 ❄. **탭 → 상세 시트** | `GridView`(3) / `Card` + `InkWell` |
| **점유율 게이지** | 기본 가로 막대(%, 2/3 마커, 상태 문구). 0%=빈 상태 | `Card` + `LinearProgressIndicator` |
| **정렬 토글** | `임박순 ↔ 칸별` 세그먼트. **`localStorage`→`SharedPreferences` 영속** | `SegmentedButton` + prefs |
| **임박순 존** | `지금 먹어요`(urgent+soon) / `이번 주 안에`(caution) / `여유 있어요`(fresh). 헤더 도트+카운트칩 | 섹션 위젯 |
| **냉장/냉동 칸** `StorageShelf` | `냉장칸`/`냉동칸`(/실온칸). 헤더 아이콘 박스 + 카운트 + `add_circle` | 섹션 위젯 |
| **끼니 카드** `MealCard` | 끼니별 은은한 tint 헤더(도트+제목) + 번호 메뉴 3개 | `Card` |
| **냉장고 탭칩** | 선택=brand 채움+`kitchen`아이콘, 비선택=outline | `ChoiceChip` 커스텀 |
| **버튼** | Filled(brand) / Outline(line 1.5px) / Text. h48 r14 | `FilledButton`/`OutlinedButton`/`TextButton` |
| **세그먼트(유형/보관방식)** | sunken 트랙 + 선택 흰 칩 | `SegmentedButton` |
| **배너 광고** | h56 점선 placeholder, 홈·오늘추천 **하단 고정** | `Container` (추후 AdMob) |
| **하단 네비** | 4탭, 선택=brandTint pill+brandInk | `NavigationBar` |

아이콘 매핑(주요): `kitchen, restaurant(→restaurant_menu), history, settings, tune, add, edit, delete, check, close, refresh, ac_unit, nutrition(→eco/restaurant), rice_bowl, warning, error, autorenew, calendar_today, edit_calendar, notifications_active, favorite, merge, cloud_upload, cloud_download`.
*Material Symbols에만 있는 글리프는 가장 가까운 `Icons.*`로 대체.*

---

## 6. 화면별 스펙

### 6.1 홈
헤더(하루한칸 + `tune`) → 냉장고 탭칩(가로) → 점유율 게이지 → 액션(식재료 추가 / 오늘 추천) → `재고 {총수량}` + 정렬 토글 → **재고 영역(세로 스크롤, 줄바꿈 3열 타일)** → 배너.
- **임박순 모드**: 3개 신선도 존.
- **칸별 모드**: 냉장칸 / 냉동칸(/실온칸).
- **빈 상태**: 게이지 0% + 일러스트(`kitchen`) + "냉장고가 비어 있어요" + `첫 재료 추가하기`.
- **점유율 초과**: 게이지 gaugeOver + "목표 초과".

### 6.2 오늘 추천 (성공/로딩/실패)
헤더("오늘의 추천" + `수동 새로고침 남은 횟수 N회 · 하루 최대 3회`) → 액션(수동 새로고침 / 오늘 조회) → 상태별 본문 → 배너.
- 성공: 아침/점심/저녁 `MealCard` 3개(끼니색).
- 로딩: 버튼 `생성 중…` + 스켈레톤 카드 3개.
- 실패: 일러스트 + "추천 생성에 실패했어요" + `실패 횟수 N / 3` 칩 + `다시 시도`.

### 6.3 히스토리 (배너 없음)
"추천 히스토리 / 지난 1년 · 최신순" → 날짜 카드(날짜+요일 | 아침3·점심3·저녁3 + 좋아요 아이콘 | 또는 `생성 실패` 칩). 빈 상태: `history` 일러스트 + 안내.

### 6.4 설정 (배너 없음)
그룹 카드: **계정**(비회원/회원 + UID, Google/Apple 로그인·비회원 전환, 병합 안내) · **알림**(오늘의 추천 알림, 오전 7시, 토글) · **활동**(최근 7일 좋아요 비율 %).

---

## 7. 모달 / 다이얼로그

| 모달 | 형태 | 핵심 |
|---|---|---|
| **아이템 상세** | 바텀시트 | 도트+이름(위급 칩 없음), 유통기한 D-day 정보(예상값 표시, 편집은 ‘수정’에서), 수량 스테퍼, 유형, 보관. 액션: **다 먹었어요·소진**(주) / **수정**(시트 열기) / **폐기** |
| **추가·수정** | 바텀시트 | 이름 · 수량 · 유형 · **보관 방식(냉장/냉동/실온)** · 보관 시작일 · **유통기한 예상 미리보기 + ‘직접 입력’**(비워둬도 됨) · 저장. *유통기한 직접 입력은 여기서만* |
| **냉장고 관리** | 바텀시트 | 목록(선택 표시·이름변경·삭제) + 새 냉장고 추가. "마지막 1개 삭제 불가" |
| **데이터 병합** | 다이얼로그 | 이 기기/클라우드 시각 비교 + 3선택: **최신 기준 병합(권장)** / 클라우드 사용 / 로컬 업로드 |
| **만족도** | 다이얼로그 | "오늘 추천 어땠어요?" 좋아요/싫어요(카드형) + 건너뛰기. 홈 백버튼 종료 시 |

> **삭제 사유(소진/폐기)는 상세 시트에 직접 노출** → 별도 삭제 사유 다이얼로그 단계 생략(개선점).

---

## 8. `ThemeExtension` 권장 구조

```dart
@immutable
class MinfridgeColors extends ThemeExtension<MinfridgeColors> {
  final FreshTone fresh, caution, soon, urgent;  // {main, tint, ink}
  final Color frost, frostTint, frostInk;
  final Color gaugeOk, gaugeOver;
  final MealTone breakfast, lunch, dinner;       // {tint, dot, ink}
  // copyWith / lerp 구현, 라이트/다크 2세트
}
```
신선도·보관·끼니·게이지 색은 전부 여기서 읽는다 (하드코딩 금지). `freshnessOf()` 헬퍼가 enum 반환 → 색 매핑.

---

## 9. 범위 밖 / 주의
- 광고 SDK·LLM 추천·바코드는 placeholder/mock (디자인은 자리만).
- 냉장고 **물리 형태(양문/4문 등)는 다루지 않음** — 칸은 논리적(냉장/냉동) 구분.
- 정렬 토글 상태는 `SharedPreferences` 영속(키 예: `mf_group_mode`).
- 접근성: 상태는 색+라벨+아이콘 병행, 명도 대비 확보.
