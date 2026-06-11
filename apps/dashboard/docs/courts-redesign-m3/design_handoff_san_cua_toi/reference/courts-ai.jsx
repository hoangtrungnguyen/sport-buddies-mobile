// AI extraction logic + assist panel UI (text / link / photo / chat)
const { useState: useStateAI, useRef: useRefAI, useEffect: useEffectAI } = React;

/* ================= Helpers ================= */
const extractJSON = (text) => {
  if (!text) return null;
  const a = text.indexOf('{');
  const b = text.lastIndexOf('}');
  if (a === -1 || b === -1 || b <= a) return null;
  try { return JSON.parse(text.slice(a, b + 1)); } catch (e) { return null; }
};

const COURT_SCHEMA = `{
  "name": string|null, "address": string|null,
  "lat": number|null, "lng": number|null,
  "mapsUrl": string|null, "phone": string|null,
  "description": string|null,
  "openTime": "HH:MM"|null, "closeTime": "HH:MM"|null,
  "amenities": string[] — CHỈ dùng các khoá: parking, locker, toilet, canteen, equipment, wifi, lights, roof,
  "venues": [{"name": string, "sport": "pickleball"|"badminton"|"football"|"tennis", "price": number (VND/giờ), "indoor": boolean}] | null
}`;

const aiExtractCourt = async (text) => {
  const prompt = `Bạn là công cụ trích xuất dữ liệu sân thể thao cho ứng dụng quản lý sân tại Việt Nam.
Từ văn bản dưới đây, trích xuất thông tin và trả về DUY NHẤT một khối JSON đúng schema sau, không giải thích gì thêm:
${COURT_SCHEMA}
Quy tắc: trường không có thông tin → null. Giá tiền: "120k" = 120000. Giờ: "6h" = "06:00". Nếu văn bản nêu số lượng sân (vd "4 sân pickleball giá 120k"), tạo từng sân con riêng (Sân 1, Sân 2, ...).
VĂN BẢN:
"""${text}"""`;
  const raw = await window.claude.complete(prompt);
  const data = extractJSON(raw);
  if (!data) throw new Error('AI không trả về JSON hợp lệ');
  return data;
};

const aiExtractVenues = async (text) => {
  const prompt = `Trích xuất danh sách sân con (court/venue) từ văn bản tiếng Việt dưới đây. Trả về DUY NHẤT JSON:
{"venues": [{"name": string, "sport": "pickleball"|"badminton"|"football"|"tennis", "price": number (VND/giờ), "indoor": boolean}]}
Quy tắc: "120k" = 120000. Nếu nêu số lượng (vd "4 sân pickleball"), tạo từng sân riêng với tên đánh số (Sân 1, Sân 2, ...). Không rõ trong nhà/ngoài trời → indoor: false.
VĂN BẢN:
"""${text}"""`;
  const raw = await window.claude.complete(prompt);
  const data = extractJSON(raw);
  if (!data || !Array.isArray(data.venues)) throw new Error('AI không trả về JSON hợp lệ');
  return data.venues;
};

const aiWriteDescription = async (form) => {
  const am = (form.amenities || []).map(id => (AMENITIES.find(a => a.id === id) || {}).label).filter(Boolean).join(', ');
  const vs = (form.venues || []).map(v => `${v.name} (${sportLabel(v.sport)})`).join(', ');
  const prompt = `Viết mô tả ngắn (2–3 câu, tiếng Việt, thân thiện, không dùng emoji, không phóng đại) cho sân thể thao sau để hiển thị cho khách đặt sân:
Tên: ${form.name || 'chưa rõ'}. Địa chỉ: ${form.address || 'chưa rõ'}. Giờ: ${form.openTime}–${form.closeTime}. Tiện ích: ${am || 'chưa rõ'}. Sân con: ${vs || 'chưa rõ'}.
Chỉ trả về đoạn mô tả, không có gì khác.`;
  const raw = await window.claude.complete(prompt);
  return raw.trim().replace(/^["']|["']$/g, '');
};

// Parse a Google Maps URL client-side (lat/lng + place name)
const parseMapsUrl = (url) => {
  const out = { mapsUrl: url };
  let m = url.match(/@(-?\d+\.\d+),(-?\d+\.\d+)/);
  if (!m) m = url.match(/[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)/);
  if (!m) m = url.match(/!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)/);
  if (m) { out.lat = parseFloat(m[1]); out.lng = parseFloat(m[2]); }
  const p = url.match(/\/place\/([^/@?]+)/);
  if (p) out.name = decodeURIComponent(p[1]).replace(/\+/g, ' ');
  return out;
};

// Simulated flyer OCR result (photo tab — vision not wired in prototype)
const DEMO_FLYER = {
  name: 'CLB Pickleball Sunrise', address: '212 Huỳnh Tấn Phát, Quận 7, TP.HCM',
  phone: '0908 222 333', openTime: '05:30', closeTime: '22:30',
  amenities: ['parking', 'wifi', 'lights', 'canteen'],
  venues: [
    { name: 'Sân 1', sport: 'pickleball', price: 130000, indoor: true },
    { name: 'Sân 2', sport: 'pickleball', price: 130000, indoor: true },
    { name: 'Sân 3', sport: 'pickleball', price: 110000, indoor: false },
  ],
};

const fmtVND = (n) => (n || 0).toLocaleString('vi-VN') + 'đ';

// Render a review value for a court field
const reviewValue = (key, val) => {
  if (val === null || val === undefined || val === '' ) return null;
  if (key === 'amenities') {
    const labels = (val || []).map(id => (AMENITIES.find(a => a.id === id) || {}).label).filter(Boolean);
    return labels.length ? labels.join(' · ') : null;
  }
  if (key === 'venues') {
    if (!Array.isArray(val) || !val.length) return null;
    return `${val.length} sân: ` + val.map(v => `${v.name} (${sportLabel(v.sport)} · ${fmtVND(v.price)}/giờ)`).join(', ');
  }
  return String(val);
};

/* ================= Review list ================= */
const ReviewList = ({ data, checked, onToggle }) => {
  const rows = COURT_FIELD_META
    .map(f => ({ ...f, value: reviewValue(f.key, data[f.key]) }))
    .filter(f => f.value !== null);
  if (!rows.length) return <p className="body-md" style={{ color: 'var(--md-on-surface-variant)' }}>AI không tìm thấy thông tin nào trong nội dung này.</p>;
  return (
    <div className="review-list">
      {rows.map(f => (
        <div key={f.key} className={`review-row ${checked[f.key] === false ? 'off' : ''}`}>
          <button type="button" className={`rv-check ${checked[f.key] !== false ? 'on' : ''}`} onClick={() => onToggle(f.key)} aria-label={`Chọn ${f.label}`}>
            {checked[f.key] !== false && <MIcon name="check" size={16} />}
          </button>
          <span className="rv-label">{f.label}</span>
          <span className="rv-value">{f.value}</span>
        </div>
      ))}
    </div>
  );
};

/* ================= Chat assistant ================= */
const CHAT_PREAMBLE = `Bạn là trợ lý nhập liệu của SportBuddies, giúp chủ sân Việt Nam khai báo sân thể thao. Trò chuyện tiếng Việt, ngắn gọn, thân thiện.
Thông tin cần thu thập: tên sân, địa chỉ, giờ mở/đóng cửa, số điện thoại, tiện ích (parking, locker, toilet, canteen, equipment, wifi, lights, roof), các sân con (tên, môn: pickleball/badminton/football/tennis, giá VND/giờ, trong nhà hay không).
MỖI lượt trả lời của bạn PHẢI có 2 phần:
1. Một câu phản hồi ngắn + MỘT câu hỏi tiếp theo về thông tin còn thiếu (đừng hỏi nhiều thứ cùng lúc). Khi đã đủ tên + địa chỉ + giờ, nói: "Đã đủ thông tin chính — bạn có thể bấm Hoàn tất."
2. Khối \`\`\`json chứa TOÀN BỘ dữ liệu đã biết tới giờ theo schema: ${COURT_SCHEMA}
Bắt đầu: chào ngắn gọn và hỏi tên + địa chỉ sân.`;

const stripJsonBlock = (text) => text.replace(/```json[\s\S]*?```/g, '').replace(/```[\s\S]*?```/g, '').trim();

const ChatAssist = ({ onData, fillLive, style }) => {
  const [msgs, setMsgs] = useStateAI([{ role: 'assistant', content: 'Xin chào! Tôi sẽ giúp bạn khai báo sân mới. Trước tiên, sân của bạn tên gì và ở địa chỉ nào?' }]);
  const [input, setInput] = useStateAI('');
  const [busy, setBusy] = useStateAI(false);
  const boxRef = useRefAI(null);

  useEffectAI(() => {
    if (boxRef.current) boxRef.current.scrollTop = boxRef.current.scrollHeight;
  }, [msgs, busy]);

  const send = async () => {
    const text = input.trim();
    if (!text || busy) return;
    const hist = [...msgs, { role: 'user', content: text }];
    setMsgs(hist); setInput(''); setBusy(true);
    try {
      const apiMsgs = [
        { role: 'user', content: CHAT_PREAMBLE },
        ...hist.map(m => ({ role: m.role, content: m.content + (m.role === 'assistant' && m.raw ? '\n' + m.raw : '') })),
      ];
      const raw = await window.claude.complete({ messages: apiMsgs });
      const data = extractJSON(raw);
      if (data && onData) onData(data);
      setMsgs(h => [...h, { role: 'assistant', content: stripJsonBlock(raw) || 'Đã ghi nhận!', raw: (raw.match(/```json[\s\S]*?```/) || [''])[0] }]);
    } catch (e) {
      setMsgs(h => [...h, { role: 'assistant', content: 'Xin lỗi, tôi gặp lỗi khi xử lý. Bạn thử lại nhé.' }]);
    }
    setBusy(false);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: 0, ...style }}>
      <div className="chat-box" ref={boxRef}>
        {msgs.map((m, i) => <div key={i} className={`chat-msg ${m.role === 'assistant' ? 'ai' : 'user'}`}>{m.content}</div>)}
        {busy && <div className="chat-msg ai" style={{ display: 'flex', gap: 10, alignItems: 'center' }}><MSpinner style={{ width: 16, height: 16, borderWidth: 2 }} /> Đang suy nghĩ…</div>}
      </div>
      {fillLive && <div className="body-sm" style={{ color: 'var(--md-tertiary)', display: 'flex', gap: 6, alignItems: 'center', margin: '6px 2px 0' }}><MIcon name="auto_awesome" size={14} /> Form bên phải được điền tự động sau mỗi câu trả lời</div>}
      <div className="chat-input-row">
        <input
          value={input} placeholder="Nhập câu trả lời…"
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => { if (e.key === 'Enter') send(); }}
        />
        <MIconButton icon="send" variant="filled" onClick={send} title="Gửi" />
      </div>
    </div>
  );
};

/* ================= AI assist panel (tabs + review state machine) ================= */
const AI_TABS = [
  { id: 'text', label: 'Văn bản', icon: 'notes' },
  { id: 'link', label: 'Liên kết', icon: 'link' },
  { id: 'photo', label: 'Ảnh', icon: 'photo_camera' },
  { id: 'chat', label: 'Hỏi đáp', icon: 'forum' },
];

const AIPanelBody = ({ onApply, compact }) => {
  const [tab, setTab] = useStateAI('text');
  const [text, setText] = useStateAI('');
  const [link, setLink] = useStateAI('');
  const [photoName, setPhotoName] = useStateAI(null);
  const [phase, setPhase] = useStateAI('input'); // input | loading | review
  const [result, setResult] = useStateAI(null);
  const [checked, setChecked] = useStateAI({});
  const [err, setErr] = useStateAI(null);
  const snack = useSnack();
  const fileRef = useRefAI(null);

  const runExtract = async (fn) => {
    setPhase('loading'); setErr(null);
    try {
      const data = await fn();
      setResult(data); setChecked({}); setPhase('review');
    } catch (e) {
      setErr(e.message || 'Có lỗi xảy ra. Thử lại nhé.');
      setPhase('input');
    }
  };

  const analyzeText = () => runExtract(() => aiExtractCourt(text));
  const analyzeLink = () => runExtract(async () => {
    const parsed = parseMapsUrl(link.trim());
    // enrich with AI from the URL text itself (place names, query strings)
    try {
      const data = await aiExtractCourt(`URL sân thể thao: ${link}\nTên nơi chốn (nếu có trong URL): ${parsed.name || ''}`);
      return { ...data, ...Object.fromEntries(Object.entries(parsed).filter(([, v]) => v != null)) };
    } catch (e) {
      if (parsed.lat || parsed.name) return parsed;
      throw e;
    }
  });
  const analyzePhoto = () => runExtract(async () => {
    await new Promise(r => setTimeout(r, 1400)); // simulated OCR
    return DEMO_FLYER;
  });

  const apply = () => {
    const data = {};
    COURT_FIELD_META.forEach(f => {
      if (checked[f.key] === false) return;
      if (reviewValue(f.key, result[f.key]) !== null) data[f.key] = result[f.key];
    });
    onApply(data);
  };

  if (phase === 'loading') {
    return (
      <div style={{ padding: '36px 8px', textAlign: 'center' }}>
        <MSpinner style={{ margin: '0 auto 16px' }} />
        <div className="title-md">AI đang phân tích…</div>
        <p className="body-md" style={{ color: 'var(--md-on-surface-variant)', marginTop: 4 }}>Trích xuất tên, địa chỉ, giờ mở cửa, tiện ích, sân con</p>
        <MLinear style={{ maxWidth: 280, margin: '20px auto 0' }} />
      </div>
    );
  }

  if (phase === 'review') {
    return (
      <div>
        <div className="title-md" style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
          <MIcon name="fact_check" size={20} style={{ color: 'var(--md-primary)' }} /> Kiểm tra trước khi điền
        </div>
        <p className="body-md" style={{ color: 'var(--md-on-surface-variant)', marginBottom: 14 }}>
          Bỏ chọn những dòng không đúng — chỉ các dòng được chọn sẽ điền vào form.
        </p>
        <ReviewList data={result} checked={checked} onToggle={k => setChecked(c => ({ ...c, [k]: c[k] === false ? true : false }))} />
        <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end', marginTop: 18 }}>
          <MButton variant="text" icon="arrow_back" onClick={() => setPhase('input')}>Sửa lại</MButton>
          <MButton variant="filled" icon="auto_awesome" onClick={apply}>Điền vào form</MButton>
        </div>
      </div>
    );
  }

  return (
    <div>
      <div className="ai-tabs">
        {AI_TABS.map(t => (
          <button key={t.id} className={tab === t.id ? 'on' : ''} onClick={() => setTab(t.id)}>
            <MIcon name={t.icon} size={19} />{t.label}
          </button>
        ))}
      </div>

      {err && (
        <div style={{ background: 'var(--md-error-container)', color: 'var(--md-on-error-container)', borderRadius: 12, padding: '10px 14px', fontSize: 13, marginBottom: 12, display: 'flex', gap: 8, alignItems: 'center' }}>
          <MIcon name="error" size={18} /> {err}
        </div>
      )}

      {tab === 'text' && (
        <div>
          <textarea
            className="ai-textarea" value={text} onChange={e => setText(e.target.value)}
            placeholder={'Dán thông tin sân — tên, địa chỉ, giờ mở cửa, giá, tiện ích…\n\nVí dụ: "Sân Pickleball ABC, 123 Nguyễn Trãi Q1, mở 6h-22h, có 4 sân trong nhà giá 120k/h, WiFi và bãi đậu xe"'}
            rows={compact ? 5 : 7}
          ></textarea>
          <p className="ai-hint">Mẹo: dán nguyên bài đăng Facebook, tin Zalo hoặc ghi chú của bạn — AI tự nhặt thông tin và bạn sẽ kiểm tra lại trước khi điền.</p>
          <MButton variant="filled" icon="auto_awesome" full onClick={analyzeText} disabled={!text.trim()}>Phân tích bằng AI</MButton>
        </div>
      )}

      {tab === 'link' && (
        <div>
          <MTextField label="Liên kết Google Maps hoặc Facebook" value={link} onChange={setLink} leadingIcon="link" placeholder="https://maps.google.com/…" supporting="Toạ độ và tên địa điểm được đọc trực tiếp từ liên kết" />
          <div style={{ height: 10 }}></div>
          <MButton variant="filled" icon="travel_explore" full onClick={analyzeLink} disabled={!link.trim()}>Đọc liên kết</MButton>
        </div>
      )}

      {tab === 'photo' && (
        <div>
          <input ref={fileRef} type="file" accept="image/*" style={{ display: 'none' }} onChange={e => setPhotoName(e.target.files[0] ? e.target.files[0].name : null)} />
          <div className="ai-drop" onClick={() => fileRef.current && fileRef.current.click()}>
            <MIcon name={photoName ? 'task' : 'add_photo_alternate'} />
            <span className="title-sm">{photoName || 'Chụp hoặc tải ảnh bảng giá, tờ rơi'}</span>
            <span className="body-sm">PNG, JPG — AI đọc chữ trong ảnh</span>
          </div>
          <p className="ai-hint">Trong prototype này, kết quả đọc ảnh được mô phỏng (bản production dùng Claude Vision).</p>
          <MButton variant="filled" icon="document_scanner" full onClick={analyzePhoto} disabled={!photoName}>Đọc ảnh</MButton>
        </div>
      )}

      {tab === 'chat' && (
        <ChatAssist onData={(data) => { setResult(data); }} style={{ minHeight: 280 }} />
      )}
      {tab === 'chat' && result && (
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <MButton variant="tonal" icon="fact_check" onClick={() => { setChecked({}); setPhase('review'); }}>Xem dữ liệu đã thu thập</MButton>
        </div>
      )}
    </div>
  );
};

const AIPanelHeader = () => (
  <div className="ai-head">
    <div className="spark"><MIcon name="auto_awesome" size={22} /></div>
    <div>
      <h3>Nhập nhanh bằng AI</h3>
      <p>Dán văn bản, liên kết hoặc ảnh — AI điền form, bạn duyệt lại</p>
    </div>
  </div>
);

Object.assign(window, {
  extractJSON, aiExtractCourt, aiExtractVenues, aiWriteDescription, parseMapsUrl,
  ReviewList, ChatAssist, AIPanelBody, AIPanelHeader, fmtVND, reviewValue,
});
