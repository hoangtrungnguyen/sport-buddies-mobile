import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/owner_court.dart';
import '../repository/owner_court_repository.dart';

const kSportTypes = [
  'Bóng đá 5v5',
  'Bóng đá 7v7',
  'Bóng đá 11v11',
  'Pickleball',
  'Tennis',
  'Cầu lông',
  'Bóng rổ',
  'Đa năng',
];

class CourtFormDialog extends StatefulWidget {
  const CourtFormDialog({
    super.key,
    required this.repository,
    this.court,
  });

  final OwnerCourtRepository repository;
  final OwnerCourt? court;

  @override
  State<CourtFormDialog> createState() => _CourtFormDialogState();
}

class _CourtFormDialogState extends State<CourtFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _priceCtrl;
  late Set<String> _selectedSports;
  late int _openHour;
  late int _closeHour;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.court != null;

  @override
  void initState() {
    super.initState();
    final c = widget.court;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _capacityCtrl =
        TextEditingController(text: c?.capacity.toString() ?? '4');
    _priceCtrl = TextEditingController(
        text: c?.pricePerHour != 0 ? c?.pricePerHour.toString() ?? '' : '');
    _selectedSports = Set<String>.from(c?.sportTypes ?? []);
    _openHour = c?.openHour ?? 6;
    _closeHour = c?.closeHour ?? 22;
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
    if (_selectedSports.isEmpty) {
      setState(() => _error = 'Vui lòng chọn ít nhất một môn thể thao.');
      return;
    }
    if (_closeHour <= _openHour) {
      setState(
          () => _error = 'Giờ đóng cửa phải sau giờ mở cửa.');
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await widget.repository.updateCourt(
          widget.court!.id,
          name: _nameCtrl.text.trim(),
          sportTypes: _selectedSports.toList(),
          capacity: int.parse(_capacityCtrl.text),
          openHour: _openHour,
          closeHour: _closeHour,
          pricePerHour: int.parse(_priceCtrl.text),
        );
      } else {
        await widget.repository.createCourt(
          name: _nameCtrl.text.trim(),
          sportTypes: _selectedSports.toList(),
          capacity: int.parse(_capacityCtrl.text),
          openHour: _openHour,
          closeHour: _closeHour,
          pricePerHour: int.parse(_priceCtrl.text),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Không thể lưu sân. Vui lòng thử lại.\n${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Text(
                      _isEdit ? 'Chỉnh sửa sân' : 'Thêm sân mới',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon:
                          const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.neutral500,
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Error banner
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 15, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: AppColors.dangerDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Tên sân
                _Label('Tên sân'),
                const SizedBox(height: 6),
                Semantics(
                  label: 'court-name-field',
                  textField: true,
                  child: TextFormField(
                  controller: _nameCtrl,
                  style:
                      GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: const InputDecoration(
                      hintText: 'Ví dụ: Sân 1, Pickleball A'),
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Vui lòng nhập tên sân.'
                      : null,
                  ),
                ),
                const SizedBox(height: 18),

                // Môn thể thao (multi-select chips)
                _Label('Môn thể thao'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kSportTypes.map((sport) {
                    final selected = _selectedSports.contains(sport);
                    return Semantics(
                      label: 'sport-chip-$sport',
                      button: true,
                      child: FilterChip(
                      label: Text(sport),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _selectedSports.add(sport);
                        } else {
                          _selectedSports.remove(sport);
                        }
                      }),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _Label('Sức chứa (người)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _capacityCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14),
                            decoration: const InputDecoration(
                                hintText: '4'),
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n < 1) {
                                return 'Tối thiểu 1';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _Label('Giá / giờ (đồng)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14),
                            decoration: const InputDecoration(
                                hintText: '350000'),
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n < 0) {
                                return 'Vui lòng nhập giá hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Giờ hoạt động
                _Label('Giờ hoạt động'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _HourDropdown(
                        label: 'Mở cửa',
                        value: _openHour,
                        onChanged: (v) =>
                            setState(() => _openHour = v),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      child: Text('–',
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              color: AppColors.neutral400)),
                    ),
                    Expanded(
                      child: _HourDropdown(
                        label: 'Đóng cửa',
                        value: _closeHour,
                        onChanged: (v) =>
                            setState(() => _closeHour = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () =>
                                Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neutral700,
                          side: const BorderSide(
                              color: AppColors.neutral200),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          textStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
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
                              borderRadius:
                                  BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          textStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
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
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral700,
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
  Widget build(BuildContext context) {
    return InputDecorator(
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
                  child:
                      Text('${h.toString().padLeft(2, '0')}:00'),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
