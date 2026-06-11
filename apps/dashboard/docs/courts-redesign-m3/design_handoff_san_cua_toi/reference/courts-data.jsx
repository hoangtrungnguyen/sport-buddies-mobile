// Sample data + constants for the Sân của tôi prototype
const AMENITIES = [
  { id: 'parking', label: 'Bãi đậu xe', icon: 'local_parking' },
  { id: 'locker', label: 'Phòng thay đồ', icon: 'checkroom' },
  { id: 'toilet', label: 'Nhà vệ sinh', icon: 'wc' },
  { id: 'canteen', label: 'Căng tin', icon: 'storefront' },
  { id: 'equipment', label: 'Thuê thiết bị', icon: 'sports_tennis' },
  { id: 'wifi', label: 'WiFi', icon: 'wifi' },
  { id: 'lights', label: 'Đèn chiếu sáng', icon: 'lightbulb' },
  { id: 'roof', label: 'Mái che', icon: 'roofing' },
];

const SPORTS = [
  { id: 'pickleball', label: 'Pickleball', icon: 'sports_tennis' },
  { id: 'badminton', label: 'Cầu lông', icon: 'sports_tennis' },
  { id: 'football', label: 'Bóng đá', icon: 'sports_soccer' },
  { id: 'tennis', label: 'Tennis', icon: 'sports_baseball' },
];
const sportLabel = (id) => (SPORTS.find(s => s.id === id) || {}).label || id;

const HOURS = [];
for (let h = 5; h <= 23; h++) { HOURS.push(`${String(h).padStart(2, '0')}:00`); HOURS.push(`${String(h).padStart(2, '0')}:30`); }

const EMPTY_COURT = {
  id: null, name: '', address: '', lat: '', lng: '', mapsUrl: '', phone: '',
  description: '', amenities: [], openTime: '06:00', closeTime: '22:00',
  status: 'draft', venues: [],
};

const SEED_COURTS = [
  {
    ...EMPTY_COURT,
    id: 'c1', name: 'SnB Đại Lộc', address: '88 Đào Trí, Phú Thuận, Quận 7, TP.HCM',
    lat: '10.7180', lng: '106.7361', phone: '0903 555 888',
    mapsUrl: 'https://maps.google.com/?q=10.7180,106.7361',
    description: 'Cụm sân pickleball & cầu lông trong nhà, mặt sân tiêu chuẩn thi đấu, có chỗ đậu ô tô.',
    amenities: ['parking', 'toilet', 'wifi', 'lights', 'roof'],
    openTime: '06:00', closeTime: '22:00', status: 'active',
    venues: [
      { id: 'v1', name: 'Sân 1', sport: 'pickleball', price: 120000, indoor: true },
      { id: 'v2', name: 'Sân 2', sport: 'pickleball', price: 120000, indoor: true },
      { id: 'v3', name: 'Sân 3', sport: 'pickleball', price: 100000, indoor: false },
      { id: 'v4', name: 'Sân A', sport: 'badminton', price: 80000, indoor: true },
      { id: 'v5', name: 'Sân B', sport: 'badminton', price: 80000, indoor: true },
    ],
  },
  {
    ...EMPTY_COURT,
    id: 'c2', name: 'SnB Phú Mỹ Hưng', address: '15 Nguyễn Lương Bằng, Tân Phú, Quận 7, TP.HCM',
    lat: '10.7295', lng: '106.7019', phone: '0903 555 888',
    description: 'Sân pickleball ngoài trời khu PMH, gió mát, đèn LED thi đấu ban đêm.',
    amenities: ['parking', 'toilet', 'lights'],
    openTime: '05:30', closeTime: '23:00', status: 'pending',
    venues: [
      { id: 'v6', name: 'Sân P1', sport: 'pickleball', price: 140000, indoor: false },
      { id: 'v7', name: 'Sân P2', sport: 'pickleball', price: 140000, indoor: false },
    ],
  },
  {
    ...EMPTY_COURT,
    id: 'c3', name: 'Sân Thể Thao Tân Quy', address: '290 Lê Văn Lương, Tân Quy, Quận 7, TP.HCM',
    lat: '10.7412', lng: '106.7008',
    description: '',
    amenities: ['toilet', 'canteen'],
    openTime: '06:00', closeTime: '21:00', status: 'draft',
    venues: [
      { id: 'v8', name: 'Sân 5 người', sport: 'football', price: 300000, indoor: false },
    ],
  },
];

// Field metadata for the AI review step
const COURT_FIELD_META = [
  { key: 'name', label: 'Tên sân' },
  { key: 'address', label: 'Địa chỉ' },
  { key: 'lat', label: 'Vĩ độ' },
  { key: 'lng', label: 'Kinh độ' },
  { key: 'mapsUrl', label: 'Google Maps' },
  { key: 'phone', label: 'Điện thoại' },
  { key: 'openTime', label: 'Giờ mở cửa' },
  { key: 'closeTime', label: 'Giờ đóng cửa' },
  { key: 'amenities', label: 'Tiện ích' },
  { key: 'description', label: 'Mô tả' },
  { key: 'venues', label: 'Sân con' },
];

Object.assign(window, { AMENITIES, SPORTS, sportLabel, HOURS, EMPTY_COURT, SEED_COURTS, COURT_FIELD_META });
