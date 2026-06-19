import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/model/owner_court.dart';
import '../../setup/repository/owner_court_repository.dart';
import '../service/court_info_parser_service.dart';
import '../util/court_format.dart';
import '../util/maps_url.dart';
import 'widgets/ai_assist_sheet.dart';
import 'widgets/court_form_ai_fill.dart';
import 'widgets/court_form_chrome.dart';
import 'widgets/court_form_fields.dart';
import 'widgets/court_widgets.dart';

/// Field keys used for AI-fill marking + pulse highlight.
class _K {
  static const name = 'name';
  static const phone = 'phone';
  static const address = 'address';
  static const location = 'location';
  static const maps = 'maps';
  static const description = 'description';
  static const amenities = 'amenities';
  static const hours = 'hours';
}

class CourtFormScreen extends StatefulWidget {
  const CourtFormScreen({super.key, this.court});

  /// Null = create mode; non-null = edit mode.
  final OwnerCourt? court;

  @override
  State<CourtFormScreen> createState() => _CourtFormScreenState();
}

class _CourtFormScreenState extends State<CourtFormScreen>
    with CourtFormAiFill<CourtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _mapsCtrl;
  late final TextEditingController _descCtrl;
  late Set<String> _selectedAmenities;
  late int _openHour;
  late int _closeHour;
  late bool _isActive;

  bool _saving = false;
  bool _descBusy = false;
  String? _error;

  final _parser = CourtInfoParserService();

  bool get _isEdit => widget.court != null;

  @override
  void initState() {
    super.initState();
    final c = widget.court;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl =
        TextEditingController(text: c?.additionalInfo['phone'] as String? ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _latCtrl = TextEditingController(
        text: c?.lat != null ? c!.lat!.toStringAsFixed(6) : '');
    _lngCtrl = TextEditingController(
        text: c?.lng != null ? c!.lng!.toStringAsFixed(6) : '');
    _mapsCtrl = TextEditingController(text: c?.googleMapsUrl ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _selectedAmenities = Set<String>.from(c?.amenities ?? []);
    _openHour = c?.openHour ?? 6;
    _closeHour = c?.closeHour ?? 22;
    _isActive = c?.isActive ?? true;
    // Lat/lng are read-only and derived from the Maps URL — keep them in sync.
    _mapsCtrl.addListener(_syncCoordsFromMapsUrl);
  }

  /// Parse the Maps URL and push its coordinates into the read-only lat/lng
  /// fields. No-op when the URL has no usable pair or they already match.
  void _syncCoordsFromMapsUrl() {
    final coords = extractLatLngFromMapsUrl(_mapsCtrl.text.trim());
    if (coords == null) return;
    final lat = coords.lat.toStringAsFixed(6);
    final lng = coords.lng.toStringAsFixed(6);
    if (_latCtrl.text == lat && _lngCtrl.text == lng) return;
    _latCtrl.text = lat;
    _lngCtrl.text = lng;
    flashFields({_K.location, _K.maps});
  }

  @override
  void dispose() {
    _mapsCtrl.removeListener(_syncCoordsFromMapsUrl);
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _mapsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _applyAi(CourtParseResult r) {
    final filled = <String>{};
    void set(TextEditingController c, String? v, String key) {
      if (v != null && v.trim().isNotEmpty) {
        c.text = v.trim();
        filled.add(key);
      }
    }

    set(_nameCtrl, r.name, _K.name);
    set(_phoneCtrl, r.phone, _K.phone);
    set(_addressCtrl, r.address, _K.address);
    set(_mapsCtrl, r.googleMapsUrl, _K.maps);
    set(_descCtrl, r.description, _K.description);
    if (r.lat != null) {
      _latCtrl.text = r.lat!.toStringAsFixed(6);
      filled.add(_K.location);
    }
    if (r.lng != null) {
      _lngCtrl.text = r.lng!.toStringAsFixed(6);
      filled.add(_K.location);
    }
    if (r.amenities.isNotEmpty) {
      _selectedAmenities = Set.from(r.amenities);
      filled.add(_K.amenities);
    }
    // Clamp to the dropdown's 0–24 range so a stray AI value can't break the
    // DropdownButtonFormField (a value outside its items asserts).
    if (r.openHour != null) {
      _openHour = r.openHour!.clamp(0, 24);
      filled.add(_K.hours);
    }
    if (r.closeHour != null) {
      _closeHour = r.closeHour!.clamp(0, 24);
      filled.add(_K.hours);
    }

    flashFields(filled, markFilled: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(filled.isEmpty
            ? 'Không có trường nào được điền.'
            : 'AI đã điền ${filled.length} trường — các trường được đánh dấu ✦'),
      ),
    );
  }

  void _openAiSheet() {
    showCourtAiSheet(
      context: context,
      service: _parser,
      onApply: _applyAi,
    );
  }

  Future<void> _writeDescription() async {
    setState(() => _descBusy = true);
    try {
      final desc = await _parser.writeDescription(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        openHour: _openHour,
        closeHour: _closeHour,
        amenities: _selectedAmenities.toList(),
        venueNames: const [],
      );
      if (!mounted) return;
      _descCtrl.text = desc;
      flashFields({_K.description}, markFilled: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không gọi được AI — thử lại nhé')),
      );
    } finally {
      if (mounted) setState(() => _descBusy = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Còn trường bắt buộc chưa điền')),
      );
      return;
    }
    if (_closeHour <= _openHour) {
      setState(() => _error = 'Giờ đóng cửa phải sau giờ mở cửa.');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = context.read<OwnerCourtRepository>();
      final address = _addressCtrl.text.trim();
      final desc = _descCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final lat = double.tryParse(_latCtrl.text.trim());
      final lng = double.tryParse(_lngCtrl.text.trim());
      final mapsUrl = _mapsCtrl.text.trim();

      Map<String, dynamic> additionalInfo() {
        final m = Map<String, dynamic>.from(
            _isEdit ? widget.court!.additionalInfo : const {});
        if (mapsUrl.isEmpty) {
          m.remove('google_maps_url');
        } else {
          m['google_maps_url'] = mapsUrl;
        }
        if (phone.isEmpty) {
          m.remove('phone');
        } else {
          m['phone'] = phone;
        }
        return m;
      }

      OwnerCourt saved;
      if (_isEdit) {
        saved = await repo.updateCourt(
          widget.court!.id,
          name: _nameCtrl.text.trim(),
          openHour: _openHour,
          closeHour: _closeHour,
          address: address.isEmpty ? null : address,
          description: desc.isEmpty ? null : desc,
          amenities: _selectedAmenities.toList(),
          lat: lat,
          lng: lng,
          additionalInfo: additionalInfo(),
        );
        if (_isActive != widget.court!.isActive) {
          if (_isActive) {
            await repo.reactivateCourt(widget.court!.id);
          } else {
            await repo.deactivateCourt(widget.court!.id);
          }
        }
      } else {
        saved = await repo.createCourt(
          name: _nameCtrl.text.trim(),
          openHour: _openHour,
          closeHour: _closeHour,
          address: address.isEmpty ? null : address,
          description: desc.isEmpty ? null : desc,
          amenities: _selectedAmenities.toList(),
          lat: lat,
          lng: lng,
          additionalInfo: additionalInfo(),
        );
      }

      if (!mounted) return;
      context.read<CourtBloc>().add(const CourtEvent.loadRequested());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu ${saved.name}')),
      );
      if (_isEdit) {
        _leave(context);
      } else {
        // After creating a court, return to the courts list (not the new
        // court's sub-court detail) so the owner sees it in the list.
        context.go('/courts');
      }
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Không thể lưu sân. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Full-screen page (rendered over the app shell via root navigator). Its own
    // app bar carries the back arrow + AI action; the sticky footer keeps the
    // Lưu/Tạo button pinned and always visible.
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: _saving ? null : () => _leave(context),
        ),
        title: Text(_isEdit ? 'Chỉnh sửa sân' : 'Thêm sân mới'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Semantics(
              label: 'court-form-ai-parse-btn',
              button: true,
              child: FilledButton.tonalIcon(
                icon: const Icon(Symbols.auto_awesome, size: 18),
                label: const Text('Nhập nhanh bằng AI'),
                onPressed: _saving ? null : _openAiSheet,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 140),
              children: [
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  ErrorBanner(_error!),
                ],
                ..._basicInfoSection(),
                ..._locationSection(),
                ..._descriptionSection(scheme),
                ..._amenitiesSection(),
                ..._hoursSection(),
                if (_isEdit) ..._subCourtsSection(context),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: StickyFooter(
        saving: _saving,
        isEdit: _isEdit,
        onCancel: _saving ? null : () => _leave(context),
        onSubmit: _saving ? null : _submit,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Form sections — each returns the header + fields for one card of the form.
  // They stay private State methods (not standalone widgets) because every
  // field is wired to this State's controllers + AI-mark helpers.
  // ---------------------------------------------------------------------------

  /// 1) Thông tin cơ bản — name + phone.
  List<Widget> _basicInfoSection() => [
        const SectionHeader(
          icon: Symbols.badge,
          title: 'Thông tin cơ bản',
          subtitle: 'Tên hiển thị và liên hệ của sân',
        ),
        TwoCol(
          left: AiField(
            controller: _nameCtrl,
            label: 'Tên sân *',
            fieldKey: _K.name,
            aiFilled: aiFilled,
            pulse: pulse,
            onManualEdit: clearAiMark,
            validator: (v) => (v?.trim().isEmpty ?? true)
                ? 'Bắt buộc — nhập tên sân'
                : null,
          ),
          right: AiField(
            controller: _phoneCtrl,
            label: 'Số điện thoại',
            fieldKey: _K.phone,
            leading: Symbols.call,
            keyboardType: TextInputType.phone,
            aiFilled: aiFilled,
            pulse: pulse,
            onManualEdit: clearAiMark,
          ),
        ),
      ];

  /// 2) Vị trí — address + Maps URL + (read-only) lat/lng.
  List<Widget> _locationSection() => [
        const SectionHeader(
          icon: Symbols.location_on,
          title: 'Vị trí',
          subtitle: 'Địa chỉ và toạ độ để khách tìm đường',
        ),
        AiField(
          controller: _addressCtrl,
          label: 'Địa chỉ *',
          fieldKey: _K.address,
          aiFilled: aiFilled,
          pulse: pulse,
          onManualEdit: clearAiMark,
          validator: (v) => (v?.trim().isEmpty ?? true)
              ? 'Bắt buộc — nhập địa chỉ'
              : null,
        ),
        const SizedBox(height: 16),
        AiField(
          controller: _mapsCtrl,
          label: 'Google Maps URL',
          fieldKey: _K.maps,
          leading: Symbols.map,
          keyboardType: TextInputType.url,
          aiFilled: aiFilled,
          pulse: pulse,
          onManualEdit: clearAiMark,
          helperText: 'Dán link Google Maps — toạ độ tự điền bên dưới',
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return null;
            return t.startsWith('http')
                ? null
                : 'URL phải bắt đầu bằng http';
          },
        ),
        const SizedBox(height: 16),
        TwoCol(
          left: AiField(
            controller: _latCtrl,
            label: 'Vĩ độ (lat)',
            fieldKey: _K.location,
            readOnly: true,
            leading: Symbols.my_location,
            aiFilled: aiFilled,
            pulse: pulse,
            onManualEdit: clearAiMark,
            helperText: 'Tự động từ link Maps',
          ),
          right: AiField(
            controller: _lngCtrl,
            label: 'Kinh độ (lng)',
            fieldKey: _K.location,
            readOnly: true,
            leading: Symbols.my_location,
            aiFilled: aiFilled,
            pulse: pulse,
            onManualEdit: clearAiMark,
            helperText: 'Tự động từ link Maps',
          ),
        ),
      ];

  /// 3) Mô tả — description field + AI write/rewrite chip.
  List<Widget> _descriptionSection(ColorScheme scheme) => [
        const SectionHeader(
          icon: Symbols.description,
          title: 'Mô tả',
          subtitle: 'Giới thiệu ngắn hiển thị cho khách',
        ),
        AiField(
          controller: _descCtrl,
          label: 'Mô tả',
          fieldKey: _K.description,
          maxLines: 3,
          aiFilled: aiFilled,
          pulse: pulse,
          onManualEdit: clearAiMark,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: ActionChip(
            avatar: _descBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Symbols.auto_awesome,
                    size: 18, color: scheme.tertiary),
            label: Text(_descBusy
                ? 'AI đang viết…'
                : (_descCtrl.text.trim().isEmpty
                    ? 'Viết mô tả bằng AI'
                    : 'Viết lại bằng AI')),
            onPressed: _descBusy ? null : _writeDescription,
          ),
        ),
      ];

  /// 4) Tiện ích — amenity filter chips.
  List<Widget> _amenitiesSection() => [
        const SectionHeader(
          icon: Symbols.category,
          title: 'Tiện ích',
          subtitle: 'Chọn các tiện ích sân có',
        ),
        if (aiFilled.contains(_K.amenities)) const AiHint(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in kAmenities)
              Semantics(
                label: 'amenity-chip-$a',
                button: true,
                child: FilterChip(
                  avatar: Icon(amenityIcon(a), size: 18),
                  label: Text(a),
                  selected: _selectedAmenities.contains(a),
                  onSelected: (sel) => setState(() {
                    if (sel) {
                      _selectedAmenities.add(a);
                    } else {
                      _selectedAmenities.remove(a);
                    }
                    aiFilled.remove(_K.amenities);
                  }),
                ),
              ),
          ],
        ),
      ];

  /// 5) Giờ hoạt động — open/close hour dropdowns.
  List<Widget> _hoursSection() => [
        const SectionHeader(
          icon: Symbols.schedule,
          title: 'Giờ hoạt động',
          subtitle: 'Khung giờ nhận khách trong ngày',
        ),
        if (aiFilled.contains(_K.hours)) const AiHint(),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Row(
            children: [
              Expanded(
                child: HourDropdown(
                  label: 'Mở cửa',
                  icon: Symbols.wb_twilight,
                  value: _openHour,
                  onChanged: (v) => setState(() {
                    _openHour = v;
                    aiFilled.remove(_K.hours);
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HourDropdown(
                  label: 'Đóng cửa',
                  icon: Symbols.bedtime,
                  value: _closeHour,
                  onChanged: (v) => setState(() {
                    _closeHour = v;
                    aiFilled.remove(_K.hours);
                  }),
                ),
              ),
            ],
          ),
        ),
      ];

  /// Sân con + active toggle — edit mode only (a created court has no id yet).
  List<Widget> _subCourtsSection(BuildContext context) => [
        const SectionHeader(
          icon: Symbols.grid_view,
          title: 'Sân con',
          subtitle: 'Quản lý các sân con bên trong cụm sân',
        ),
        OutlinedButton.icon(
          icon: const Icon(Symbols.grid_view, size: 18),
          label: const Text('Quản lý sân con'),
          onPressed: () => context.go('/courts/${widget.court!.id}'),
        ),
        const SizedBox(height: 20),
        ActiveToggle(
          isActive: _isActive,
          saving: _saving,
          onChanged: (v) => setState(() => _isActive = v),
        ),
      ];

  /// Leave the form: edit returns to its court's detail, create returns to the
  /// courts list. Uses go() so the shell location updates (it hides its top bar
  /// on these sub-screens, leaving only this screen's app bar).
  void _leave(BuildContext context) {
    if (_isEdit) {
      context.go('/courts/${widget.court!.id}');
    } else {
      context.go('/courts');
    }
  }
}
