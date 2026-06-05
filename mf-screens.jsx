/* 하루한칸 — 히스토리(+빈) · 설정. window로 export. */

function ScreenTitle({ title, sub }) {
  return (
    <div style={{ padding: '4px 16px 0' }}>
      <div style={{ fontSize: 23, fontWeight: 800, color: MF.ink900, letterSpacing: '-0.6px' }}>{title}</div>
      {sub && <div style={{ fontSize: 12.5, fontWeight: 600, color: MF.ink500, marginTop: 4 }}>{sub}</div>}
    </div>
  );
}

const HISTORY = [
  { date: '6월 5일', day: '오늘', ok: true, like: 'up' },
  { date: '6월 4일', day: '수', ok: true, like: 'down' },
  { date: '6월 3일', day: '화', ok: true },
  { date: '6월 2일', day: '월', ok: false },
  { date: '6월 1일', day: '일', ok: true, like: 'up' },
  { date: '5월 31일', day: '토', ok: true },
];

function HistoryRow({ row }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, background: MF.surface, borderRadius: 14,
      border: `1px solid ${MF.lineSoft}`, padding: '13px 14px', marginBottom: 8 }}>
      <div style={{ width: 44, textAlign: 'center', flex: '0 0 auto' }}>
        <div style={{ fontSize: 14, fontWeight: 800, color: MF.ink900 }}>{row.date.split('월 ')[1]}</div>
        <div style={{ fontSize: 10.5, fontWeight: 700, color: row.day === '오늘' ? MF.brand : MF.ink400 }}>{row.day}</div>
      </div>
      <div style={{ width: 1, height: 30, background: MF.lineSoft }} />
      <div style={{ flex: 1, minWidth: 0 }}>
        {row.ok ? (
          <React.Fragment>
            <div style={{ fontSize: 14, fontWeight: 700, color: MF.ink900 }}>아침 3 · 점심 3 · 저녁 3</div>
            <div style={{ fontSize: 11.5, fontWeight: 600, color: MF.ink500, marginTop: 2 }}>추천 9개 생성됨</div>
          </React.Fragment>
        ) : (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, height: 24, padding: '0 10px',
            borderRadius: 12, background: MF.urgent.tint, color: MF.urgent.ink, fontSize: 12, fontWeight: 700 }}>
            <MIcon name="error" size={13} fill={1} />생성 실패
          </span>
        )}
      </div>
      {row.like && (
        <MIcon name={row.like === 'up' ? 'thumb_up' : 'thumb_down'} size={17} fill={1}
          color={row.like === 'up' ? MF.fresh.main : MF.ink400} />
      )}
    </div>
  );
}
function HistoryScreen() {
  return (
    <Screen active={2} banner={false}>
      <ScreenTitle title="추천 히스토리" sub="지난 1년 · 최신순" />
      <div style={{ flex: 1, minHeight: 0, overflow: 'hidden', padding: '14px 16px 0' }}>
        {HISTORY.map((r) => <HistoryRow key={r.date} row={r} />)}
      </div>
    </Screen>
  );
}
function HistoryEmpty() {
  return (
    <Screen active={2} banner={false}>
      <ScreenTitle title="추천 히스토리" sub="지난 1년 · 최신순" />
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', alignItems: 'center',
        justifyContent: 'center', padding: '0 32px', textAlign: 'center' }}>
        <div style={{ width: 88, height: 88, borderRadius: 26, background: MF.sunken, display: 'flex',
          alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}>
          <MIcon name="history" size={42} color={MF.ink400} />
        </div>
        <div style={{ fontSize: 16.5, fontWeight: 800, color: MF.ink900, marginBottom: 7 }}>아직 추천 기록이 없어요</div>
        <div style={{ fontSize: 13.5, fontWeight: 500, color: MF.ink500, lineHeight: 1.5 }}>
          오늘의 추천을 한 번 받아보면<br />여기에 차곡차곡 쌓여요.</div>
      </div>
    </Screen>
  );
}

// ── 설정 ──────────────────────────────────────────────
function SettingsGroup({ title, children }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ fontSize: 11.5, fontWeight: 800, color: MF.ink400, letterSpacing: '0.4px',
        padding: '0 4px 8px' }}>{title}</div>
      <div style={{ background: MF.surface, borderRadius: 16, border: `1px solid ${MF.lineSoft}`,
        overflow: 'hidden' }}>{children}</div>
    </div>
  );
}
function SettingRow({ icon, title, sub, trailing, top, accent }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 14px',
      borderTop: top ? `1px solid ${MF.lineSoft}` : 'none' }}>
      <div style={{ width: 34, height: 34, borderRadius: 10, flex: '0 0 auto', background: MF.sunken,
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <MIcon name={icon} size={18} color={accent || MF.ink700} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 700, color: MF.ink900 }}>{title}</div>
        {sub && <div style={{ fontSize: 11.5, fontWeight: 500, color: MF.ink500, marginTop: 1,
          whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{sub}</div>}
      </div>
      {trailing}
    </div>
  );
}
function Toggle({ on }) {
  return (
    <div style={{ width: 44, height: 26, borderRadius: 13, background: on ? MF.brand : MF.line,
      padding: 3, display: 'flex', justifyContent: on ? 'flex-end' : 'flex-start' }}>
      <div style={{ width: 20, height: 20, borderRadius: 10, background: '#fff' }} />
    </div>
  );
}
function SettingsScreen() {
  return (
    <Screen active={3} banner={false}>
      <ScreenTitle title="설정" />
      <div style={{ flex: 1, minHeight: 0, overflow: 'hidden', padding: '16px 16px 0' }}>
        <SettingsGroup title="계정">
          <SettingRow icon="person" title="비회원으로 사용 중" sub="UID · anon_8f3a4c…" />
          <div style={{ padding: '4px 14px 14px', display: 'flex', flexDirection: 'column', gap: 8 }}>
            <div style={{ display: 'flex', gap: 8 }}>
              <button style={{ flex: 1, height: 44, borderRadius: 12, border: `1.5px solid ${MF.line}`,
                background: '#fff', color: MF.ink900, fontSize: 13.5, fontWeight: 700, fontFamily: 'inherit',
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 7, cursor: 'pointer' }}>
                <span style={{ fontSize: 15, fontWeight: 800, color: '#4285F4' }}>G</span>Google 로그인</button>
              <button style={{ flex: 1, height: 44, borderRadius: 12, border: 'none', background: MF.ink900,
                color: '#fff', fontSize: 13.5, fontWeight: 700, fontFamily: 'inherit', display: 'inline-flex',
                alignItems: 'center', justifyContent: 'center', gap: 6, cursor: 'pointer' }}>
                <MIcon name="apple" size={17} fill={1} color="#fff" />Apple 로그인</button>
            </div>
            <div style={{ fontSize: 11, fontWeight: 500, color: MF.ink400, lineHeight: 1.5, padding: '2px 2px 0' }}>
              로그인 시 기존 비회원 데이터는 계정에 연결돼요. 클라우드에 데이터가 있으면 병합 방식을 물어봐요.</div>
          </div>
        </SettingsGroup>

        <SettingsGroup title="알림">
          <SettingRow icon="notifications_active" title="오늘의 추천 알림" sub="매일 오전 7시" trailing={<Toggle on />} />
        </SettingsGroup>

        <SettingsGroup title="활동">
          <SettingRow icon="favorite" title="최근 7일 좋아요 비율" accent={MF.fresh.main}
            trailing={<span style={{ fontSize: 17, fontWeight: 800, color: MF.fresh.main }}>67%</span>} />
        </SettingsGroup>
      </div>
    </Screen>
  );
}

Object.assign(window, {
  ScreenTitle, HISTORY, HistoryRow, HistoryScreen, HistoryEmpty,
  SettingsGroup, SettingRow, Toggle, SettingsScreen,
});
