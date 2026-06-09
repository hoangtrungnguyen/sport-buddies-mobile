import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/model/owner_court.dart';
import '../../setup/repository/owner_court_repository.dart';
import '../service/court_info_parser_service.dart';

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
  String? _error;
  final _parserService = CourtInfoParserService();

  bool get _isEdit => widget.court != null;

  @override
  void initState() {
    super.initState();
    final c = widget.court;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
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
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _mapsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _applyParseResult(CourtParseResult r) {
    setState(() {
      if (r.name != null) _nameCtrl.text = r.name!;
      if (r.address != null) _addressCtrl.text = r.address!;
      if (r.lat != null) _latCtrl.text = r.lat!.toStringAsFixed(6);
      if (r.lng != null) _lngCtrl.text = r.lng!.toStringAsFixed(6);
      if (r.googleMapsUrl != null) _mapsCtrl.text = r.googleMapsUrl!;
      if (r.description != null) _descCtrl.text = r.description!;
      if (r.amenities.isNotEmpty) _selectedAmenities = Set.from(r.amenities);
      if (r.openHour != null) _openHour = r.openHour!;
      if (r.closeHour != null) _closeHour = r.closeHour!;
    });
  }

  void _openParseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ParseSheet(
        parserService: _parserService,
        onResult: (r) {
          _applyParseResult(r);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã điền thông tin từ văn bản'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_closeHour <= _openHour) {
      setState(() => _error = 'Giờ đóng cửa phải sau giờ mở cửa.');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = context.read<OwnerCourtRepository>();
      final address = _addressCtrl.text.trim();
      final desc = _descCtrl.text.trim();
      final lat = double.tryParse(_latCtrl.text.trim());
      final lng = double.tryParse(_lngCtrl.text.trim());
      final mapsUrl = _mapsCtrl.text.trim();

      OwnerCourt saved;
      if (_isEdit) {
        final additionalInfo = Map<String, dynamic>.from(
          widget.court!.additionalInfo,
        );
        if (mapsUrl.isEmpty) {
          additionalInfo.remove('google_maps_url');
        } else {
          additionalInfo['google_maps_url'] = mapsUrl;
        }
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
          additionalInfo: additionalInfo,
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
          additionalInfo: mapsUrl.isEmpty ? {} : {'google_maps_url': mapsUrl},
        );
      }

      if (!mounted) return;
      context.read<CourtBloc>().add(const CourtEvent.loadRequested());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu sân'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      if (_isEdit) {
        context.pop();
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
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              size: 20, color: AppColors.neutral700),
          onPressed: _saving ? null : () => context.pop(),
        ),
        title: Text(
          _isEdit ? 'Chỉnh sửa sân' : 'Thêm sân mới',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        actions: [
          Semantics(
            label: 'court-form-ai-parse-btn',
            button: true,
            child: Tooltip(
              message: 'Nhập từ văn bản (AI)',
              child: IconButton(
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                color: AppColors.primary,
                onPressed: _saving ? null : _openParseSheet,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.neutral200),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error banner
                  if (_error != null) ...[
                    _ErrorBanner(_error!),
                    const SizedBox(height: 16),
                  ],

                  _Label('Tên sân'),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'court-name-field',
                    textField: true,
                    child: TextFormField(
                      controller: _nameCtrl,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: const InputDecoration(
                          hintText: 'Ví dụ: Sân 1, Pickleball A'),
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Vui lòng nhập tên sân.'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),

                  _Label('Địa chỉ'),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'court-address-field',
                    textField: true,
                    child: TextFormField(
                      controller: _addressCtrl,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: const InputDecoration(
                          hintText: 'Ví dụ: 123 Nguyễn Văn Linh, Q7, TP.HCM'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Vĩ độ (lat)'),
                            const SizedBox(height: 6),
                            Semantics(
                              label: 'court-lat-field',
                              textField: true,
                              child: TextFormField(
                                controller: _latCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true, signed: true),
                                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                                decoration: const InputDecoration(
                                    hintText: '10.762622'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return null;
                                  }
                                  final n = double.tryParse(v.trim());
                                  return (n == null || n < -90 || n > 90)
                                      ? '-90 đến 90'
                                      : null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Kinh độ (lng)'),
                            const SizedBox(height: 6),
                            Semantics(
                              label: 'court-lng-field',
                              textField: true,
                              child: TextFormField(
                                controller: _lngCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true, signed: true),
                                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                                decoration: const InputDecoration(
                                    hintText: '106.660172'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return null;
                                  }
                                  final n = double.tryParse(v.trim());
                                  return (n == null || n < -180 || n > 180)
                                      ? '-180 đến 180'
                                      : null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _Label('Google Maps URL'),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'court-maps-url-field',
                    textField: true,
                    child: TextFormField(
                      controller: _mapsCtrl,
                      keyboardType: TextInputType.url,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'https://maps.google.com/?q=...',
                        prefixIcon: Icon(Icons.map_outlined, size: 18),
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return null;
                        if (!t.startsWith('http')) {
                          return 'URL phải bắt đầu bằng http';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  _Label('Mô tả'),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'court-description-field',
                    textField: true,
                    child: TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: const InputDecoration(
                          hintText:
                              'Mô tả ngắn về sân, tiện ích, lưu ý cho khách...'),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _Label('Tiện ích'),
                  const SizedBox(height: 8),
                  _ChipSelector(
                    options: kAmenities,
                    selected: _selectedAmenities,
                    semanticsPrefix: 'amenity-chip',
                    onChanged: (v) =>
                        setState(() => _selectedAmenities = v),
                  ),
                  const SizedBox(height: 18),

                  _Label('Giờ hoạt động'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _HourDropdown(
                          label: 'Mở cửa',
                          value: _openHour,
                          onChanged: (v) => setState(() => _openHour = v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('–',
                            style: GoogleFonts.sora(
                                fontSize: 16,
                                color: AppColors.neutral400)),
                      ),
                      Expanded(
                        child: _HourDropdown(
                          label: 'Đóng cửa',
                          value: _closeHour,
                          onChanged: (v) => setState(() => _closeHour = v),
                        ),
                      ),
                    ],
                  ),

                  if (_isEdit) ...[
                    const SizedBox(height: 18),
                    _ActiveToggle(
                      isActive: _isActive,
                      saving: _saving,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.neutral700,
                            side: const BorderSide(
                                color: AppColors.neutral200),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            textStyle: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          child: const Text('Huỷ'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Semantics(
                          label: 'court-form-submit-btn',
                          button: true,
                          child: FilledButton(
                            onPressed: _saving ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              textStyle: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : Text(
                                    _isEdit ? 'Lưu thay đổi' : 'Tạo sân'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _Label extends StatelessWidget {
  const _Label(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 15, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5, color: AppColors.dangerDark)),
            ),
          ],
        ),
      );
}

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.semanticsPrefix,
    required this.onChanged,
  });
  final List<String> options;
  final Set<String> selected;
  final String semanticsPrefix;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final sel = selected.contains(opt);
          return Semantics(
            label: '$semanticsPrefix-$opt',
            button: true,
            child: FilterChip(
              label: Text(opt),
              selected: sel,
              onSelected: (v) {
                final next = Set<String>.from(selected);
                if (v) {
                  next.add(opt);
                } else {
                  next.remove(opt);
                }
                onChanged(next);
              },
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel
                    ? AppColors.primaryDark
                    : AppColors.neutral700,
              ),
              selectedColor: AppColors.primaryLight,
              backgroundColor: AppColors.neutral100,
              checkmarkColor: AppColors.primary,
              side: BorderSide(
                  color:
                      sel ? AppColors.primary : AppColors.neutral200),
              showCheckmark: true,
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 2),
            ),
          );
        }).toList(),
      );
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.neutral50 : AppColors.dangerBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.neutral200
                : AppColors.danger.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trạng thái hoạt động',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral700,
                    ),
                  ),
                  Text(
                    isActive
                        ? 'Sân đang hoạt động — khách có thể đặt.'
                        : 'Sân đang tạm ngưng — khách không thể đặt.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isActive
                          ? AppColors.neutral500
                          : AppColors.danger,
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
                activeTrackColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
}

class _ParseSheet extends StatefulWidget {
  const _ParseSheet({required this.parserService, required this.onResult});

  final CourtInfoParserService parserService;
  final ValueChanged<CourtParseResult> onResult;

  @override
  State<_ParseSheet> createState() => _ParseSheetState();
}

class _ParseSheetState extends State<_ParseSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.parserService.parse(text);
      if (!mounted) return;
      widget.onResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Không thể phân tích văn bản. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Nhập từ văn bản',
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dán thông tin sân (tên, địa chỉ, giờ mở cửa, tiện ích…) — AI sẽ tự điền vào form.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null) ...[
            _ErrorBanner(_error!),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _ctrl,
            maxLines: 6,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
            decoration: InputDecoration(
              hintText:
                  'Ví dụ: Sân Pickleball ABC, 123 Nguyễn Trãi Q1, mở 6h-22h, có WiFi và bãi đậu xe...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.neutral400,
              ),
              filled: true,
              fillColor: AppColors.neutral50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.neutral200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.neutral200),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 16),
              label: Text(_loading ? 'Đang phân tích…' : 'Phân tích'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourDropdown extends StatelessWidget {
  const _HourDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: AppColors.neutral900),
          items: List.generate(17, (i) => i + 6)
              .map((h) => DropdownMenuItem(
                    value: h,
                    child: Text('${h.toString().padLeft(2, '0')}:00'),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      );
}
