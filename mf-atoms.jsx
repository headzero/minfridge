/* 하루한칸 — 공유 토큰 · 아이콘 · 데이터 · 원자 컴포넌트
   모든 홈 방향(A/B/C)과 스펙시트가 공유. window로 export. */

// ── 디자인 토큰 (라이트) — 브랜드: 상큼한 연두초록 ──────
const MF = {
  bg: '#F6FAEE', surface: '#FFFFFF', sunken: '#EDF4DF', card2: '#FFFFFF',
  ink900: '#27301C', ink700: '#46503A', ink500: '#8A9479', ink400: '#AEB89D',
  line: '#E3ECD2', lineSoft: '#ECF2E1',
  brand: '#6BA830', brand700: '#54871F', brandTint: '#E9F3D6', brandInk: '#46751A',
  // 신선도 신호등 (의미 유지, 하모나이즈)
  fresh:   { key: 'fresh',   name: '여유', main: '#3F9163', tint: '#E7F1EA', ink: '#2C6B45' },
  caution: { key: 'caution', name: '주의', main: '#CD9A1C', tint: '#FAF0D2', ink: '#856212' },
  soon:    { key: 'soon',    name: '임박', main: '#E97E2B', tint: '#FCE8D5', ink: '#9C4F12' },
  urgent:  { key: 'urgent',  name: '위급', main: '#D6453A', tint: '#FBE1DD', ink: '#9C2A22' },
  gaugeOk: '#5DA72C', gaugeOver: '#E97E2B',
  frost: '#3E7CC2', frostTint: '#E6EFF8', frostInk: '#2A5A94',
};
const STORE = {
  cold:   { key: 'cold',   name: '냉장', icon: 'kitchen' },
  frozen: { key: 'frozen', name: '냉동', icon: 'ac_unit' },
  room:   { key: 'room',   name: '실온', icon: 'countertops' },
};
const FRESH = { fresh: MF.fresh, caution: MF.caution, soon: MF.soon, urgent: MF.urgent };

// ── 아이콘 (Material Symbols Outlined — Flutter Material 3와 동일 글리프) ──
function MIcon({ name, size = 22, fill = 0, weight = 400, color, style }) {
  return (
    <span className="msi" style={{
      fontSize: size, color,
      fontVariationSettings: `'FILL' ${fill}, 'wght' ${weight}, 'GRAD' 0, 'opsz' ${size}`,
      ...style,
    }}>{name}</span>
  );
}

// ── 신선도 로직 ───────────────────────────────────────
function freshnessOf(item) {
  if (item.dday != null) {
    const d = item.dday;
    if (d <= 1) return 'urgent';
    if (d <= 3) return 'soon';
    if (d <= 7) return 'caution';
    return 'fresh';
  }
  const s = item.storageDays;
  if (s <= 3) return 'fresh';
  if (s <= 14) return 'caution';
  if (s <= 28) return 'soon';
  return 'urgent';
}
function ddayLabel(d) { return d < 0 ? '지남' : d === 0 ? 'D-day' : 'D-' + d; }
function subLine(item) {
  const parts = [`수량 ${item.quantity}개`, `보관 ${item.storageDays}일`];
  if (item.dday != null) parts.push(`유통기한 ${ddayLabel(item.dday)}${item.est ? ' (예상)' : ''}`);
  return parts.join(' · ');
}

// ── 샘플 데이터 ───────────────────────────────────────
const SAMPLE_FRIDGES = [
  { id: 'f1', name: '주방 냉장고' },
  { id: 'f2', name: '김치냉장고' },
  { id: 'f3', name: '사무실' },
];
const SAMPLE_ITEMS = [
  { name: '손두부',   type: 'ing',  store: 'cold',   quantity: 2, storageDays: 4,  dday: 1,  est: true  },
  { name: '우유 1L',  type: 'ing',  store: 'cold',   quantity: 1, storageDays: 3,  dday: 2,  est: true  },
  { name: '시금치',   type: 'ing',  store: 'cold',   quantity: 1, storageDays: 5,  dday: 3,  est: true  },
  { name: '대파',     type: 'ing',  store: 'cold',   quantity: 1, storageDays: 8,  dday: null, est: false },
  { name: '멸치볶음', type: 'side', store: 'cold',   quantity: 1, storageDays: 6,  dday: null, est: false },
  { name: '사과',     type: 'ing',  store: 'cold',   quantity: 4, storageDays: 6,  dday: 9,  est: true  },
  { name: '계란 한판', type: 'ing', store: 'cold',   quantity: 3, storageDays: 6,  dday: 18, est: true  },
  { name: '배추김치', type: 'side', store: 'cold',   quantity: 1, storageDays: 21, dday: 40, est: false },
  { name: '닭가슴살', type: 'ing',  store: 'frozen', quantity: 3, storageDays: 9,  dday: 30, est: true  },
  { name: '냉동만두', type: 'ing',  store: 'frozen', quantity: 2, storageDays: 12, dday: 60, est: true  },
];
const TOTAL_QTY = SAMPLE_ITEMS.reduce((s, i) => s + i.quantity, 0); // 19
const GAUGE = TOTAL_QTY / 30; // 0.633
// 급한 순 정렬 (위급>임박>주의>여유, 그 안에서 dday 오름차순)
const RANK = { urgent: 0, soon: 1, caution: 2, fresh: 3 };
const SORTED = [...SAMPLE_ITEMS].sort((a, b) => {
  const ra = RANK[freshnessOf(a)], rb = RANK[freshnessOf(b)];
  if (ra !== rb) return ra - rb;
  return (a.dday ?? 99) - (b.dday ?? 99);
});

// ── 상태바 ────────────────────────────────────────────
function StatusBar({ tone = 'dark' }) {
  const c = tone === 'dark' ? MF.ink900 : '#fff';
  return (
    <div style={{ height: 44, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 22px 0 26px', flex: '0 0 auto' }}>
      <span style={{ fontSize: 15, fontWeight: 700, color: c, letterSpacing: '0.2px' }}>9:41</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <MIcon name="signal_cellular_alt" size={17} fill={1} color={c} />
        <MIcon name="wifi" size={17} fill={1} color={c} />
        <MIcon name="battery_full" size={19} fill={1} color={c} style={{ transform: 'rotate(90deg)' }} />
      </div>
    </div>
  );
}

// ── 하단 네비게이션 ───────────────────────────────────
function BottomNav({ active = 0, accent = MF.brand }) {
  const tabs = [
    { icon: 'kitchen', label: '홈' },
    { icon: 'restaurant', label: '오늘 추천' },
    { icon: 'history', label: '히스토리' },
    { icon: 'settings', label: '설정' },
  ];
  return (
    <div style={{ flex: '0 0 auto', height: 64, display: 'flex', borderTop: `1px solid ${MF.line}`,
      background: MF.surface, paddingBottom: 2 }}>
      {tabs.map((t, i) => {
        const on = i === active;
        return (
          <div key={t.label} style={{ flex: 1, display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center', gap: 3 }}>
            <div style={{ width: 52, height: 26, borderRadius: 13, display: 'flex', alignItems: 'center',
              justifyContent: 'center', background: on ? MF.brandTint : 'transparent' }}>
              <MIcon name={t.icon} size={21} fill={on ? 1 : 0} weight={on ? 500 : 400}
                color={on ? MF.brandInk : MF.ink500} />
            </div>
            <span style={{ fontSize: 10.5, fontWeight: on ? 700 : 500,
              color: on ? MF.brandInk : MF.ink500 }}>{t.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ── 배너 광고 영역 (56px 고정) ─────────────────────────
function AdBanner() {
  return (
    <div style={{ flex: '0 0 auto', margin: '8px 16px 10px', height: 56, borderRadius: 12,
      border: `1px dashed ${MF.line}`, background: 'repeating-linear-gradient(135deg,#EFF4E4 0 10px,#E7EFD7 10px 20px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
      <MIcon name="ad" size={15} color={MF.ink400} />
      <span style={{ fontSize: 11.5, fontWeight: 600, color: MF.ink400, letterSpacing: '0.3px',
        fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace' }}>배너 광고 영역</span>
    </div>
  );
}

// ── 신선도 표현 원자들 ────────────────────────────────
function FreshDot({ kind, size = 9 }) {
  const f = FRESH[kind];
  return <span style={{ width: size, height: size, borderRadius: size, background: f.main,
    display: 'inline-block', flex: '0 0 auto' }} />;
}
function FreshChip({ kind, label }) {
  const f = FRESH[kind];
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, height: 22, padding: '0 9px 0 8px',
      borderRadius: 11, background: f.tint, color: f.ink, fontSize: 11.5, fontWeight: 700, flex: '0 0 auto',
      whiteSpace: 'nowrap' }}>
      <FreshDot kind={kind} size={7} />{label || f.name}
    </span>
  );
}

// ── 점유율 게이지 (3종) ───────────────────────────────
function GaugeBar({ progress }) {
  const over = progress > 0.66;
  const col = over ? MF.gaugeOver : MF.gaugeOk;
  return (
    <div style={{ background: MF.surface, border: `1px solid ${MF.line}`, borderRadius: 18, padding: 16 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
        <span style={{ fontSize: 13.5, fontWeight: 700, color: MF.ink700 }}>냉장고 점유율</span>
        <span style={{ fontSize: 13, fontWeight: 700, color: over ? MF.soon.ink : MF.gaugeOk }}>
          {over ? '목표 초과' : '목표 이내'}</span>
      </div>
      <div style={{ display: 'flex', alignItems: 'flex-end', gap: 10 }}>
        <span style={{ fontSize: 30, fontWeight: 800, color: MF.ink900, lineHeight: 0.9, letterSpacing: '-1px' }}>
          {Math.round(progress * 100)}<span style={{ fontSize: 16, fontWeight: 700 }}>%</span></span>
        <div style={{ flex: 1, paddingBottom: 4 }}>
          <div style={{ height: 10, borderRadius: 6, background: MF.sunken, position: 'relative', overflow: 'hidden' }}>
            <div style={{ position: 'absolute', inset: 0, width: `${Math.min(progress, 1) * 100}%`,
              background: col, borderRadius: 6 }} />
            <div style={{ position: 'absolute', top: -2, bottom: -2, left: '66%', width: 2,
              background: MF.ink400, opacity: 0.5 }} />
          </div>
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 4 }}>
            <span style={{ fontSize: 10.5, color: MF.ink500, fontWeight: 600 }}>목표 2/3</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function GaugeRing({ progress }) {
  const over = progress > 0.66;
  const col = over ? MF.gaugeOver : MF.gaugeOk;
  const R = 30, C = 2 * Math.PI * R, p = Math.min(progress, 1);
  return (
    <div style={{ background: MF.surface, border: `1px solid ${MF.line}`, borderRadius: 18, padding: 16,
      display: 'flex', alignItems: 'center', gap: 16 }}>
      <div style={{ position: 'relative', width: 76, height: 76, flex: '0 0 auto' }}>
        <svg width="76" height="76" viewBox="0 0 76 76">
          <circle cx="38" cy="38" r={R} fill="none" stroke={MF.sunken} strokeWidth="9" />
          <circle cx="38" cy="38" r={R} fill="none" stroke={col} strokeWidth="9" strokeLinecap="round"
            strokeDasharray={C} strokeDashoffset={C * (1 - p)} transform="rotate(-90 38 38)" />
        </svg>
        <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center' }}>
          <span style={{ fontSize: 20, fontWeight: 800, color: MF.ink900, lineHeight: 1 }}>{Math.round(progress * 100)}%</span>
        </div>
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 700, color: MF.ink900, marginBottom: 3 }}>냉장고 점유율</div>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5, height: 22, padding: '0 9px',
          borderRadius: 11, background: over ? MF.soon.tint : '#E2F2EE',
          color: over ? MF.soon.ink : '#1F7A68', fontSize: 11.5, fontWeight: 700 }}>
          <MIcon name={over ? 'warning' : 'check_circle'} size={13} fill={1} />
          {over ? '주의 · 목표(2/3) 초과' : '목표 이내'}
        </div>
      </div>
    </div>
  );
}

function GaugeSegments({ progress, segments = 18 }) {
  const over = progress > 0.66;
  const col = over ? MF.gaugeOver : MF.gaugeOk;
  const filled = Math.round(Math.min(progress, 1) * segments);
  const target = Math.round((2 / 3) * segments);
  const slack = Math.max(target - filled, 0);
  return (
    <div style={{ background: MF.surface, border: `1px solid ${MF.line}`, borderRadius: 18, padding: 16 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 11 }}>
        <span style={{ fontSize: 14, fontWeight: 700, color: MF.ink900 }}>
          냉장고 점유율 <span style={{ color: over ? MF.soon.ink : MF.gaugeOk }}>{Math.round(progress * 100)}%</span></span>
        <span style={{ fontSize: 11.5, fontWeight: 700, color: MF.ink500 }}>{TOTAL_QTY} / 30</span>
      </div>
      <div style={{ display: 'flex', gap: 3 }}>
        {Array.from({ length: segments }).map((_, i) => (
          <div key={i} style={{ flex: 1, height: 16, borderRadius: 3,
            background: i < filled ? col : MF.sunken,
            boxShadow: i + 1 === target ? `inset 0 0 0 1.5px ${MF.ink400}` : 'none' }} />
        ))}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginTop: 9 }}>
        <MIcon name={over ? 'warning' : 'check_circle'} size={14} fill={1} color={over ? MF.soon.main : MF.gaugeOk} />
        <span style={{ fontSize: 11.5, fontWeight: 600, color: over ? MF.soon.ink : MF.ink500 }}>
          {over ? '목표(2/3 칸) 초과' : slack > 0 ? `목표(2/3 칸)까지 ${slack}칸 여유` : '목표(2/3 칸)에 근접'}</span>
      </div>
    </div>
  );
}

// ── 버튼 ──────────────────────────────────────────────
function PrimaryBtn({ icon, children, full }) {
  return (
    <button style={{ flex: full ? 1 : '0 0 auto', height: 48, border: 'none', borderRadius: 14,
      background: MF.brand, color: '#fff', fontSize: 14.5, fontWeight: 700, fontFamily: 'inherit',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 7, cursor: 'pointer',
      boxShadow: '0 6px 16px -8px rgba(214,89,47,.7)' }}>
      {icon && <MIcon name={icon} size={19} fill={1} />}{children}
    </button>
  );
}
function OutlineBtn({ icon, children, full }) {
  return (
    <button style={{ flex: full ? 1 : '0 0 auto', height: 48, borderRadius: 14,
      border: `1.5px solid ${MF.line}`, background: MF.surface, color: MF.ink900, fontSize: 14.5,
      fontWeight: 700, fontFamily: 'inherit', display: 'inline-flex', alignItems: 'center',
      justifyContent: 'center', gap: 7, cursor: 'pointer' }}>
      {icon && <MIcon name={icon} size={19} color={MF.ink700} />}{children}
    </button>
  );
}

// ── 화면 헤더 ─────────────────────────────────────────
function AppHeader({ title = '하루한칸', action = 'tune' }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '4px 16px 6px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span style={{ fontSize: 23, fontWeight: 800, color: MF.ink900, letterSpacing: '-0.6px' }}>{title}</span>
      </div>
      <div style={{ width: 40, height: 40, borderRadius: 12, background: MF.surface,
        border: `1px solid ${MF.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <MIcon name={action} size={21} color={MF.ink700} />
      </div>
    </div>
  );
}

Object.assign(window, {
  MF, FRESH, STORE, MIcon, freshnessOf, ddayLabel, subLine,
  SAMPLE_FRIDGES, SAMPLE_ITEMS, TOTAL_QTY, GAUGE, SORTED,
  StatusBar, BottomNav, AdBanner, FreshDot, FreshChip,
  GaugeBar, GaugeRing, GaugeSegments, PrimaryBtn, OutlineBtn, AppHeader,
});
