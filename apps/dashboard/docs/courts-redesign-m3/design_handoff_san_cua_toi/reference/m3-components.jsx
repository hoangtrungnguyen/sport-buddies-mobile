// M3 primitives — Material 3 components as React (shared via window)
const { useState, useRef, useEffect, useContext, createContext } = React;

const MIcon = ({ name, size = 24, fill, style, className = '' }) => (
  <span className={`msr ${fill ? 'fill' : ''} ${className}`} style={{ fontSize: size, ...style }} aria-hidden="true">{name}</span>
);

const MButton = ({ variant = 'filled', icon, children, onClick, disabled, full, style, type }) => (
  <button type={type || 'button'} className={`m3-btn ${variant} ${full ? 'full' : ''}`} onClick={onClick} disabled={disabled} style={style}>
    {icon && <MIcon name={icon} size={18} />}
    {children}
  </button>
);

const MIconButton = ({ icon, variant = '', onClick, title, fill, style, size = 24 }) => (
  <button type="button" className={`m3-iconbtn ${variant}`} onClick={onClick} title={title} aria-label={title} style={style}>
    <MIcon name={icon} size={size} fill={fill} />
  </button>
);

const MChip = ({ selected, icon, onClick, children, type = 'filter', sm, style }) => (
  <button
    type="button"
    className={`m3-chip ${selected ? 'selected' : ''} ${type} ${sm ? 'sm' : ''} ${onClick ? '' : 'static'}`}
    onClick={onClick}
    style={style}
  >
    {(selected && type === 'filter') ? <MIcon name="check" size={sm ? 15 : 18} /> : (icon && <MIcon name={icon} size={sm ? 15 : 18} />)}
    {children}
  </button>
);

/* ---------- Text field (outlined / filled via FieldStyleContext) ---------- */
const FieldStyleContext = createContext('outlined');

const MTextField = ({
  label, value, onChange, placeholder, leadingIcon, trailing, supporting,
  error, textarea, rows = 3, type = 'text', aiFilled, style, inputStyle, onClear, disabled,
}) => {
  const fieldStyle = useContext(FieldStyleContext);
  const [focused, setFocused] = useState(false);
  const ref = useRef(null);
  const floated = (value !== undefined && value !== null && String(value).length > 0) || !label;
  const cls = [
    'm3-field', fieldStyle, textarea ? 'textarea' : '',
    focused ? 'focused' : '', floated ? 'floated' : '',
    error ? 'error' : '', leadingIcon ? 'has-lead' : '',
    aiFilled ? 'ai-filled' : '', label ? '' : 'no-label',
  ].join(' ');
  const showPlaceholder = !label || focused || floated;
  const common = {
    ref, value: value ?? '', disabled,
    placeholder: showPlaceholder ? placeholder : undefined,
    onChange: e => onChange && onChange(e.target.value),
    onFocus: () => setFocused(true), onBlur: () => setFocused(false),
  };
  return (
    <div className={cls} style={style}>
      <div className="box" onClick={() => ref.current && ref.current.focus()}>
        {leadingIcon && <MIcon name={leadingIcon} className="lead" size={22} />}
        {label && <span className="flabel">{label}</span>}
        {textarea
          ? <textarea rows={rows} {...common} style={inputStyle}></textarea>
          : <input type={type} {...common} style={inputStyle} />}
        {(onClear && floated && String(value || '').length > 0) && (
          <span className="trail"><MIconButton icon="close" size={18} title="Xoá" onClick={() => onClear()} /></span>
        )}
        {trailing && <span className="trail">{trailing}</span>}
      </div>
      {(supporting || error || aiFilled) && (
        <div className={`support ${error ? 'err' : ''} ${aiFilled && !error ? 'ai' : ''}`}>
          {aiFilled && !error && <MIcon name="auto_awesome" size={14} />}
          {error || (aiFilled ? 'Điền bởi AI — hãy kiểm tra lại' : supporting)}
        </div>
      )}
    </div>
  );
};

const MSelect = ({ label, value, onChange, options, leadingIcon, style, supporting }) => {
  const fieldStyle = useContext(FieldStyleContext);
  const [focused, setFocused] = useState(false);
  return (
    <div className={`m3-field ${fieldStyle} floated ${focused ? 'focused' : ''} ${leadingIcon ? 'has-lead' : ''}`} style={style}>
      <div className="box" style={{ cursor: 'pointer' }}>
        {leadingIcon && <MIcon name={leadingIcon} className="lead" size={22} />}
        {label && <span className="flabel">{label}</span>}
        <select value={value} onChange={e => onChange(e.target.value)} onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}>
          {options.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
        <MIcon name="arrow_drop_down" size={24} style={{ color: 'var(--md-on-surface-variant)' }} />
      </div>
      {supporting && <div className="support">{supporting}</div>}
    </div>
  );
};

const MSwitch = ({ on, onChange, label }) => (
  <button type="button" onClick={() => onChange(!on)} style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
    <span className={`m3-switch ${on ? 'on' : ''}`}><span className="thumb">{on && <MIcon name="check" size={16} />}</span></span>
    {label && <span className="body-md">{label}</span>}
  </button>
);

const MSegmented = ({ options, value, onChange, style }) => (
  <div className="m3-seg" style={style}>
    {options.map(o => (
      <button key={o.value} type="button" className={value === o.value ? 'on' : ''} onClick={() => onChange(o.value)}>
        {value === o.value ? <MIcon name="check" size={18} /> : (o.icon && <MIcon name={o.icon} size={18} />)}
        {o.label}
      </button>
    ))}
  </div>
);

const MDialog = ({ open, onClose, icon, title, children, actions, width }) => {
  if (!open) return null;
  return (
    <React.Fragment>
      <div className="m3-scrim" onClick={onClose}></div>
      <div className="m3-dialog" style={width ? { width: `min(${width}px, calc(100vw - 48px))` } : undefined} role="dialog">
        <div className="dlg-head">
          {icon && <MIcon name={icon} className="hero" />}
          <div className="headline-sm" style={{ textAlign: icon ? 'center' : 'left' }}>{title}</div>
        </div>
        <div className="dlg-body">{children}</div>
        {actions && <div className="dlg-actions">{actions}</div>}
      </div>
    </React.Fragment>
  );
};

const MBottomSheet = ({ open, onClose, children }) => {
  if (!open) return null;
  return (
    <React.Fragment>
      <div className="m3-scrim" onClick={onClose}></div>
      <div className="m3-sheet" role="dialog">
        <div className="handle"></div>
        <div className="sheet-body">{children}</div>
      </div>
    </React.Fragment>
  );
};

const MSideSheet = ({ open, onClose, title, children }) => {
  if (!open) return null;
  return (
    <React.Fragment>
      <div className="m3-scrim" onClick={onClose}></div>
      <div className="m3-side" role="dialog">
        <div className="side-head">
          <span className="title-lg" style={{ flex: 1 }}>{title}</span>
          <MIconButton icon="close" onClick={onClose} title="Đóng" />
        </div>
        <div className="side-body">{children}</div>
      </div>
    </React.Fragment>
  );
};

const MLinear = ({ style }) => <div className="m3-linear" style={style}><div className="bar"></div></div>;
const MSpinner = ({ style }) => <div className="m3-spinner" style={style}></div>;

/* ---------- Snackbar context ---------- */
const SnackContext = createContext(() => {});
const useSnack = () => useContext(SnackContext);

const SnackHost = ({ children }) => {
  const [snack, setSnack] = useState(null);
  const timer = useRef(null);
  const show = (msg, action) => {
    clearTimeout(timer.current);
    setSnack({ msg, action });
    timer.current = setTimeout(() => setSnack(null), 4500);
  };
  return (
    <SnackContext.Provider value={show}>
      {children}
      {snack && (
        <div className="m3-snackbar">
          <span>{snack.msg}</span>
          {snack.action
            ? <button onClick={() => { snack.action.fn(); setSnack(null); }}>{snack.action.label}</button>
            : <button onClick={() => setSnack(null)}>OK</button>}
        </div>
      )}
    </SnackContext.Provider>
  );
};

/* ---------- Misc ---------- */
const PhotoPh = ({ label = 'ảnh sân', icon = 'image', style, className = '' }) => (
  <div className={`ph ${className}`} style={style}>
    <MIcon name={icon} />
    <span>{label}</span>
  </div>
);

const StatusChip = ({ status }) => {
  const map = {
    active: { cls: 'active', icon: 'check_circle', t: 'Hoạt động' },
    pending: { cls: 'pending', icon: 'hourglass_top', t: 'Chờ duyệt' },
    draft: { cls: 'draft', icon: 'edit_note', t: 'Bản nháp' },
  };
  const m = map[status] || map.draft;
  return <span className={`status-chip ${m.cls}`}><MIcon name={m.icon} size={14} fill />{m.t}</span>;
};

Object.assign(window, {
  MIcon, MButton, MIconButton, MChip, MTextField, MSelect, MSwitch, MSegmented,
  MDialog, MBottomSheet, MSideSheet, MLinear, MSpinner,
  SnackHost, useSnack, FieldStyleContext, PhotoPh, StatusChip,
});
