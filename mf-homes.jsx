/* 하루한칸 — 홈 3방향 (A/B/C) · 화면 래퍼. window로 export.
   mf-atoms.jsx 의 전역들을 사용. */

// ── 공통 화면 래퍼 (390 폭, 프레임 없음) ───────────────
function Screen({ children, active = 0, banner = true }) {
  return (
    <div style={{ width: '100%', height: '100%', background: MF.bg, display: 'flex',
      flexDirection: 'column', fontFamily: "'Pretendard', sans-serif", color: MF.ink900 }}>
      <StatusBar tone="dark" />
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>{children}</div>
      {banner && <AdBanner />}
      <BottomNav active={active} />
    </div>
  );
}

// ════════════════════════════════════════════════════════
//  방향 A — 따뜻한 카드형 · 좌측 신호바
// ════════════════════════════════════════════════════════
function FridgeChips({ selected = 'f1' }) {
  return (
    <div style={{ display: 'flex', gap: 8, padding: '2px 16px 0', overflow: 'hidden' }}>
      {SAMPLE_FRIDGES.map((f) => {
        const on = f.id === selected;
        return (
          <div key={f.id} style={{ flex: '0 0 auto', height: 36, padding: '0 15px', borderRadius: 18,
            display: 'flex', alignItems: 'center', gap: 6,
            background: on ? MF.brand : MF.surface, color: on ? '#fff' : MF.ink700,
            border: on ? 'none' : `1px solid ${MF.line}`, fontSize: 13.5, fontWeight: 700 }}>
            {on && <MIcon name="kitchen" size={16} fill={1} />}{f.name}
          </div>
        );
      })}
    </div>
  );
}
function ItemRowA({ item }) {
  const k = freshnessOf(item), f = FRESH[k];
  return (
    <div style={{ display: 'flex', alignItems: 'stretch', background: MF.surface, borderRadius: 14,
      border: `1px solid ${MF.lineSoft}`, overflow: 'hidden' }}>
      <div style={{ width: 5, background: f.main, flex: '0 0 auto' }} />
      <div style={{ flex: 1, minWidth: 0, padding: '11px 12px 11px 13px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 3 }}>
          <span style={{ fontSize: 15.5, fontWeight: 700, color: MF.ink900 }}>{item.name}</span>
          <FreshChip kind={k} label={item.dday != null ? ddayLabel(item.dday) : f.name} />
          {item.est && <span style={{ fontSize: 10, fontWeight: 700, color: MF.ink400 }}>예상</span>}
        </div>
        <div style={{ fontSize: 12, color: MF.ink500, fontWeight: 500 }}>{subLine(item)}</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 2, paddingRight: 8 }}>
        <MIcon name="edit" size={18} color={MF.ink400} />
        <MIcon name="delete" size={18} color={MF.ink400} />
      </div>
    </div>
  );
}
function HomeA() {
  return (
    <Screen active={0}>
      <AppHeader />
      <div style={{ marginTop: 6 }}><FridgeChips /></div>
      <div style={{ padding: '14px 16px 0' }}><GaugeBar progress={GAUGE} /></div>
      <div style={{ display: 'flex', gap: 8, padding: '12px 16px 0' }}>
        <PrimaryBtn icon="add" full>식재료 추가</PrimaryBtn>
        <OutlineBtn icon="restaurant" full>오늘 추천</OutlineBtn>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '16px 16px 8px' }}>
        <span style={{ fontSize: 16, fontWeight: 800, color: MF.ink900 }}>재고 <span style={{ color: MF.brand }}>{TOTAL_QTY}</span></span>
        <span style={{ fontSize: 12, fontWeight: 600, color: MF.ink500, display: 'inline-flex', alignItems: 'center', gap: 3 }}>
          급한 순<MIcon name="swap_vert" size={15} color={MF.ink500} /></span>
      </div>
      <div style={{ flex: 1, minHeight: 0, overflow: 'hidden', padding: '0 16px',
        display: 'flex', flexDirection: 'column', gap: 8 }}>
        {SORTED.slice(0, 4).map((it) => <ItemRowA key={it.name} item={it} />)}
        <div style={{ textAlign: 'center', fontSize: 12, fontWeight: 600, color: MF.ink400, paddingTop: 2 }}>
          + {SORTED.length - 4}개 더</div>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════
//  방향 B — 냉장고 '칸' 공간화 · 선반 메타포
// ════════════════════════════════════════════════════════
function FridgePicker({ selected = 'f1' }) {
  return (
    <div style={{ display: 'flex', gap: 9, padding: '2px 16px 0', overflow: 'hidden' }}>
      {SAMPLE_FRIDGES.map((f) => {
        const on = f.id === selected;
        return (
          <div key={f.id} style={{ flex: on ? '0 0 auto' : '0 0 auto', minWidth: on ? 132 : 96, height: 60,
            borderRadius: 16, padding: '0 14px', display: 'flex', alignItems: 'center', gap: 9,
            background: on ? MF.ink900 : MF.surface, border: on ? 'none' : `1px solid ${MF.line}` }}>
            <div style={{ width: 30, height: 36, borderRadius: 5, flex: '0 0 auto',
              background: on ? 'rgba(255,255,255,.14)' : MF.sunken, position: 'relative' }}>
              <div style={{ position: 'absolute', left: 5, right: 5, top: 14, height: 1.5,
                background: on ? 'rgba(255,255,255,.4)' : MF.line }} />
            </div>
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 13.5, fontWeight: 700, color: on ? '#fff' : MF.ink900,
                whiteSpace: 'nowrap' }}>{f.name}</div>
              {on && <div style={{ fontSize: 11, fontWeight: 600, color: 'rgba(255,255,255,.6)', marginTop: 1 }}>선택됨 · {TOTAL_QTY}개</div>}
            </div>
          </div>
        );
      })}
    </div>
  );
}
function ShelfTile({ item }) {
  const k = freshnessOf(item), f = FRESH[k];
  return (
    <div style={{ flex: '0 0 auto', width: 96, background: MF.surface, borderRadius: 11,
      border: `1px solid ${MF.lineSoft}`, borderTop: `3px solid ${f.main}`, padding: '8px 9px 9px',
      boxShadow: '0 2px 5px -3px rgba(43,33,27,.25)' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 5 }}>
        <FreshDot kind={k} size={8} />
        <span style={{ fontSize: 10.5, fontWeight: 800, color: f.ink }}>
          {item.dday != null ? ddayLabel(item.dday) : `${item.storageDays}일`}</span>
      </div>
      <div style={{ fontSize: 13, fontWeight: 700, color: MF.ink900, whiteSpace: 'nowrap', overflow: 'hidden',
        textOverflow: 'ellipsis' }}>{item.name}</div>
      <div style={{ fontSize: 11, fontWeight: 600, color: MF.ink500, marginTop: 1 }}>{item.quantity}개</div>
    </div>
  );
}
function Shelf({ title, count, items, icon }) {
  return (
    <div style={{ marginBottom: 12 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '0 2px 7px' }}>
        <MIcon name={icon} size={16} color={MF.ink700} />
        <span style={{ fontSize: 13, fontWeight: 800, color: MF.ink900 }}>{title}</span>
        <span style={{ fontSize: 11.5, fontWeight: 700, color: MF.ink400 }}>{count}</span>
        <div style={{ flex: 1 }} />
        <MIcon name="add_circle" size={19} fill={0} color={MF.brand} />
      </div>
      <div style={{ position: 'relative', padding: '2px 2px 0' }}>
        <div style={{ display: 'flex', gap: 8, overflow: 'hidden' }}>
          {items.map((it) => <ShelfTile key={it.name} item={it} />)}
          {count > items.length && (
            <div style={{ flex: '0 0 auto', width: 44, alignSelf: 'stretch', borderRadius: 11,
              border: `1.5px dashed ${MF.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 12, fontWeight: 800, color: MF.ink400 }}>+{count - items.length}</div>
          )}
        </div>
        {/* 선반 받침 */}
        <div style={{ height: 7, marginTop: 5, borderRadius: 4,
          background: 'linear-gradient(180deg,#EADFD3,#DBCcBC)',
          boxShadow: '0 4px 8px -4px rgba(43,33,27,.3)' }} />
      </div>
    </div>
  );
}
function HomeB() {
  const ing = SAMPLE_ITEMS.filter((i) => i.type === 'ing');
  const side = SAMPLE_ITEMS.filter((i) => i.type === 'side');
  const ingSorted = [...ing].sort((a, b) => RANK[freshnessOf(a)] - RANK[freshnessOf(b)]);
  return (
    <Screen active={0}>
      <AppHeader />
      <div style={{ marginTop: 4 }}><FridgePicker /></div>
      <div style={{ padding: '12px 16px 0' }}><GaugeSegments progress={GAUGE} /></div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, padding: '15px 18px 9px' }}>
        <MIcon name="shelves" size={17} color={MF.ink700} />
        <span style={{ fontSize: 13.5, fontWeight: 800, color: MF.ink900 }}>냉장고 안</span>
        <span style={{ fontSize: 11.5, fontWeight: 600, color: MF.ink500 }}>· 칸별로 정리</span>
      </div>
      <div style={{ flex: 1, minHeight: 0, overflow: 'hidden', padding: '0 16px' }}>
        <Shelf icon="nutrition" title="식재료칸" count={ing.length} items={ingSorted.slice(0, 3)} />
        <Shelf icon="rice_bowl" title="반찬칸" count={side.length} items={side.slice(0, 2)} />
      </div>
      <div style={{ display: 'flex', gap: 8, padding: '4px 16px 4px' }}>
        <PrimaryBtn icon="add" full>식재료 추가</PrimaryBtn>
        <OutlineBtn icon="restaurant" full>오늘 추천</OutlineBtn>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════
//  방향 C — 미니멀 모던 · 틴트 + 링 게이지
// ════════════════════════════════════════════════════════
function FridgeSegment({ selected = 'f1' }) {
  return (
    <div style={{ margin: '2px 16px 0', padding: 4, background: MF.sunken, borderRadius: 13,
      display: 'flex', gap: 3 }}>
      {SAMPLE_FRIDGES.map((f) => {
        const on = f.id === selected;
        return (
          <div key={f.id} style={{ flex: 1, height: 34, borderRadius: 10, display: 'flex',
            alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 700,
            background: on ? MF.surface : 'transparent', color: on ? MF.ink900 : MF.ink500,
            boxShadow: on ? '0 1px 3px rgba(43,33,27,.12)' : 'none' }}>{f.name}</div>
        );
      })}
    </div>
  );
}
function ItemRowC({ item, last }) {
  const k = freshnessOf(item), f = FRESH[k];
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 4px',
      borderBottom: last ? 'none' : `1px solid ${MF.lineSoft}` }}>
      <div style={{ width: 38, height: 38, borderRadius: 11, background: f.tint, flex: '0 0 auto',
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <FreshDot kind={k} size={11} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15.5, fontWeight: 700, color: MF.ink900 }}>{item.name}</div>
        <div style={{ fontSize: 12, color: MF.ink500, fontWeight: 500, marginTop: 1 }}>
          수량 {item.quantity}개 · 보관 {item.storageDays}일</div>
      </div>
      <div style={{ textAlign: 'right' }}>
        <div style={{ fontSize: 13.5, fontWeight: 800, color: f.ink }}>
          {item.dday != null ? ddayLabel(item.dday) : f.name}</div>
        {item.est && item.dday != null && <div style={{ fontSize: 10, fontWeight: 700, color: MF.ink400, marginTop: 1 }}>예상</div>}
      </div>
    </div>
  );
}
function HomeC() {
  return (
    <Screen active={0}>
      <div style={{ padding: '2px 0 4px' }}><AppHeader /></div>
      <FridgeSegment />
      <div style={{ padding: '14px 16px 0' }}><GaugeRing progress={GAUGE} /></div>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '18px 18px 2px' }}>
        <span style={{ fontSize: 16, fontWeight: 800, color: MF.ink900 }}>재고 {TOTAL_QTY}</span>
        <span style={{ fontSize: 13, fontWeight: 700, color: MF.brand, display: 'inline-flex', alignItems: 'center', gap: 3 }}>
          <MIcon name="add" size={17} color={MF.brand} />추가</span>
      </div>
      <div style={{ flex: 1, minHeight: 0, overflow: 'hidden', padding: '0 18px' }}>
        {SORTED.slice(0, 5).map((it, i) => <ItemRowC key={it.name} item={it} last={i === 4} />)}
      </div>
      <div style={{ padding: '6px 16px 4px' }}>
        <PrimaryBtn icon="restaurant" full>오늘 추천 보기</PrimaryBtn>
      </div>
    </Screen>
  );
}

window.RANK = window.RANK || { urgent: 0, soon: 1, caution: 2, fresh: 3 };
Object.assign(window, { Screen, HomeA, HomeB, HomeC });
