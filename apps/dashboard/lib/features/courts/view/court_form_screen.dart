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
import 'widgets/ai_assist_sheet.dart';
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

class _CourtFormScreenState extends State<CourtFormScreen> {
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

  /// Keys whose value was written by AI and not yet manually edited.
  final Set<String> _aiFilled = {};

  /// Keys currently showing the one-shot tertiaryContainer pulse.
  final Set<String> _pulse = {};

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
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _mapsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _clearMark(String key) {
    if (_aiFilled.remove(key)) setState(() {});
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
    if (r.openHour != null) {
      _openHour = r.openHour!;
      filled.add(_K.hours);
    }
    if (r.closeHour != null) {
      _closeHour = r.closeHour!;
      filled.add(_K.hours);
    }

    setState(() {
      _aiFilled.addAll(filled);
      _pulse
        ..clear()
        ..addAll(filled);
    });
    // Clear the pulse highlight after the one-shot flash.
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _pulse.clear());
    });

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
      setState(() {
        _descCtrl.text = desc;
        _aiFilled.add(_K.description);
        _pulse.add(_K.description);
      });
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _pulse.remove(_K.description));
      });
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
        context.go('/courts/${saved.id}');
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
                  _ErrorBanner(_error!),
                ],

                // 1) Thông tin cơ bản
                const SectionHeader(
                  icon: Symbols.badge,
                  title: 'Thông tin cơ bản',
                  subtitle: 'Tên hiển thị và liên hệ của sân',
                ),
                _TwoCol(
                  left: _AiField(
                    controller: _nameCtrl,
                    label: 'Tên sân *',
                    fieldKey: _K.name,
                    aiFilled: _aiFilled,
                    pulse: _pulse,
                    onManualEdit: _clearMark,
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? 'Bắt buộc — nhập tên sân'
                        : null,
                  ),
                  right: _AiField(
                    controller: _phoneCtrl,
                    label: 'Số điện thoại',
                    fieldKey: _K.phone,
                    leading: Symbols.call,
                    keyboardType: TextInputType.phone,
                    aiFilled: _aiFilled,
                    pulse: _pulse,
                    onManualEdit: _clearMark,
                  ),
                ),

                // 2) Vị trí
                const SectionHeader(
                  icon: Symbols.location_on,
                  title: 'Vị trí',
                  subtitle: 'Địa chỉ và toạ độ để khách tìm đường',
                ),
                _AiField(
                  controller: _addressCtrl,
                  label: 'Địa chỉ *',
                  fieldKey: _K.address,
                  aiFilled: _aiFilled,
                  pulse: _pulse,
                  onManualEdit: _clearMark,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Bắt buộc — nhập địa chỉ'
                      : null,
                ),
                const SizedBox(height: 16),
                _TwoCol(
                  left: _AiField(
                    controller: _latCtrl,
                    label: 'Vĩ độ (lat)',
                    fieldKey: _K.location,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    aiFilled: _aiFilled,
                    pulse: _pulse,
                    onManualEdit: _clearMark,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final n = double.tryParse(v.trim());
                      return (n == null || n < -90 || n > 90)
                          ? '-90 đến 90'
                          : null;
                    },
                  ),
                  right: _AiField(
                    controller: _lngCtrl,
                    label: 'Kinh độ (lng)',
                    fieldKey: _K.location,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    aiFilled: _aiFilled,
                    pulse: _pulse,
                    onManualEdit: _clearMark,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final n = double.tryParse(v.trim());
                      return (n == null || n < -180 || n > 180)
                          ? '-180 đến 180'
                          : null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _AiField(
                  controller: _mapsCtrl,
                  label: 'Google Maps URL',
                  fieldKey: _K.maps,
                  leading: Symbols.map,
                  keyboardType: TextInputType.url,
                  aiFilled: _aiFilled,
                  pulse: _pulse,
                  onManualEdit: _clearMark,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return null;
                    return t.startsWith('http')
                        ? null
                        : 'URL phải bắt đầu bằng http';
                  },
                ),

                // 3) Mô tả
                const SectionHeader(
                  icon: Symbols.description,
                  title: 'Mô tả',
                  subtitle: 'Giới thiệu ngắn hiển thị cho khách',
                ),
                _AiField(
                  controller: _descCtrl,
                  label: 'Mô tả',
                  fieldKey: _K.description,
                  maxLines: 3,
                  aiFilled: _aiFilled,
                  pulse: _pulse,
                  onManualEdit: _clearMark,
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

                // 4) Tiện ích
                const SectionHeader(
                  icon: Symbols.category,
                  title: 'Tiện ích',
                  subtitle: 'Chọn các tiện ích sân có',
                ),
                if (_aiFilled.contains(_K.amenities)) const _AiHint(),
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
                            _aiFilled.remove(_K.amenities);
                          }),
                        ),
                      ),
                  ],
                ),

                // 5) Giờ hoạt động
                const SectionHeader(
                  icon: Symbols.schedule,
                  title: 'Giờ hoạt động',
                  subtitle: 'Khung giờ nhận khách trong ngày',
                ),
                if (_aiFilled.contains(_K.hours)) const _AiHint(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Row(
                    children: [
                      Expanded(
                        child: _HourDropdown(
                          label: 'Mở cửa',
                          icon: Symbols.wb_twilight,
                          value: _openHour,
                          onChanged: (v) => setState(() {
                            _openHour = v;
                            _aiFilled.remove(_K.hours);
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _HourDropdown(
                          label: 'Đóng cửa',
                          icon: Symbols.bedtime,
                          value: _closeHour,
                          onChanged: (v) => setState(() {
                            _closeHour = v;
                            _aiFilled.remove(_K.hours);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isEdit) ...[
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
                  _ActiveToggle(
                    isActive: _isActive,
                    saving: _saving,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _StickyFooter(
        saving: _saving,
        isEdit: _isEdit,
        onCancel: _saving ? null : () => _leave(context),
        onSubmit: _saving ? null : _submit,
      ),
    );
  }

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

// ---------------------------------------------------------------------------
// Field with AI-fill marking + one-shot pulse
// ---------------------------------------------------------------------------

class _AiField extends StatelessWidget {
  const _AiField({
    required this.controller,
    required this.label,
    required this.fieldKey,
    required this.aiFilled,
    required this.pulse,
    required this.onManualEdit,
    this.leading,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String fieldKey;
  final Set<String> aiFilled;
  final Set<String> pulse;
  final ValueChanged<String> onManualEdit;
  final IconData? leading;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAi = aiFilled.contains(fieldKey);
    final isPulsing = pulse.contains(fieldKey);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isPulsing
            ? scheme.tertiaryContainer
            : scheme.tertiaryContainer.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (_) {
          if (aiFilled.contains(fieldKey)) onManualEdit(fieldKey);
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: leading != null ? Icon(leading, size: 20) : null,
          helperText: isAi ? '✦ Điền bởi AI — hãy kiểm tra lại' : null,
          helperStyle: TextStyle(color: scheme.tertiary),
          helperMaxLines: 2,
        ),
        validator: validator,
      ),
    );
  }
}

/// Tertiary "AI filled" note for non-field targets (amenities, hours).
class _AiHint extends StatelessWidget {
  const _AiHint();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Symbols.auto_awesome, size: 14, color: scheme.tertiary),
          const SizedBox(width: 6),
          Text(
            'AI đã điền — hãy kiểm tra lại',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.tertiary),
          ),
        ],
      ),
    );
  }
}

class _TwoCol extends StatelessWidget {
  const _TwoCol({required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 560) {
          return Column(
            children: [left, const SizedBox(height: 16), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _HourDropdown extends StatelessWidget {
  const _HourDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      items: List.generate(17, (i) => i + 6)
          .map((h) => DropdownMenuItem(value: h, child: Text(formatHour(h))))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _ActiveToggle extends StatelessWidget {
  const _ActiveToggle({
    required this.isActive,
    required this.saving,
    required this.onChanged,
  });
  final bool isActive;
  final bool saving;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trạng thái hoạt động',
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  isActive
                      ? 'Sân đang hoạt động — khách có thể đặt.'
                      : 'Sân đang tạm ngưng — khách không thể đặt.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'court-active-toggle',
            toggled: isActive,
            child: Switch(
              value: isActive,
              onChanged: saving ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.saving,
    required this.isEdit,
    required this.onCancel,
    required this.onSubmit,
  });
  final bool saving;
  final bool isEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      // heightFactor:1 makes this shrink-wrap the button row's height. Without
      // it, Center fills the bottomSheet's loose vertical constraints and the
      // footer balloons into a full-height white box over the form.
      child: Align(
        alignment: Alignment.center,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Row(
            children: [
              TextButton(onPressed: onCancel, child: const Text('Huỷ')),
              const Spacer(),
              Semantics(
                label: 'court-form-submit-btn',
                button: true,
                child: FilledButton.icon(
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Symbols.check, size: 18),
                  label: Text(isEdit ? 'Lưu thay đổi' : 'Tạo sân'),
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Symbols.error, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
