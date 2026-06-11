// Screen 1: My courts list · Screen 3: Venues manager
const { useState: useStateS } = React;

/* ================= My courts ================= */
const MyCourtsScreen = ({ courts, onAdd, onEdit, onVenues }) => {
  const sportsOf = (c) => [...new Set(c.venues.map(v => v.sport))];
  return (
    <div className="content-inner" data-screen-label="Sân của tôi — danh sách">
      <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', paddingTop: 16, flexWrap: 'wrap', gap: 12 }}>
        <div>
          <h1 className="headline-md">Sân của tôi</h1>
          <p className="body-md" style={{ color: 'var(--md-on-surface-variant)', marginTop: 4 }}>
            {courts.length} cụm sân · {courts.reduce((n, c) => n + c.venues.length, 0)} sân con
          </p>
        </div>
        <MButton variant="filled" icon="add" onClick={onAdd}>Thêm sân mới</MButton>
      </div>

      <div className="courts-grid">
        {courts.map(c => (
          <div key={c.id} className="m3-card elevated-card court-card clickable" onClick={() => onEdit(c)}>
            <div className="photo" style={{ position: 'relative' }}>
              <PhotoPh label={`ảnh ${c.name}`} icon="stadium" style={{ position: 'absolute', inset: 0 }}></PhotoPh>
              <span className="status-chip-holder" style={{ position: 'absolute', top: 12, left: 12 }}><StatusChip status={c.status} /></span>
            </div>
            <div className="cc-body">
              <span className="cc-name">{c.name}</span>
              <span className="cc-addr"><MIcon name="location_on" size={16} />{c.address}</span>
              <div className="cc-chips">
                <MChip sm icon="grid_view">{c.venues.length} sân con</MChip>
                {sportsOf(c).map(s => <MChip key={s} sm selected>{sportLabel(s)}</MChip>)}
              </div>
            </div>
            <div className="cc-actions" onClick={e => e.stopPropagation()}>
              <MButton variant="text" icon="edit" onClick={() => onEdit(c)}>Sửa</MButton>
              <MButton variant="text" icon="grid_view" onClick={() => onVenues(c)}>Sân con</MButton>
              <span style={{ flex: 1 }}></span>
              <MIconButton icon="more_vert" title="Thêm" size={20} />
            </div>
          </div>
        ))}

        <button type="button" className="m3-card outlined-card clickable" onClick={onAdd}
          style={{ minHeight: 240, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 10, color: 'var(--md-primary)', borderStyle: 'none' }}>
          <span style={{ width: 52, height: 52, borderRadius: 16, background: 'var(--md-primary-container)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--md-on-primary-container)' }}>
            <MIcon name="add" size={26} />
          </span>
          <span className="title-sm">Thêm sân mới</span>
          <span className="body-sm" style={{ color: 'var(--md-on-surface-variant)', maxWidth: 200, textAlign: 'center' }}>Nhập tay hoặc để AI điền giúp từ văn bản, liên kết, ảnh</span>
        </button>
      </div>
    </div>
  );
};

/* ================= Venue dialog (add / edit) ================= */
const VenueDialog = ({ open, initial, onClose, onSave }) => {
  const [v, setV] = useStateS(initial || { name: '', sport: 'pickleball', price: 120000, indoor: true });
  React.useEffect(() => { setV(initial || { name: '', sport: 'pickleball', price: 120000, indoor: true }); }, [initial, open]);
  const set = (k, val) => setV(x => ({ ...x, [k]: val }));
  return (
    <MDialog
      open={open} onClose={onClose} icon="sports_tennis"
      title={initial && initial.id ? 'Sửa sân con' : 'Thêm sân con'}
      actions={
        <React.Fragment>
          <MButton variant="text" onClick={onClose}>Huỷ</MButton>
          <MButton variant="filled" disabled={!v.name.trim()} onClick={() => onSave(v)}>Lưu</MButton>
        </React.Fragment>
      }
    >
      <div className="form-stack" style={{ gap: 14, paddingTop: 6 }}>
        <MTextField label="Tên sân con" value={v.name} onChange={x => set('name', x)} placeholder="Ví dụ: Sân 1, Sân A" />
        <div className="form-row">
          <MSelect label="Môn thể thao" value={v.sport} onChange={x => set('sport', x)} options={SPORTS.map(s => ({ value: s.id, label: s.label }))} />
          <MTextField label="Giá / giờ (VND)" type="number" value={v.price} onChange={x => set('price', Number(x) || 0)} supporting={fmtVND(v.price) + '/giờ'} />
        </div>
        <MSegmented
          value={v.indoor ? 'in' : 'out'} onChange={x => set('indoor', x === 'in')}
          options={[{ value: 'in', label: 'Trong nhà', icon: 'roofing' }, { value: 'out', label: 'Ngoài trời', icon: 'sunny' }]}
        />
      </div>
    </MDialog>
  );
};

/* ================= Bulk AI venue creation ================= */
const VenueBulkSheet = ({ open, onClose, onCreate }) => {
  const [text, setText] = useStateS('');
  const [phase, setPhase] = useStateS('input');
  const [rows, setRows] = useStateS([]);
  const [err, setErr] = useStateS(null);

  const analyze = async () => {
    setPhase('loading'); setErr(null);
    try {
      const venues = await aiExtractVenues(text);
      setRows(venues.map(v => ({ ...v, on: true })));
      setPhase('review');
    } catch (e) { setErr(e.message || 'Có lỗi xảy ra'); setPhase('input'); }
  };
  const reset = () => { setPhase('input'); setRows([]); };
  const create = () => { onCreate(rows.filter(r => r.on)); reset(); setText(''); };

  return (
    <MBottomSheet open={open} onClose={() => { onClose(); reset(); }}>
      <div className="ai-head" style={{ marginBottom: 4 }}>
        <div className="spark"><MIcon name="auto_awesome" size={22} /></div>
        <div>
          <h3>Tạo nhanh sân con bằng AI</h3>
          <p>Mô tả các sân — AI tách thành danh sách, bạn duyệt lại</p>
        </div>
      </div>

      {phase === 'input' && (
        <div style={{ marginTop: 14 }}>
          {err && <div style={{ background: 'var(--md-error-container)', color: 'var(--md-on-error-container)', borderRadius: 12, padding: '10px 14px', fontSize: 13, marginBottom: 12 }}>{err}</div>}
          <textarea className="ai-textarea" rows={4} value={text} onChange={e => setText(e.target.value)}
            placeholder={'Ví dụ: "Có 4 sân pickleball trong nhà giá 120k/h và 2 sân cầu lông 80k/h"'}></textarea>
          <div style={{ height: 12 }}></div>
          <MButton variant="filled" icon="auto_awesome" full onClick={analyze} disabled={!text.trim()}>Phân tích bằng AI</MButton>
        </div>
      )}

      {phase === 'loading' && (
        <div style={{ padding: '32px 8px', textAlign: 'center' }}>
          <MSpinner style={{ margin: '0 auto 14px' }} />
          <div className="title-md">AI đang tách danh sách sân…</div>
        </div>
      )}

      {phase === 'review' && (
        <div style={{ marginTop: 14 }}>
          <p className="body-md" style={{ color: 'var(--md-on-surface-variant)', marginBottom: 12 }}>Bỏ chọn sân không đúng. Bạn có thể sửa chi tiết sau khi tạo.</p>
          <div className="review-list">
            {rows.map((r, i) => (
              <div key={i} className={`review-row ${r.on ? '' : 'off'}`}>
                <button type="button" className={`rv-check ${r.on ? 'on' : ''}`} onClick={() => setRows(rs => rs.map((x, j) => j === i ? { ...x, on: !x.on } : x))}>
                  {r.on && <MIcon name="check" size={16} />}
                </button>
                <span className="rv-value" style={{ fontWeight: 500 }}>{r.name}</span>
                <span className="rv-value" style={{ flex: 'none', color: 'var(--md-on-surface-variant)' }}>{sportLabel(r.sport)} · {r.indoor ? 'Trong nhà' : 'Ngoài trời'}</span>
                <span className="rv-value" style={{ flex: 'none', fontWeight: 500 }}>{fmtVND(r.price)}/giờ</span>
              </div>
            ))}
          </div>
          <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end', marginTop: 16 }}>
            <MButton variant="text" icon="arrow_back" onClick={reset}>Sửa lại</MButton>
            <MButton variant="filled" icon="playlist_add" onClick={create} disabled={!rows.some(r => r.on)}>
              Tạo {rows.filter(r => r.on).length} sân con
            </MButton>
          </div>
        </div>
      )}
    </MBottomSheet>
  );
};

/* ================= Venues screen ================= */
const VenuesScreen = ({ court, onUpdate }) => {
  const [dialog, setDialog] = useStateS(null); // null | {venue or empty}
  const [bulkOpen, setBulkOpen] = useStateS(false);
  const snack = useSnack();

  const saveVenue = (v) => {
    let venues;
    if (v.id) venues = court.venues.map(x => x.id === v.id ? v : x);
    else venues = [...court.venues, { ...v, id: 'v' + Date.now() }];
    onUpdate({ ...court, venues });
    setDialog(null);
    snack(v.id ? `Đã cập nhật ${v.name}` : `Đã thêm ${v.name}`);
  };
  const removeVenue = (v) => {
    onUpdate({ ...court, venues: court.venues.filter(x => x.id !== v.id) });
    snack(`Đã xoá ${v.name}`, { label: 'Hoàn tác', fn: () => onUpdate(court) });
  };
  const bulkCreate = (list) => {
    const venues = [...court.venues, ...list.map((v, i) => ({ ...v, id: 'v' + Date.now() + i }))];
    onUpdate({ ...court, venues });
    setBulkOpen(false);
    snack(`Đã tạo ${list.length} sân con bằng AI`);
  };

  const groups = {};
  court.venues.forEach(v => { (groups[v.sport] = groups[v.sport] || []).push(v); });

  return (
    <div className="content-inner" data-screen-label="Sân con — quản lý">
      <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', paddingTop: 16, flexWrap: 'wrap', gap: 12 }}>
        <div>
          <h1 className="headline-md">Sân con · {court.name}</h1>
          <p className="body-md" style={{ color: 'var(--md-on-surface-variant)', marginTop: 4 }}>
            {court.venues.length} sân · mở cửa {court.openTime}–{court.closeTime}
          </p>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          <MButton variant="tonal" icon="auto_awesome" onClick={() => setBulkOpen(true)}>Tạo nhanh bằng AI</MButton>
          <MButton variant="filled" icon="add" onClick={() => setDialog({})}>Thêm sân con</MButton>
        </div>
      </div>

      {Object.entries(groups).map(([sport, list]) => (
        <div key={sport} style={{ marginTop: 24 }}>
          <div className="title-sm" style={{ color: 'var(--md-on-surface-variant)', margin: '0 4px 8px', display: 'flex', gap: 8, alignItems: 'center' }}>
            <MIcon name={(SPORTS.find(s => s.id === sport) || {}).icon || 'sports'} size={18} />
            {sportLabel(sport)} · {list.length} sân
          </div>
          <div className="m3-card outlined-card" style={{ background: 'var(--md-surface-container-lowest)' }}>
            {list.map((v, i) => (
              <React.Fragment key={v.id}>
                {i > 0 && <div className="venue-divider"></div>}
                <div className="venue-row">
                  <span className="v-ic"><MIcon name={v.indoor ? 'roofing' : 'sunny'} size={22} /></span>
                  <div>
                    <div className="v-name">{v.name}</div>
                    <div className="v-sub">{v.indoor ? 'Trong nhà' : 'Ngoài trời'} · {sportLabel(v.sport)}</div>
                  </div>
                  <div className="v-price">{fmtVND(v.price)}<span>mỗi giờ</span></div>
                  <MIconButton icon="edit" size={20} title="Sửa" onClick={() => setDialog(v)} />
                  <MIconButton icon="delete" size={20} title="Xoá" onClick={() => removeVenue(v)} />
                </div>
              </React.Fragment>
            ))}
          </div>
        </div>
      ))}

      {!court.venues.length && (
        <div className="m3-card" style={{ marginTop: 24, padding: '48px 24px', textAlign: 'center', color: 'var(--md-on-surface-variant)' }}>
          <MIcon name="grid_view" size={36} style={{ opacity: .5 }} />
          <p className="title-md" style={{ marginTop: 12 }}>Chưa có sân con nào</p>
          <p className="body-md" style={{ marginTop: 4 }}>Thêm từng sân, hoặc mô tả tất cả trong một câu để AI tạo giúp.</p>
        </div>
      )}

      <VenueDialog open={dialog !== null} initial={dialog && dialog.id ? dialog : null} onClose={() => setDialog(null)} onSave={saveVenue} />
      <VenueBulkSheet open={bulkOpen} onClose={() => setBulkOpen(false)} onCreate={bulkCreate} />
    </div>
  );
};

Object.assign(window, { MyCourtsScreen, VenuesScreen, VenueDialog, VenueBulkSheet });
