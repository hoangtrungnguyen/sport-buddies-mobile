// App shell — nav drawer, top app bar, routing, tweaks
const { useState: useStateApp } = React;

const NAV_ITEMS = [
  { id: 'home', label: 'Trang chủ', icon: 'home', count: 3 },
  { id: 'requests', label: 'Yêu cầu', icon: 'inbox', count: 8 },
  { id: 'schedule', label: 'Lịch sân', icon: 'calendar_month' },
  { id: 'fixed', label: 'Lịch cố định', icon: 'autorenew', count: 6 },
  { id: 'analytics', label: 'Thống kê', icon: 'monitoring' },
  { id: 'mycourts', label: 'Sân của tôi', icon: 'stadium' },
  { id: 'players', label: 'Khách hàng', icon: 'group' },
];
const NAV_SYS = [
  { id: 'notifications', label: 'Thông báo', icon: 'notifications', count: 4 },
  { id: 'settings', label: 'Cài đặt sân', icon: 'settings' },
  { id: 'support', label: 'Hỗ trợ', icon: 'help' },
];

const NavDrawer = ({ onOther }) => (
  <nav className="navdrawer">
    <div className="brand">
      <div className="mark">S</div>
      <div><strong>SportBuddies</strong><span>Chủ sân · Quận 7</span></div>
    </div>
    <div className="nav-label">Quản lý</div>
    {NAV_ITEMS.map(n => (
      <button key={n.id} className={`nav-item ${n.id === 'mycourts' ? 'active' : ''}`} onClick={n.id === 'mycourts' ? undefined : onOther}>
        <MIcon name={n.icon} fill={n.id === 'mycourts'} />
        <span className="lbl">{n.label}</span>
        {n.count && <span className="cnt">{n.count}</span>}
      </button>
    ))}
    <div className="nav-label">Hệ thống</div>
    {NAV_SYS.map(n => (
      <button key={n.id} className="nav-item" onClick={onOther}>
        <MIcon name={n.icon} />
        <span className="lbl">{n.label}</span>
        {n.count && <span className="cnt">{n.count}</span>}
      </button>
    ))}
    <div className="nav-foot">
      <div className="owner-row">
        <div className="avatar">MN</div>
        <div style={{ flex: 1 }}><strong>Nguyễn Văn Minh</strong><span>Chủ sân · 5 sân</span></div>
        <MIcon name="logout" size={18} style={{ color: 'var(--md-on-surface-variant)' }} />
      </div>
      <div className="trial-card">
        <strong>Gói miễn phí 3 tháng</strong>
        Hết hạn 04/08/2026 · <a href="#">Nâng cấp</a>
      </div>
    </div>
  </nav>
);

const CourtsApp = ({ tweaks, setTweak }) => {
  const [courts, setCourts] = useStateApp(SEED_COURTS);
  const [route, setRoute] = useStateApp({ screen: 'list' });
  const [aiOpen, setAiOpen] = useStateApp(false);
  const [injected, setInjected] = useStateApp(null);
  const snack = useSnack();

  const flow = tweaks.flow;
  const aiEntry = tweaks.aiEntry;

  const goAdd = () => {
    setInjected(null);
    if (flow === 'ai-first') setRoute({ screen: 'intake' });
    else { setRoute({ screen: 'form', court: null }); setAiOpen(aiEntry === 'inline'); }
  };
  const goEdit = (c) => { setInjected(null); setRoute({ screen: 'form', court: c }); setAiOpen(false); };
  const goVenues = (c) => setRoute({ screen: 'venues', courtId: c.id });
  const goList = () => setRoute({ screen: 'list' });

  const saveCourt = (form) => {
    if (form.id) {
      setCourts(cs => cs.map(c => c.id === form.id ? form : c));
      snack(`Đã lưu thay đổi cho ${form.name}`);
    } else {
      const status = form.status === 'draft' ? 'draft' : 'pending';
      setCourts(cs => [...cs, { ...form, id: 'c' + Date.now(), status }]);
      snack(status === 'draft' ? 'Đã lưu nháp' : `Đã tạo ${form.name} — chờ SnB duyệt`);
    }
    goList();
  };
  const updateCourt = (c) => setCourts(cs => cs.map(x => x.id === c.id ? c : x));

  const titles = {
    list: 'Sân của tôi',
    form: route.court ? 'Sửa sân' : 'Thêm sân mới',
    intake: 'Thêm sân mới',
    venues: 'Sân con',
  };
  const isSub = route.screen !== 'list';
  const showAiTrigger = route.screen === 'form' && flow === 'form' && (aiEntry === 'sheet' || aiEntry === 'side');

  const venuesCourt = route.screen === 'venues' ? courts.find(c => c.id === route.courtId) : null;

  return (
    <div className="shell">
      <NavDrawer onOther={() => snack('Màn hình này nằm ngoài phạm vi prototype — xem "Sân của tôi"')} />
      <div className="main-col">
        <header className="topbar">
          {isSub
            ? <MIconButton icon="arrow_back" title="Quay lại" onClick={route.screen === 'venues' || route.screen === 'intake' ? goList : goList} />
            : <span style={{ width: 8 }}></span>}
          <span className="tb-title">{titles[route.screen]}</span>
          {route.screen === 'venues' && venuesCourt && <span className="tb-sub">{venuesCourt.name}</span>}
          <span className="spacer"></span>
          {showAiTrigger && (
            <MButton variant="tonal" icon="auto_awesome" onClick={() => setAiOpen(true)}>Nhập nhanh bằng AI</MButton>
          )}
          <MIconButton icon="search" title="Tìm kiếm" />
          <MIconButton icon="notifications" title="Thông báo" />
        </header>

        <div className="content">
          {route.screen === 'list' && (
            <MyCourtsScreen courts={courts} onAdd={goAdd} onEdit={goEdit} onVenues={goVenues} />
          )}
          {route.screen === 'intake' && (
            <IntakeScreen
              onApply={(data) => { setInjected({ data, ts: Date.now() }); setRoute({ screen: 'form', court: null }); }}
              onSkip={() => { setInjected(null); setRoute({ screen: 'form', court: null }); }}
            />
          )}
          {route.screen === 'form' && (
            <CourtFormScreen
              key={(route.court && route.court.id) || 'new'}
              initial={route.court}
              onSave={saveCourt}
              onCancel={goList}
              flow={flow}
              aiEntry={aiEntry}
              aiOpen={aiOpen}
              setAiOpen={setAiOpen}
              injected={injected}
            />
          )}
          {route.screen === 'venues' && venuesCourt && (
            <VenuesScreen court={venuesCourt} onUpdate={updateCourt} />
          )}
        </div>
      </div>

      <TweaksPanel title="Tweaks">
        <TweakSection title="Luồng thêm sân (3 phương án)">
          <TweakRadio
            label="Phương án"
            value={tweaks.flow}
            options={[
              { label: 'A · Form + trợ lý AI', value: 'form' },
              { label: 'B · AI nhập trước', value: 'ai-first' },
              { label: 'C · Chat từng bước', value: 'chat' },
            ]}
            onChange={v => { setTweak('flow', v); setRoute({ screen: 'list' }); }}
          />
        </TweakSection>
        <TweakSection title="Kiểu hiển thị trợ lý AI (phương án A)">
          <TweakRadio
            label="Vị trí"
            value={tweaks.aiEntry}
            options={[
              { label: 'Bottom sheet', value: 'sheet' },
              { label: 'Side sheet', value: 'side' },
              { label: 'Thẻ trong form', value: 'inline' },
            ]}
            onChange={v => { setTweak('aiEntry', v); setAiOpen(v === 'inline'); }}
          />
        </TweakSection>
        <TweakSection title="Material 3">
          <TweakRadio
            label="Kiểu text field"
            value={tweaks.fieldStyle}
            options={[{ label: 'Outlined', value: 'outlined' }, { label: 'Filled', value: 'filled' }]}
            onChange={v => setTweak('fieldStyle', v)}
          />
        </TweakSection>
        <TweakSection title="Điều hướng">
          <TweakButton label="→ Sân của tôi (danh sách)" onClick={goList} />
          <TweakButton label="→ Thêm sân mới" onClick={goAdd} />
          <TweakButton label="→ Sửa sân (SnB Đại Lộc)" onClick={() => goEdit(courts[0])} />
          <TweakButton label="→ Sân con (SnB Đại Lộc)" onClick={() => goVenues(courts[0])} />
        </TweakSection>
      </TweaksPanel>
    </div>
  );
};

const Root = () => {
  const [tweaks, setTweak] = window.useTweaks(window.SnB_COURTS_TWEAKS);
  return (
    <FieldStyleContext.Provider value={tweaks.fieldStyle || 'outlined'}>
      <SnackHost>
        <CourtsApp tweaks={tweaks} setTweak={setTweak} />
      </SnackHost>
    </FieldStyleContext.Provider>
  );
};

ReactDOM.createRoot(document.getElementById('root')).render(<Root />);
