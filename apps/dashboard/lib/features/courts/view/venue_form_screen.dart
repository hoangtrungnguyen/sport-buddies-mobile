import 'package:dashboard/core/debug/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/model/owner_court.dart';
import '../model/venue.dart';
import '../repository/venue_repository.dart';

class VenueFormScreen extends StatefulWidget {
  const VenueFormScreen({
    super.key,
    required this.courtId,
    this.venue,
  });

  final String courtId;

  /// Null = create mode; non-null = edit mode.
  final Venue? venue;

  @override
  State<VenueFormScreen> createState() => _VenueFormScreenState();
}

class _VenueFormScreenState extends State<VenueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _priceCtrl;
  late String? _selectedSport;
  late bool _isActive;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.venue != null;

  @override
  void initState() {
    super.initState();
    final v = widget.venue;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _capacityCtrl =
        TextEditingController(text: v?.capacity.toString() ?? '');
    _priceCtrl = TextEditingController(
        text: (v?.pricePerHour ?? 0) != 0
            ? v!.pricePerHour.toString()
            : '');
    _selectedSport =
        (v?.sportType.isNotEmpty ?? false) ? v!.sportType : null;
    _isActive = v?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSport == null) {
      setState(() => _error = 'Vui lòng chọn môn thể thao.');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = context.read<VenueRepository>();

      if (_isEdit) {
        await repo.update(
          widget.venue!.id,
          name: _nameCtrl.text.trim(),
          sportType: _selectedSport!,
          capacity: int.parse(_capacityCtrl.text),
          pricePerHour: int.parse(_priceCtrl.text),
        );
        if (_isActive != widget.venue!.isActive) {
          if (_isActive) {
            await repo.reactivate(widget.venue!.id);
          } else {
            await repo.deactivate(widget.venue!.id);
          }
        }
      } else {
        await repo.create(
          courtId: widget.courtId,
          name: _nameCtrl.text.trim(),
          sportType: _selectedSport!,
          capacity: int.parse(_capacityCtrl.text),
          pricePerHour: int.parse(_priceCtrl.text),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu khu sân'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      context.pop(true);
    } catch (e, st) {
      appLogger.e('VenueForm save failed', error: e, stackTrace: st);
      setState(() {
        _saving = false;
        _error = 'Không thể lưu khu sân. Vui lòng thử lại.';
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
          _isEdit ? 'Chỉnh sửa khu sân' : 'Thêm khu sân',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.neutral200),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    _ErrorBanner(_error!),
                    const SizedBox(height: 16),
                  ],

                  // Tên khu sân
                  _Label('Tên khu sân'),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'venue-name-field',
                    textField: true,
                    child: TextFormField(
                      controller: _nameCtrl,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: const InputDecoration(
                          hintText: 'Ví dụ: Sân 1, Khu cầu lông A'),
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Vui lòng nhập tên khu sân.'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Môn thể thao (single-select)
                  _Label('Môn thể thao'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kSportTypes.map((sport) {
                      final selected = _selectedSport == sport;
                      return Semantics(
                        label: 'venue-sport-chip-$sport',
                        button: true,
                        child: FilterChip(
                          label: Text(sport),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedSport = sport),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.neutral700,
                          ),
                          selectedColor: AppColors.primaryLight,
                          backgroundColor: AppColors.neutral100,
                          checkmarkColor: AppColors.primary,
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.neutral200,
                          ),
                          showCheckmark: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Sức chứa + Giá
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Sức chứa (người)'),
                            const SizedBox(height: 6),
                            Semantics(
                              label: 'venue-capacity-field',
                              textField: true,
                              child: TextFormField(
                                controller: _capacityCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14),
                                decoration:
                                    const InputDecoration(hintText: '2'),
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  return (n == null || n < 1)
                                      ? 'Tối thiểu 1'
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
                            _Label('Giá / giờ (đồng)'),
                            const SizedBox(height: 6),
                            Semantics(
                              label: 'venue-price-field',
                              textField: true,
                              child: TextFormField(
                                controller: _priceCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14),
                                decoration: const InputDecoration(
                                    hintText: '150000'),
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  return (n == null || n < 0)
                                      ? 'Vui lòng nhập giá hợp lệ'
                                      : null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Active toggle (edit only)
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
                          onPressed:
                              _saving ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.neutral700,
                            side: const BorderSide(
                                color: AppColors.neutral200),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
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
                          label: 'venue-form-submit-btn',
                          button: true,
                          child: FilledButton(
                            onPressed: _saving ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
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
                                : Text(_isEdit
                                    ? 'Lưu thay đổi'
                                    : 'Thêm khu sân'),
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
                    'Trạng thái',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral700,
                    ),
                  ),
                  Text(
                    isActive
                        ? 'Khu sân đang hoạt động.'
                        : 'Khu sân đang tạm ngưng.',
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
              label: 'venue-active-toggle',
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
