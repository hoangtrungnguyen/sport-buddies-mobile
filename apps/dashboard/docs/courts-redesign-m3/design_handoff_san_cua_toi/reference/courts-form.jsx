// Screen 2: Court form — with 3 flow variants & AI entry styles
const { useState: useStateF, useEffect: useEffectF } = React;

const cleanVal = (v) => (v === null || v === undefined) ? '' : v;

/* ---------- shared form body ---------- */
const CourtFormBody = ({ form, set, aiFilled, errors, onWriteDesc, descBusy, onOpenVenueDialog, onOpenBulk, onRemoveVenue, inlineAI }) => {
  const toggleAmenity = (id) => set('amenities', form.amenities.includes(id) ? form.amenities.filter(a => a !== id) : [...form.amenities, id]);
  return (
    <div>
      {inlineAI}

      <div className="form-section">
        <div className="fs-head">
          <MIcon name="badge" />
          <div><h2>Thông tin cơ bản</h2><p>Tên hiển thị cho khách và số liên hệ</p></div>
        </div>
        <div className="form-row">
          <MTextField label="Tên sân" value={form.name} onChange={v => set('name', v)} placeholder="Ví dụ: Sân 1, Pickleball A" aiFilled={aiFilled.has('name')} error={errors.name} />
          <MTextField label="Số điện thoại" value={form.phone} onChange={v => set('phone', v)} leadingIcon="call" placeholder="090x xxx xxx" aiFilled={aiFilled.has('phone')} />
        </div>
      </div>

      <div className="form-section">
        <div className="fs-head">
          <MIcon name="location_on" />
          <div><h2>Vị trí</h2><p>Địa chỉ và toạ độ để khách tìm thấy sân trên bản đồ</p></div>
        </div>
        <div className="form-stack" style={{ gap: 16 }}>
          <MTextField label="Địa chỉ" value={form.address} onChange={v => set('address', v)} placeholder="Ví dụ: 123 Nguyễn Văn Linh, Q7, TP.HCM" aiFilled={aiFilled.has('address')} error={errors.address} />
          <div className="form-row">
            <MTextField label="Vĩ độ (lat)" value={form.lat} onChange={v => set('lat', v)} type="text" placeholder="10.762622" aiFilled={aiFilled.has('lat')} />
            <MTextField label="Kinh độ (lng)" value={form.lng} onChange={v => set('lng', v)} type="text" placeholder="106.660172" aiFilled={aiFilled.has('lng')} />
          </div>
          <MTextField label="Google Maps URL" value={form.mapsUrl} onChange={v => set('mapsUrl', v)} leadingIcon="map" placeholder="https://maps.google.com/?q=…" aiFilled={aiFilled.has('mapsUrl')} />
        </div>
      </div>

      <div className="form-section">
        <div className="fs-head">
          <MIcon name="description" />
          <div><h2>Mô tả</h2><p>Giới thiệu ngắn về sân, tiện ích, lưu ý cho khách</p></div>
        </div>
        <MTextField textarea rows={3} label="Mô tả" value={form.description} onChange={v => set('description', v)} placeholder="Mô tả ngắn về sân, tiện ích, lưu ý cho khách…" aiFilled={aiFilled.has('description')} />
        <div style={{ marginTop: 10, display: 'flex', gap: 8 }}>
          <MChip type="assist" icon={descBusy ? undefined : 'auto_awesome'} onClick={descBusy ? undefined : onWriteDesc}>
            {descBusy && <MSpinner style={{ width: 14, height: 14, borderWidth: 2 }} />}
            {descBusy ? 'AI đang viết…' : (form.description ? 'Viết lại bằng AI' : 'Viết mô tả bằng AI')}
          </MChip>
        </div>
      </div>

      <div className="form-section">
        <div className="fs-head">
          <MIcon name="category" />
          <div><h2>Tiện ích</h2><p>Chọn các tiện ích sân có {aiFilled.has('amenities') && <span style={{ color: 'var(--md-tertiary)', fontWeight: 500 }}>· ✦ AI đã chọn — kiểm tra lại</span>}</p></div>
        </div>
        <div className="chip-wrap">
          {AMENITIES.map(a => (
            <MChip key={a.id} icon={a.icon} selected={form.amenities.includes(a.id)} onClick={() => toggleAmenity(a.id)}>{a.label}</MChip>
          ))}
        </div>
      </div>

      <div className="form-section">
        <div className="fs-head">
          <MIcon name="schedule" />
          <div><h2>Giờ hoạt động</h2><p>Khung giờ nhận đặt sân mỗi ngày</p></div>
        </div>
        <div className="form-row" style={{ maxWidth: 480 }}>
          <MSelect label="Mở cửa" value={form.openTime} onChange={v => set('openTime', v)} options={HOURS.map(h => ({ value: h, label: h }))} leadingIcon="wb_twilight" />
          <MSelect label="Đóng cửa" value={form.closeTime} onChange={v => set('closeTime', v)} options={HOURS.map(h => ({ value: h, label: h }))} leadingIcon="bedtime" />
        </div>
        {aiFilled.has('openTime') && <div className="body-sm" style={{ color: 'var(--md-tertiary)', marginTop: 6, display: 'flex', gap: 6, alignItems: 'center' }}><MIcon name="auto_awesome" size={14} /> Giờ hoạt động điền bởi AI — kiểm tra lại</div>}
      </div>

      <div className="form-section">
        <div className="fs-head">
          <MIcon name="photo_library" />
          <div><h2>Ảnh sân</h2><p>Tối thiểu 1 ảnh — ảnh đầu tiên là ảnh đại diện</p></div>
        </div>
        <div className="photos-row">
          <PhotoPh label="ảnh đại diện" />
          <PhotoPh label="ảnh sân" />
          <button type="button" className="add-photo"><MIcon name="add_photo_alternate" size={22} /> Thêm ảnh</button>
        </div>
      </div>

      <div className="form-section">
        <div className="fs-head">
          <MIcon name="grid_view" />
          <div><h2>Sân con ({form.venues.length})</h2><p>Các sân bên trong cụm sân này — có thể bổ sung sau</p></div>
        </div>
        {form.venues.length > 0 && (
          <div className="m3-card outlined-card" style={{ background: 'var(--md-surface-container-lowest)', marginBottom: 12 }}>
            {form.venues.map((v, i) => (
              <React.Fragment key={v.id || i}>
                {i > 0 && <div className="venue-divider"></div>}
                <div className="venue-row" style={{ padding: '10px 8px 10px 14px' }}>
                  <span className="v-ic" style={{ width: 36, height: 36 }}><MIcon name={v.indoor ? 'roofing' : 'sunny'} size={18} /></span>
                  <div>
                    <div className="v-name" style={{ fontSize: 14 }}>{v.name}</div>
                    <div className="v-sub">{sportLabel(v.sport)} · {v.indoor ? 'Trong nhà' : 'Ngoài trời'}</div>
                  </div>
                  <div className="v-price" style={{ fontSize: 13 }}>{fmtVND(v.price)}<span>mỗi giờ</span></div>
                  <MIconButton icon="close" size={18} title="Bỏ" onClick={() => onRemoveVenue(i)} />
                </div>
              </React.Fragment>
            ))}
          </div>
        )}
        <div style={{ display: 'flex', gap: 8 }}>
          <MChip type="assist" icon="add" onClick={onOpenVenueDialog}>Thêm sân con</MChip>
          <MChip type="assist" icon="auto_awesome" onClick={onOpenBulk}>Tạo nhanh bằng AI</MChip>
        </div>
      </div>
    </div>
  );
};

/* ---------- full court form screen ---------- */
const CourtFormScreen = ({ initial, onSave, onCancel, aiEntry, flow, aiOpen, setAiOpen, injected }) => {
  const [form, setForm] = useStateF({ ...EMPTY_COURT, ...initial });
  const [aiFilled, setAiFilled] = useStateF(new Set());
  const [errors, setErrors] = useStateF({});
  const [descBusy, setDescBusy] = useStateF(false);
  const [venueDialog, setVenueDialog] = useStateF(false);
  const [bulkOpen, setBulkOpen] = useStateF(false);
  const snack = useSnack();

  const set = (k, v) => {
    setForm(f => ({ ...f, [k]: v }));
    setAiFilled(s => { if (!s.has(k)) return s; const n = new Set(s); n.delete(k); return n; });
    setErrors(e => ({ ...e, [k]: undefined }));
  };

  const applyAI = (data, silent) => {
    const keys = [];
    setForm(f => {
      const next = { ...f };
      Object.entries(data).forEach(([k, v]) => {
        if (v === null || v === undefined || v === '') return;
        if (k === 'venues') {
          if (Array.isArray(v) && v.length) { next.venues = v.map((x, i) => ({ ...x, id: 'v' + Date.now() + i })); keys.push(k); }
          return;
        }
        if (k === 'amenities' && (!Array.isArray(v) || !v.length)) return;
        if (!(k in next)) return;
        next[k] = k === 'lat' || k === 'lng' ? String(v) : v;
        keys.push(k);
      });
      return next;
    });
    setAiFilled(s => new Set([...s, ...keys]));
    if (!silent && keys.length) snack(`AI đã điền ${keys.length} trường — các trường được đánh dấu ✦`);
  };

  // data injected from intake screen / chat
  useEffectF(() => { if (injected && injected.data) applyAI(injected.data, injected.silent); }, [injected && injected.ts]);

  const writeDesc = async () => {
    setDescBusy(true);
    try {
      const d = await aiWriteDescription(form);
      setForm(f => ({ ...f, description: d }));
      setAiFilled(s => new Set([...s, 'description']));
    } catch (e) { snack('Không gọi được AI — thử lại nhé'); }
    setDescBusy(false);
  };

  const save = () => {
    const errs = {};
    if (!form.name.trim()) errs.name = 'Bắt buộc — nhập tên sân';
    if (!form.address.trim()) errs.address = 'Bắt buộc — nhập địa chỉ';
    setErrors(errs);
    if (Object.keys(errs).length) { snack('Còn trường bắt buộc chưa điền'); return; }
    onSave(form);
  };

  const aiPanel = <AIPanelBody compact={aiEntry === 'side'} onApply={(data) => { applyAI(data); setAiOpen(false); }} />;

  const inlineAI = (flow === 'form' && aiEntry === 'inline') ? (
    <div className="ai-inline-card">
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
        <AIPanelHeader />
        <MIconButton icon={aiOpen ? 'expand_less' : 'expand_more'} title="Thu gọn" onClick={() => setAiOpen(!aiOpen)} />
      </div>
      {aiOpen && <div style={{ marginTop: 8 }}>{aiPanel}</div>}
    </div>
  ) : null;

  const body = (
    <CourtFormBody
      form={form} set={set} aiFilled={aiFilled} errors={errors}
      onWriteDesc={writeDesc} descBusy={descBusy}
      onOpenVenueDialog={() => setVenueDialog(true)}
      onOpenBulk={() => setBulkOpen(true)}
      onRemoveVenue={(i) => setForm(f => ({ ...f, venues: f.venues.filter((_, j) => j !== i) }))}
      inlineAI={inlineAI}
    />
  );

  const footer = (
    <div className="form-footer">
      <MButton variant="text" onClick={onCancel}>Huỷ</MButton>
      <MButton variant="outlined" onClick={() => { onSave({ ...form, status: 'draft' }); }}>Lưu nháp</MButton>
      <MButton variant="filled" icon="check" onClick={save}>{initial && initial.id ? 'Lưu thay đổi' : 'Tạo sân'}</MButton>
    </div>
  );

  const dialogs = (
    <React.Fragment>
      <VenueDialog open={venueDialog} initial={null} onClose={() => setVenueDialog(false)}
        onSave={(v) => { setForm(f => ({ ...f, venues: [...f.venues, { ...v, id: 'v' + Date.now() }] })); setVenueDialog(false); }} />
      <VenueBulkSheet open={bulkOpen} onClose={() => setBulkOpen(false)}
        onCreate={(list) => { setForm(f => ({ ...f, venues: [...f.venues, ...list.map((v, i) => ({ ...v, id: 'v' + Date.now() + i }))] })); setBulkOpen(false); snack(`Đã thêm ${list.length} sân con`); }} />
    </React.Fragment>
  );

  /* --- chat flow: split layout --- */
  if (flow === 'chat' && !(initial && initial.id)) {
    return (
      <div className="chat-split" data-screen-label="Thêm sân — chat từng bước">
        <div className="chat-pane">
          <div className="ai-head" style={{ marginBottom: 10 }}>
            <div className="spark"><MIcon name="forum" size={20} /></div>
            <div><h3 style={{ fontSize: 16 }}>Trợ lý khai báo sân</h3><p>Trả lời từng câu — form tự điền</p></div>
          </div>
          <ChatAssist fillLive onData={(data) => applyAI(data, true)} style={{ flex: 1, minHeight: 0 }} />
        </div>
        <div className="form-pane">
          <div style={{ maxWidth: 760 }}>
            {body}
            {footer}
          </div>
        </div>
        {dialogs}
      </div>
    );
  }

  return (
    <div className="content-inner" data-screen-label={initial && initial.id ? 'Sửa sân' : 'Thêm sân mới'}>
      {body}
      {footer}
      {dialogs}

      {flow === 'form' && aiEntry === 'sheet' && (
        <MBottomSheet open={aiOpen} onClose={() => setAiOpen(false)}>
          <AIPanelHeader />
          <div style={{ marginTop: 4 }}>{aiPanel}</div>
        </MBottomSheet>
      )}
      {flow === 'form' && aiEntry === 'side' && (
        <MSideSheet open={aiOpen} onClose={() => setAiOpen(false)} title="Nhập nhanh bằng AI">
          {aiPanel}
        </MSideSheet>
      )}
    </div>
  );
};

/* ---------- AI-first intake screen ---------- */
const IntakeScreen = ({ onApply, onSkip }) => (
  <div className="content-inner" data-screen-label="Thêm sân — AI nhập trước">
    <div className="intake-hero">
      <div className="spark-lg"><MIcon name="auto_awesome" size={30} /></div>
      <h1>Thêm sân mới</h1>
      <p>Dán thông tin sân — bài đăng Facebook, tin Zalo, liên kết Maps hay ảnh bảng giá.<br />AI sẽ điền form giúp bạn, bạn chỉ kiểm tra lại.</p>
    </div>
    <div className="m3-card intake-card" style={{ padding: 24, background: 'var(--md-surface-container-low)' }}>
      <AIPanelBody onApply={onApply} />
    </div>
    <div style={{ textAlign: 'center', marginTop: 18 }}>
      <MButton variant="text" icon="keyboard" onClick={onSkip}>Bỏ qua — tự nhập tay</MButton>
    </div>
  </div>
);

Object.assign(window, { CourtFormScreen, IntakeScreen, CourtFormBody });
