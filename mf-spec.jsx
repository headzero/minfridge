/* 하루한칸 — 디자인 시스템 스펙 시트 (요약). window로 export. */
function Swatch({ hex, name, sub, dark }) {
  return (
    <div style={{ flex: 1 }}>
      <div style={{ height: 52, borderRadius: 11, background: hex, border: `1px solid ${MF.line}` }} />
      <div style={{ fontSize: 12, fontWeight: 800, color: MF.ink900, marginTop: 6 }}>{name}</div>
      <div style={{ fontSize: 10.5, fontWeight: 600, color: MF.ink400,
        fontFamily: 'ui-monospace, Menlo, monospace' }}>{hex}</div>
      {sub && <div style={{ fontSize: 10.5, color: MF.ink500 }}>{sub}</div>}
    </div>
  );
}
function Block({ title, children }) {
  return (
    <div style={{ marginBottom: 22 }}>
      <div style={{ fontSize: 12, fontWeight: 800, color: MF.ink500, letterSpacing: '0.4px',
        marginBottom: 11 }}>{title}</div>
      {children}
    </div>
  );
}
function SpecSheet() {
  const fr = [MF.fresh, MF.caution, MF.soon, MF.urgent];
  const type = [
    { t: '하루한칸', s: '화면 제목 · 23 / 800' },
    { t: '오늘의 추천', s: '섹션 헤더 · 16 / 800' },
    { t: '냉장고에 뭐가 있는지 한눈에', s: '본문 · 14.5 / 500' },
    { t: '수량 2개 · 보관 4일 · D-1 (예상)', s: '캡션 · 12 / 500' },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: MF.bg, padding: '26px 26px 30px',
      fontFamily: "'Pretendard', sans-serif", overflow: 'hidden' }}>
      <div style={{ fontSize: 21, fontWeight: 800, color: MF.ink900, letterSpacing: '-0.5px' }}>디자인 시스템</div>
      <div style={{ fontSize: 12.5, fontWeight: 600, color: MF.ink500, marginBottom: 22 }}>
        연두초록 · Pretendard · 신선도 신호등</div>

      <Block title="브랜드">
        <div style={{ display: 'flex', gap: 12 }}>
          <Swatch hex={MF.brand} name="Brand" sub="Primary" />
          <Swatch hex={MF.brand700} name="Pressed" />
          <Swatch hex={MF.brandTint} name="Tint" />
          <Swatch hex={MF.bg} name="Surface" sub="배경" />
          <Swatch hex={MF.ink900} name="Ink" sub="본문" />
        </div>
      </Block>

      <Block title="신선도 시맨틱 — 색 + 라벨 + 아이콘 병행 (접근성)">
        <div style={{ display: 'flex', gap: 9 }}>
          {fr.map((f) => (
            <div key={f.key} style={{ flex: 1, background: f.tint, borderRadius: 12, padding: '11px 10px',
              borderTop: `3px solid ${f.main}` }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                <span style={{ width: 9, height: 9, borderRadius: 9, background: f.main }} />
                <span style={{ fontSize: 13, fontWeight: 800, color: f.ink, whiteSpace: 'nowrap' }}>{f.name}</span>
              </div>
              <div style={{ fontSize: 10.5, fontWeight: 600, color: f.ink, marginTop: 5, opacity: 0.8 }}>
                {f.key === 'fresh' ? 'D-8+' : f.key === 'caution' ? 'D-4~7' : f.key === 'soon' ? 'D-2~3' : 'D-1·지남'}</div>
              <div style={{ fontSize: 9.5, fontWeight: 700, color: MF.ink400, marginTop: 3,
                fontFamily: 'ui-monospace, Menlo, monospace' }}>{f.main}</div>
            </div>
          ))}
        </div>
      </Block>

      <Block title="타이포 — Pretendard">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {type.map((r) => (
            <div key={r.s} style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
              <span style={{ fontSize: r.s.includes('23') ? 23 : r.s.includes('16') ? 16 : r.s.includes('14.5') ? 14.5 : 12,
                fontWeight: r.s.includes('500') ? 500 : 800, color: MF.ink900 }}>{r.t}</span>
              <span style={{ fontSize: 11, fontWeight: 600, color: MF.ink400 }}>{r.s}</span>
            </div>
          ))}
        </div>
      </Block>

      <Block title="점유율 게이지 — 정상 / 경고 2상태">
        <div style={{ display: 'flex', gap: 14 }}>
          <div style={{ flex: 1 }}>
            <div style={{ height: 9, borderRadius: 5, background: MF.sunken, overflow: 'hidden' }}>
              <div style={{ width: '52%', height: '100%', background: MF.gaugeOk, borderRadius: 5 }} /></div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 6 }}>
              <MIcon name="check_circle" size={13} fill={1} color={MF.gaugeOk} />
              <span style={{ fontSize: 11.5, fontWeight: 700, color: MF.ink700 }}>목표 이내</span></div>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ height: 9, borderRadius: 5, background: MF.sunken, overflow: 'hidden' }}>
              <div style={{ width: '84%', height: '100%', background: MF.gaugeOver, borderRadius: 5 }} /></div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 6 }}>
              <MIcon name="warning" size={13} fill={1} color={MF.gaugeOver} />
              <span style={{ fontSize: 11.5, fontWeight: 700, color: MF.soon.ink }}>주의 · 목표(2/3) 초과</span></div>
          </div>
        </div>
      </Block>

      <Block title="형태 토큰">
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {['카드 R18', '버튼 R14', '칩 R999', '엘리베이션 soft', '간격 4·8·12·16'].map((t) => (
            <span key={t} style={{ fontSize: 11.5, fontWeight: 700, color: MF.ink700, background: MF.surface,
              border: `1px solid ${MF.line}`, borderRadius: 8, padding: '6px 10px' }}>{t}</span>
          ))}
        </div>
      </Block>
    </div>
  );
}
Object.assign(window, { SpecSheet });
