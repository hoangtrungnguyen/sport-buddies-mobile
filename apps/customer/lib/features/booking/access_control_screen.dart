import 'package:customer/features/booking/state/access_control_cubit.dart';
import 'package:customer/features/booking/state/access_control_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccessControlScreen extends StatefulWidget {
  const AccessControlScreen({super.key, required this.slotId});

  final String slotId;

  @override
  State<AccessControlScreen> createState() => _AccessControlScreenState();
}

class _AccessControlScreenState extends State<AccessControlScreen> {
  String _policy = 'closed';
  final _maxPlayersCtrl = TextEditingController(text: '4');
  String? _maxPlayersError;

  @override
  void dispose() {
    _maxPlayersCtrl.dispose();
    super.dispose();
  }

  void _setPolicy(String policy) => setState(() {
        _policy = policy;
        _maxPlayersError = null;
      });

  bool _validate() {
    if (_policy == 'open') {
      final mp = int.tryParse(_maxPlayersCtrl.text);
      if (mp == null || mp < 2 || mp > 20) {
        setState(() => _maxPlayersError = 'Nhập số từ 2 đến 20');
        return false;
      }
    }
    return true;
  }

  void _save() {
    if (!_validate()) return;
    context.read<AccessControlCubit>().save(
          widget.slotId,
          policy: _policy,
          maxPlayers: _policy == 'open'
              ? int.parse(_maxPlayersCtrl.text)
              : 4,
        );
  }

  void _skip() {
    context.read<AccessControlCubit>().save(
          widget.slotId,
          policy: 'closed',
          maxPlayers: 4,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccessControlCubit, AccessControlState>(
      listener: (context, state) {
        if (state is AccessControlSaved) {
          context.go('/booking/payment/${widget.slotId}');
        } else if (state is AccessControlFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is AccessControlSaving;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Chơi cùng ai?'),
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              const _StepperRow(step: 2),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Ai có thể tham gia?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chọn chế độ phù hợp với buổi chơi của bạn.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _PolicyToggle(
                        policy: _policy,
                        onChanged: isSaving ? null : _setPolicy,
                      ),
                      if (_policy == 'open') ...[
                        const SizedBox(height: 20),
                        _MaxPlayersField(
                          controller: _maxPlayersCtrl,
                          errorText: _maxPlayersError,
                          enabled: !isSaving,
                          onChanged: (_) =>
                              setState(() => _maxPlayersError = null),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: const Color(0xFF16A34A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Xác nhận',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: isSaving ? null : _skip,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PolicyToggle extends StatelessWidget {
  const _PolicyToggle({required this.policy, required this.onChanged});

  final String policy;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PolicyCard(
            label: 'Riêng tư',
            description: 'Chỉ người được mời',
            icon: Icons.lock_outline_rounded,
            selected: policy == 'closed',
            onTap: onChanged == null ? null : () => onChanged!('closed'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PolicyCard(
            label: 'Mở',
            description: 'Ai cũng có thể yêu cầu',
            icon: Icons.public_rounded,
            selected: policy == 'open',
            onTap: onChanged == null ? null : () => onChanged!('open'),
          ),
        ),
      ],
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF0FDF4)
              : const Color(0xFFF9FAFB),
          border: Border.all(
            color: selected
                ? const Color(0xFF16A34A)
                : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFF15803D)
                    : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaxPlayersField extends StatelessWidget {
  const _MaxPlayersField({
    required this.controller,
    required this.errorText,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số người tối đa',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Ví dụ: 4',
            errorText: errorText,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF16A34A)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final isActive = i == step;
          final isDone = i < step;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF16A34A)
                  : isDone
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }
}
