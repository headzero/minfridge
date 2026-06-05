/* 하루한칸 — 오늘 추천 (성공 / 실패 / 로딩). window로 export.
   끼니별 은은한 색 구분, 아이콘 없음. 보유 재료 기반 추천(목업). */

const MEALS = {
  breakfast: { label: '아침', tint: '#FCEFE0', ink: '#9C6A2A', dot: '#E59A3C' },
  lunch:     { label: '점심', tint: '#E9F1E7', ink: '#3E7A4E', dot: '#5BA46B' },
  dinner:    { label: '저녁', tint: '#ECE8F3', ink: '#5A4E86', dot: '#7E6FB8' },
};
const REC = {
  breakfast: ['두부 계란탕', '시금치 된장국', '사과 요거트볼'],
  lunch: ['닭가슴살 볶음밥', '대파 계란말이', '배추김치찜'],
  dinner: ['두부조림 백반', '멸치볶음 비빔밥', '냉동만두 만둣국'],
};

function TodayHeader({ remaining = 2, busy = false }) {
  return (
    <React.Fragment>
      <div style={{ padding: '4px 16px 0' }}>
        <div style={{ fontSize: 23, fontWeight: 800, color: MF.ink900, letterSpacing: '-0.6px' }}>오늘의 추천</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 5 }}>
          <MIcon name="autorenew" size={15} color={MF.ink400} />
          <span style={{ fontSize: 12.5, fontWeight: 600, color: MF.ink500 }}>
            수동 새로고침 남은 횟수 <span style={{ color: MF.brand, fontWeight: 800 }}>{remaining}회</span> · 하루 최대 3회</span>
        </div>
      </div>
      <div style={{ display: 'flex', gap: 8, padding: '14px 16px 4px' }}>
        <PrimaryBtn icon={busy ? 'hourglass_top' : 'refresh'} full>{busy ? '생성 중…' : '수동 새로고침'}</PrimaryBtn>
        <OutlineBtn icon="event_available" full>오늘 조회</OutlineBtn>
      </div>
    </React.Fragment>
  );
}

function MealCard({ meal, items }) {
  const m = MEALS[meal];
  return (
    <div style={{ background: MF.surface, borderRadius: 16, border: `1px solid ${MF.lineSoft}`,
      overflow: 'hidden', marginBottom: 11 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '11px 14px', background: m.tint }}>
        <span style={{ width: 9, height: 9, borderRadius: 9, background: m.dot }} />
        <span style={{ fontSize: 15, fontWeight: 800, color: m.ink }}>{m.label}</span>
        <span style={{ fontSize: 11.5, fontWeight: 600, color: m.ink, opacity: 0.7 }}>· 보유 재료로</span>
      </div>
      <div style={{ padding: '6px 14px 12px' }}>
        {items.map((it, i) => (
          <div key={it} style={{ display: 'flex', alignItems: 'center', gap: 9, padding: '8px 0',
            borderTop: i === 0 ? 'none' : `1px solid ${MF.lineSoft}` }}>
            <span style={{ fontSize: 12, fontWeight: 800, color: m.dot, width: 16 }}>{i + 1}</span>
            <span style={{ fontSize: 14.5, fontWeight: 600, color: MF.ink900 }}>{it}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function TodaySuccess() {
  return (
    <Screen active={1}>
      <TodayHeader remaining={2} />
      <div style={{ flex: 1, minHeight: 0, overflow: 'hidden', padding: '10px 16px 0' }}>
        <MealCard meal="breakfast" items={REC.breakfast} />
        <MealCard meal="lunch" items={REC.lunch} />
        <MealCard meal="dinner" items={REC.dinner} />
      </div>
    </Screen>
  );
}

function TodayFailure() {
  return (
    <Screen active={1}>
      <TodayHeader remaining={1} />
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', alignItems: 'center',
        justifyContent: 'center', padding: '0 28px', textAlign: 'center' }}>
        <div style={{ width: 84, height: 84, borderRadius: 24, background: MF.urgent.tint, display: 'flex',
          alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}>
          <MIcon name="sentiment_dissatisfied" size={42} color={MF.urgent.main} />
        </div>
        <div style={{ fontSize: 17, fontWeight: 800, color: MF.ink900, marginBottom: 7 }}>추천 생성에 실패했어요</div>
        <div style={{ fontSize: 13.5, fontWeight: 500, color: MF.ink500, lineHeight: 1.5, marginBottom: 14 }}>
          잠시 후 다시 시도해 주세요.<br />재료를 더 추가하면 성공률이 올라가요.</div>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5, height: 26, padding: '0 11px',
          borderRadius: 13, background: MF.urgent.tint, color: MF.urgent.ink, fontSize: 12, fontWeight: 700, marginBottom: 22 }}>
          <MIcon name="error" size={14} fill={1} />실패 횟수 1 / 3
        </div>
        <PrimaryBtn icon="refresh">다시 시도</PrimaryBtn>
      </div>
    </Screen>
  );
}

function SkeletonCard({ meal }) {
  const m = MEALS[meal];
  return (
    <div style={{ background: MF.surface, borderRadius: 16, border: `1px solid ${MF.lineSoft}`,
      overflow: 'hidden', marginBottom: 11 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '11px 14px', background: m.tint }}>
        <span style={{ width: 9, height: 9, borderRadius: 9, background: m.dot, opacity: 0.5 }} />
        <span style={{ fontSize: 15, fontWeight: 800, color: m.ink, opacity: 0.7 }}>{m.label}</span>
      </div>
      <div style={{ padding: '12px 14px' }}>
        {[78, 62, 70].map((w, i) => (
          <div key={i} style={{ height: 13, width: `${w}%`, borderRadius: 7, background: MF.sunken,
            marginBottom: i === 2 ? 0 : 12 }} />
        ))}
      </div>
    </div>
  );
}
function TodayLoading() {
  return (
    <Screen active={1}>
      <TodayHeader remaining={2} busy />
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '12px 16px 2px' }}>
        <MIcon name="auto_awesome" size={16} color={MF.brand} />
        <span style={{ fontSize: 13, fontWeight: 700, color: MF.ink700 }}>오늘 끼니를 고르는 중이에요…</span>
      </div>
      <div style={{ flex: 1, minHeight: 0, overflow: 'hidden', padding: '8px 16px 0' }}>
        <SkeletonCard meal="breakfast" />
        <SkeletonCard meal="lunch" />
        <SkeletonCard meal="dinner" />
      </div>
    </Screen>
  );
}

Object.assign(window, { MEALS, REC, TodayHeader, MealCard, TodaySuccess, TodayFailure, TodayLoading });
