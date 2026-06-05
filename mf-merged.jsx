/* 하루한칸 — 통합안 v2
   홈(작동 토글 D1↔D2, localStorage 지속) · 상세 팝업 · 추가/수정 시트.
   window로 export. */

// ── 작은 타일 (탭 → 상세 팝업) ─────────────────────────
function SmallTile({ item }) {
  const k = freshnessOf(item), f = FRESH[k];
  return (
    <div style={{ background: MF.surface, borderRadius: 11, border: `1px solid ${MF.lineSoft}`,
      borderTop: `3px solid ${f.main}`, padding: '7px 9px 8px', boxShadow: '0 1px 3px rgba(43,33,27,.05)',
      cursor: 'pointer', minWidth: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
        <FreshDot kind={k} size={7} />
        <span style={{ fontSize: 11, fontWeight: 800, color: f.ink }}>
          {item.dday != null ? ddayLabel(item.dday) : `${item.storageDays}일`}</span>
      </div>
      <div style={{ fontSize: 13, fontWeight: 700, color: MF.ink900, whiteSpace: 'nowrap',
        overflow: 'hidden', textOverflow: 'ellipsis' }}>{item.name}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 3 }}>
        <MIcon name={item.type === 'ing' ? 'nutrition' : 'rice_bowl'} size={12} color={MF.ink400} />
        <span style={{ fontSize: 11, fontWeight: 600, color: MF.ink500 }}>{item.quantity}개</span>
        {item.store === 'frozen'
          ? <MIcon name="ac_unit" size={12} color={MF.frost} style={{ marginLeft: 'auto' }} />
          : (item.est && item.dday != null &&
            <span style={{ fontSize: 9.5, fontWeight: 700, color: MF.ink400, marginLeft: 'auto' }}>예상</span>)}
      </div>
    </div>
  );
}
function TileGrid({ items }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8 }}>
      {items.map((it) => <SmallTile key={it.name} item={it} />)}
    </div>
  );
}

// ── 작동 토글 (임박순 ↔ 칸별) ─────────────────────────
function GroupToggle({ mode, onChange }) {
  return (
    <div style={{ display: 'flex', background: MF.sunken, borderRadius: 9, padding: 3, gap: 2 }}>
      {[['urgency', '임박순'], ['type', '칸별']].map(([k, l]) => {
        const on = k === mode;
        return (
          <button key={k} onClick={() => onChange && onChange(k)} style={{ border: 'none', cursor: 'pointer',
            fontFamily: 'inherit', fontSize: 11.5, fontWeight: 700, padding: '5px 12px', borderRadius: 7,
            background: on ? MF.surface : 'transparent', color: on ? MF.ink900 : MF.ink500,
            boxShadow: on ? '0 1px 2px rgba(43,33,27,.12)' : 'none', transition: 'all .15s' }}>{l}</button>
        );
      })}
    </div>
  );
}

// ── 인사이드 두 모드 ──────────────────────────────────
function Zone({ kind, title, items }) {
  const f = FRESH[kind];
  if (!items.length) return null;
  return (
    <div style={{ marginBottom: 15 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 9 }}>
        <span style={{ width: 9, height: 9, borderRadius: 9, background: f.main }} />
        <span style={{ fontSize: 13.5, fontWeight: 800, color: MF.ink900 }}>{title}</span>
        <span style={{ fontSize: 11, fontWeight: 800, color: f.ink, background: f.tint,
          borderRadius: 9, padding: '1px 7px' }}>{items.length}</span>
      </div>
      <TileGrid items={items} />
    </div>
  );
}
function UrgencyZones() {
  const z1 = SORTED.filter((i) => ['urgent', 'soon'].includes(freshnessOf(i)));
  const z2 = SORTED.filter((i) => freshnessOf(i) === 'caution');
  const z3 = SORTED.filter((i) => freshnessOf(i) === 'fresh');
  return (
    <React.Fragment>
      <Zone kind="urgent" title="지금 먹어요" items={z1} />
      <Zone kind="caution" title="이번 주 안에" items={z2} />
      <Zone kind="fresh" title="여유 있어요" items={z3} />
    </React.Fragment>
  );
}
function StorageShelf({ store, items }) {
  const s = STORE[store];
  const frozen = store === 'frozen';
  return (
    <div style={{ marginBottom: 15 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 9 }}>
        <span style={{ width: 26, height: 26, borderRadius: 8, display: 'flex', alignItems: 'center',
          justifyContent: 'center', background: frozen ? MF.frostTint : MF.sunken }}>
          <MIcon name={s.icon} size={16} fill={frozen ? 1 : 0} color={frozen ? MF.frost : MF.ink700} />
        </span>
        <span style={{ fontSize: 13.5, fontWeight: 800, color: MF.ink900 }}>{s.name}칸</span>
        <span style={{ fontSize: 11, fontWeight: 800, color: frozen ? MF.frostInk : MF.ink500,
          background: frozen ? MF.frostTint : MF.sunken, borderRadius: 9, padding: '1px 7px' }}>{items.length}</span>
        <div style={{ flex: 1 }} />
        <MIcon name="add_circle" size={19} color={MF.brand} />
      </div>
      <TileGrid items={items} />
    </div>
  );
}
function StorageShelves() {
  const cold = SORTED.filter((i) => (i.store || 'cold') === 'cold');
  const frozen = SORTED.filter((i) => i.store === 'frozen');
  const room = SORTED.filter((i) => i.store === 'room');
  return (
    <React.Fragment>
      <StorageShelf store="cold" items={cold} />
      {frozen.length > 0 && <StorageShelf store="frozen" items={frozen} />}
      {room.length > 0 && <StorageShelf store="room" items={room} />}
    </React.Fragment>
  );
}

// ── 빈 재고 상태 ──────────────────────────────────────
function EmptyInventory() {
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', alignItems: 'center',
      justifyContent: 'center', padding: '0 32px', textAlign: 'center' }}>
      <div style={{ width: 92, height: 92, borderRadius: 26, background: MF.brandTint, display: 'flex',
        alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}>
        <MIcon name="kitchen" size={44} color={MF.brand} />
      </div>
      <div style={{ fontSize: 17, fontWeight: 800, color: MF.ink900, marginBottom: 7 }}>냉장고가 비어 있어요</div>
      <div style={{ fontSize: 13.5, fontWeight: 500, color: MF.ink500, lineHeight: 1.5, marginBottom: 20 }}>
        첫 재료를 추가하면 유통기한을 자동으로<br />챙겨주고, 오늘 끼니도 추천해 드려요.</div>
      <PrimaryBtn icon="add">첫 재료 추가하기</PrimaryBtn>
    </div>
  );
}

// ── 홈 (작동 토글 + 마지막 설정 지속) ─────────────────
function HomeMerged({ gauge = GAUGE, empty = false }) {
  const [mode, setMode] = React.useState(() => {
    try { return localStorage.getItem('mf_group_mode') || 'urgency'; } catch (e) { return 'urgency'; }
  });
  React.useEffect(() => { try { localStorage.setItem('mf_group_mode', mode); } catch (e) {} }, [mode]);
  return (
    <Screen active={0}>
      <AppHeader />
      <div style={{ marginTop: 6 }}><FridgeChips /></div>
      <div style={{ padding: '14px 16px 0' }}><GaugeBar progress={empty ? 0 : gauge} /></div>
      <div style={{ display: 'flex', gap: 8, padding: '12px 16px 0' }}>
        <PrimaryBtn icon="add" full>식재료 추가</PrimaryBtn>
        <OutlineBtn icon="restaurant" full>오늘 추천</OutlineBtn>
      </div>
      {empty ? <EmptyInventory /> : (
        <React.Fragment>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '15px 16px 10px' }}>
            <span style={{ fontSize: 16, fontWeight: 800, color: MF.ink900 }}>
              재고 <span style={{ color: MF.brand }}>{TOTAL_QTY}</span></span>
            <GroupToggle mode={mode} onChange={setMode} />
          </div>
          <div style={{ flex: 1, minHeight: 0, overflow: 'hidden', padding: '0 16px' }}>
            {mode === 'urgency' ? <UrgencyZones /> : <StorageShelves />}
          </div>
        </React.Fragment>
      )}
    </Screen>
  );
}

// ── 상세 팝업 (위급 칩 제거 · 보정 제거 · 수정으로 일원화) ──
function InfoRow({ label, children, top }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '13px 0', borderTop: top ? `1px solid ${MF.lineSoft}` : 'none' }}>
      <span style={{ fontSize: 13.5, fontWeight: 600, color: MF.ink500 }}>{label}</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>{children}</div>
    </div>
  );
}
function SheetShell({ children }) {
  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <HomeMerged />
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(24,16,10,.46)' }} />
      {children}
    </div>
  );
}
function ItemDetailSheet() {
  const item = SAMPLE_ITEMS[0]; // 손두부 · D-1 · 위급 · 예상
  const f = FRESH.urgent;
  return (
    <SheetShell>
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, background: MF.surface,
        borderRadius: '24px 24px 0 0', padding: '10px 20px 22px',
        boxShadow: '0 -12px 40px rgba(24,16,10,.25)', fontFamily: "'Pretendard', sans-serif" }}>
        <div style={{ width: 38, height: 4, borderRadius: 4, background: MF.line, margin: '0 auto 14px' }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginBottom: 14 }}>
          <span style={{ width: 11, height: 11, borderRadius: 11, background: f.main }} />
          <span style={{ fontSize: 21, fontWeight: 800, color: MF.ink900 }}>{item.name}</span>
          <div style={{ flex: 1 }} />
          <MIcon name="close" size={22} color={MF.ink400} />
        </div>

        {/* 유통기한 — 정보 표시 (편집은 '수정'에서) */}
        <div style={{ background: f.tint, borderRadius: 16, padding: '14px 16px' }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: f.ink, marginBottom: 3 }}>유통기한까지</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
            <span style={{ fontSize: 26, fontWeight: 800, color: MF.ink900, letterSpacing: '-0.5px' }}>D-1</span>
            <span style={{ fontSize: 12, fontWeight: 700, color: f.ink, background: '#fff',
              borderRadius: 8, padding: '2px 7px' }}>예상값</span>
          </div>
          <div style={{ fontSize: 11.5, fontWeight: 500, color: MF.ink500, marginTop: 4 }}>
            이름·유형·시작일로 자동 추정 · 정확한 날짜는 ‘수정’에서 직접 입력</div>
        </div>

        <InfoRow label="수량" top>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, background: MF.sunken,
            borderRadius: 11, padding: '5px 6px' }}>
            <MIcon name="remove" size={18} color={MF.ink500} />
            <span style={{ fontSize: 15, fontWeight: 800, color: MF.ink900, minWidth: 34, textAlign: 'center' }}>2개</span>
            <MIcon name="add" size={18} color={MF.brand} />
          </div>
        </InfoRow>
        <InfoRow label="유형" top>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontSize: 14, fontWeight: 700, color: MF.ink900 }}>
            <MIcon name="nutrition" size={16} color={MF.ink500} />식재료</span>
        </InfoRow>
        <InfoRow label="보관" top>
          <span style={{ fontSize: 14, fontWeight: 700, color: MF.ink900 }}>4일째 · 6월 1일 시작</span>
        </InfoRow>

        {/* 액션: 소진(주행동) · 수정 · 폐기 */}
        <div style={{ display: 'flex', gap: 8, marginTop: 16 }}>
          <PrimaryBtn icon="check" full>다 먹었어요 · 소진</PrimaryBtn>
        </div>
        <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
          <OutlineBtn icon="edit" full>수정</OutlineBtn>
          <button style={{ flex: 1, height: 48, borderRadius: 14, border: `1.5px solid ${MF.line}`,
            background: MF.surface, color: f.ink, fontSize: 14.5, fontWeight: 700, fontFamily: 'inherit',
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 7, cursor: 'pointer' }}>
            <MIcon name="delete" size={19} color={f.main} />폐기
          </button>
        </div>
      </div>
    </SheetShell>
  );
}

// ── 추가/수정 시트 (5.1) — 예상 유통기한 보정 UX ───────
function FieldBox({ label, children }) {
  return (
    <div style={{ marginBottom: 12 }}>
      <div style={{ fontSize: 12, fontWeight: 700, color: MF.ink500, marginBottom: 6 }}>{label}</div>
      {children}
    </div>
  );
}
function AddEditSheet() {
  return (
    <SheetShell>
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, background: MF.surface,
        borderRadius: '24px 24px 0 0', padding: '10px 20px 20px',
        boxShadow: '0 -12px 40px rgba(24,16,10,.25)', fontFamily: "'Pretendard', sans-serif" }}>
        <div style={{ width: 38, height: 4, borderRadius: 4, background: MF.line, margin: '0 auto 14px' }} />
        <div style={{ fontSize: 19, fontWeight: 800, color: MF.ink900, marginBottom: 16 }}>식재료 수정</div>

        <FieldBox label="이름">
          <div style={{ height: 46, borderRadius: 12, border: `1.5px solid ${MF.line}`, background: MF.surface,
            display: 'flex', alignItems: 'center', padding: '0 13px', fontSize: 15, fontWeight: 700, color: MF.ink900 }}>손두부</div>
        </FieldBox>

        <div style={{ display: 'flex', gap: 10 }}>
          <div style={{ flex: '0 0 auto' }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: MF.ink500, marginBottom: 6 }}>수량</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, height: 46, background: MF.sunken,
              borderRadius: 12, padding: '0 8px' }}>
              <MIcon name="remove" size={19} color={MF.ink500} />
              <span style={{ fontSize: 16, fontWeight: 800, color: MF.ink900, minWidth: 22, textAlign: 'center' }}>2</span>
              <MIcon name="add" size={19} color={MF.brand} />
            </div>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: MF.ink500, marginBottom: 6 }}>유형</div>
            <div style={{ display: 'flex', background: MF.sunken, borderRadius: 12, padding: 4, gap: 3, height: 46 }}>
              {[['식재료', true], ['반찬', false]].map(([l, on]) => (
                <div key={l} style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
                  borderRadius: 9, fontSize: 14, fontWeight: 700, background: on ? MF.surface : 'transparent',
                  color: on ? MF.ink900 : MF.ink500, boxShadow: on ? '0 1px 2px rgba(43,33,27,.12)' : 'none' }}>{l}</div>
              ))}
            </div>
          </div>
        </div>

        <div style={{ height: 12 }} />
        <FieldBox label="보관 방식">
          <div style={{ display: 'flex', background: MF.sunken, borderRadius: 12, padding: 4, gap: 3, height: 46 }}>
            {['cold', 'frozen', 'room'].map((k) => {
              const s = STORE[k], on = k === 'cold';
              const frozen = k === 'frozen';
              return (
                <div key={k} style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5,
                  borderRadius: 9, fontSize: 13.5, fontWeight: 700, background: on ? MF.surface : 'transparent',
                  color: on ? MF.ink900 : MF.ink500, boxShadow: on ? '0 1px 2px rgba(43,33,27,.12)' : 'none' }}>
                  <MIcon name={s.icon} size={15} fill={on && frozen ? 1 : 0}
                    color={on ? (frozen ? MF.frost : MF.ink700) : MF.ink400} />{s.name}
                </div>
              );
            })}
          </div>
        </FieldBox>
        <FieldBox label="보관 시작일">
          <div style={{ height: 46, borderRadius: 12, border: `1.5px solid ${MF.line}`, display: 'flex',
            alignItems: 'center', padding: '0 13px', justifyContent: 'space-between' }}>
            <span style={{ fontSize: 15, fontWeight: 700, color: MF.ink900 }}>2026년 6월 1일</span>
            <MIcon name="calendar_today" size={18} color={MF.ink500} />
          </div>
        </FieldBox>

        {/* 유통기한 — 예상 미리보기 + 직접 입력 (핵심 UX) */}
        <div style={{ fontSize: 12, fontWeight: 700, color: MF.ink500, marginBottom: 6 }}>유통기한 (선택)</div>
        <div style={{ borderRadius: 14, border: `1.5px solid ${MF.brand}`, background: MF.brandTint,
          padding: '12px 14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
              <span style={{ fontSize: 18, fontWeight: 800, color: MF.ink900 }}>2026년 6월 5일</span>
              <span style={{ fontSize: 11.5, fontWeight: 800, color: MF.brandInk, background: '#fff',
                borderRadius: 8, padding: '2px 8px' }}>예상·선택</span>
            </div>
            <div style={{ fontSize: 11.5, fontWeight: 500, color: MF.ink700, marginTop: 4 }}>
              자동 추정값이에요. 비워둬도 괜찮아요.</div>
          </div>
          <button style={{ height: 38, padding: '0 13px', borderRadius: 11, border: 'none',
            background: MF.brand, color: '#fff', fontSize: 12.5, fontWeight: 800, fontFamily: 'inherit',
            display: 'inline-flex', alignItems: 'center', gap: 5, cursor: 'pointer' }}>
            <MIcon name="edit_calendar" size={16} />직접 입력
          </button>
        </div>

        <div style={{ marginTop: 18 }}><PrimaryBtn icon="check" full>저장</PrimaryBtn></div>
      </div>
    </SheetShell>
  );
}

Object.assign(window, {
  SmallTile, TileGrid, GroupToggle, Zone, UrgencyZones, StorageShelf, StorageShelves,
  EmptyInventory, HomeMerged, InfoRow, SheetShell, ItemDetailSheet, FieldBox, AddEditSheet,
});
