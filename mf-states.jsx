/* 하루한칸 — 모달: 냉장고 관리 · 데이터 병합 · 만족도. window로 export. */

function CenterDialog({ children, maxW = 320 }) {
  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <HomeMerged />
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(24,16,10,.5)', display: 'flex',
        alignItems: 'center', justifyContent: 'center', padding: 24 }}>
        <div style={{ width: '100%', maxWidth: maxW, background: MF.surface, borderRadius: 22, padding: 22,
          fontFamily: "'Pretendard', sans-serif", boxShadow: '0 24px 60px rgba(24,16,10,.35)' }}>{children}</div>
      </div>
    </div>
  );
}

// ── 냉장고 관리 (바텀시트) ────────────────────────────
function FridgeRow({ name, selected, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '12px 2px',
      borderTop: last ? `1px solid ${MF.lineSoft}` : 'none' }}>
      <div style={{ width: 36, height: 40, borderRadius: 7, flex: '0 0 auto', position: 'relative',
        background: selected ? MF.brandTint : MF.sunken }}>
        <div style={{ position: 'absolute', left: 6, right: 6, top: 17, height: 1.5,
          background: selected ? 'rgba(214,89,47,.4)' : MF.line }} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 700, color: MF.ink900 }}>{name}</div>
        {selected && <div style={{ fontSize: 11.5, fontWeight: 700, color: MF.brand, marginTop: 1 }}>현재 선택됨</div>}
      </div>
      <div style={{ display: 'flex', gap: 4 }}>
        <div style={{ width: 36, height: 36, borderRadius: 10, background: MF.sunken, display: 'flex',
          alignItems: 'center', justifyContent: 'center' }}>
          <MIcon name="drive_file_rename_outline" size={18} color={MF.ink500} /></div>
        <div style={{ width: 36, height: 36, borderRadius: 10, background: MF.sunken, display: 'flex',
          alignItems: 'center', justifyContent: 'center' }}>
          <MIcon name="delete" size={18} color={MF.ink400} /></div>
      </div>
    </div>
  );
}
function FridgeManagerSheet() {
  return (
    <SheetShell>
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, background: MF.surface,
        borderRadius: '24px 24px 0 0', padding: '10px 20px 22px',
        boxShadow: '0 -12px 40px rgba(24,16,10,.25)', fontFamily: "'Pretendard', sans-serif" }}>
        <div style={{ width: 38, height: 4, borderRadius: 4, background: MF.line, margin: '0 auto 14px' }} />
        <div style={{ fontSize: 19, fontWeight: 800, color: MF.ink900, marginBottom: 8 }}>냉장고 관리</div>
        <FridgeRow name="주방 냉장고" selected />
        <FridgeRow name="김치냉장고" last />
        <FridgeRow name="사무실" last />
        <div style={{ height: 1, background: MF.lineSoft, margin: '12px 0 14px' }} />
        <div style={{ fontSize: 12, fontWeight: 700, color: MF.ink500, marginBottom: 7 }}>새 냉장고 추가</div>
        <div style={{ display: 'flex', gap: 8 }}>
          <div style={{ flex: 1, height: 48, borderRadius: 12, border: `1.5px solid ${MF.line}`, background: MF.surface,
            display: 'flex', alignItems: 'center', padding: '0 13px', fontSize: 14, fontWeight: 500, color: MF.ink400 }}>
            예: 베란다 냉장고</div>
          <PrimaryBtn icon="add">추가</PrimaryBtn>
        </div>
        <div style={{ fontSize: 11, fontWeight: 500, color: MF.ink400, marginTop: 10, display: 'flex',
          alignItems: 'center', gap: 5 }}>
          <MIcon name="info" size={13} color={MF.ink400} />마지막 1개 냉장고는 삭제할 수 없어요.</div>
      </div>
    </SheetShell>
  );
}

// ── 데이터 병합 다이얼로그 ────────────────────────────
function MergeChoice({ icon, title, sub, primary }) {
  return (
    <button style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 11, padding: '12px 13px',
      borderRadius: 13, cursor: 'pointer', fontFamily: 'inherit', textAlign: 'left',
      border: primary ? 'none' : `1.5px solid ${MF.line}`, background: primary ? MF.brand : MF.surface }}>
      <MIcon name={icon} size={20} color={primary ? '#fff' : MF.ink700} />
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 800, color: primary ? '#fff' : MF.ink900 }}>{title}</div>
        <div style={{ fontSize: 11.5, fontWeight: 500, color: primary ? 'rgba(255,255,255,.85)' : MF.ink500, marginTop: 1 }}>{sub}</div>
      </div>
    </button>
  );
}
function MergeDialog() {
  return (
    <CenterDialog maxW={336}>
      <div style={{ fontSize: 18, fontWeight: 800, color: MF.ink900, marginBottom: 6 }}>데이터 병합 방식</div>
      <div style={{ display: 'flex', gap: 8, marginBottom: 16, marginTop: 12 }}>
        {[['이 기기', '6월 5일', true], ['클라우드', '6월 4일', false]].map(([l, d, newer]) => (
          <div key={l} style={{ flex: 1, background: newer ? MF.brandTint : MF.sunken, borderRadius: 12, padding: '10px 12px' }}>
            <div style={{ fontSize: 11.5, fontWeight: 700, color: MF.ink500 }}>{l}</div>
            <div style={{ fontSize: 15, fontWeight: 800, color: MF.ink900, marginTop: 2 }}>{d}</div>
            {newer && <div style={{ fontSize: 10.5, fontWeight: 800, color: MF.brand, marginTop: 2 }}>최신</div>}
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <MergeChoice icon="merge" title="최신 기준 병합" sub="항목별로 더 최신 데이터를 사용 (추천)" primary />
        <MergeChoice icon="cloud_download" title="클라우드 사용" sub="이 기기 데이터를 클라우드로 덮어씀" />
        <MergeChoice icon="cloud_upload" title="로컬 업로드" sub="클라우드를 이 기기 데이터로 덮어씀" />
      </div>
    </CenterDialog>
  );
}

// ── 만족도 다이얼로그 ─────────────────────────────────
function SatisfactionDialog() {
  return (
    <CenterDialog maxW={320}>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontSize: 17.5, fontWeight: 800, color: MF.ink900, marginBottom: 6 }}>오늘 추천 어땠어요?</div>
        <div style={{ fontSize: 13, fontWeight: 500, color: MF.ink500, marginBottom: 20 }}>
          만족도는 다음 추천 품질에 반영돼요.</div>
        <div style={{ display: 'flex', gap: 10, marginBottom: 12 }}>
          <button style={{ flex: 1, height: 84, borderRadius: 16, border: `1.5px solid ${MF.line}`,
            background: MF.surface, display: 'flex', flexDirection: 'column', alignItems: 'center',
            justifyContent: 'center', gap: 6, cursor: 'pointer', fontFamily: 'inherit' }}>
            <MIcon name="sentiment_dissatisfied" size={28} color={MF.ink500} />
            <span style={{ fontSize: 13, fontWeight: 700, color: MF.ink700 }}>싫어요</span></button>
          <button style={{ flex: 1, height: 84, borderRadius: 16, border: 'none', background: MF.brandTint,
            display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 6,
            cursor: 'pointer', fontFamily: 'inherit' }}>
            <MIcon name="sentiment_very_satisfied" size={28} fill={1} color={MF.brand} />
            <span style={{ fontSize: 13, fontWeight: 800, color: MF.brandInk }}>좋아요</span></button>
        </div>
        <button style={{ border: 'none', background: 'transparent', color: MF.ink400, fontSize: 13,
          fontWeight: 700, fontFamily: 'inherit', cursor: 'pointer', padding: 6 }}>건너뛰기</button>
      </div>
    </CenterDialog>
  );
}

Object.assign(window, {
  CenterDialog, FridgeRow, FridgeManagerSheet, MergeChoice, MergeDialog, SatisfactionDialog,
});
