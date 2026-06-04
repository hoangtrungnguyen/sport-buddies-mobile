import 'package:customer/features/slots/cubit/participant_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParticipantManagementCubit
    extends Cubit<ParticipantManagementState> {
  ParticipantManagementCubit() : super(ParticipantManagementLoading());

  void loadSeedData(String slotId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 19, 0);
    final end = DateTime(now.year, now.month, now.day, 20, 30);

    final slot = SlotSummary(
      courtName: 'Pickle Hub Q1 · Sân B',
      sportType: 'Pickleball',
      startTime: start,
      endTime: end,
    );

    final confirmed = [
      const SlotParticipant(
        id: 'p1',
        name: 'Trần Minh',
        avatarColor: Color(0xFF15803D),
        initials: 'TM',
        subtitle: 'Chủ slot · ⭐ 4.8',
        isHost: true,
      ),
      const SlotParticipant(
        id: 'p2',
        name: 'Nguyễn Hoàng',
        avatarColor: Color(0xFF0369A1),
        initials: 'NH',
        subtitle: '⭐ 4.7 · 24 trận',
      ),
    ];

    final pending = [
      const JoinRequest(
        id: 'r1',
        name: 'Phạm Thuỷ',
        avatarColor: Color(0xFFD97706),
        initials: 'PT',
        rating: 4.9,
        gamesPlayed: 31,
        timeAgo: '5 phút trước',
      ),
      const JoinRequest(
        id: 'r2',
        name: 'Lê Anh Tuấn',
        avatarColor: Color(0xFF7C3AED),
        initials: 'LT',
        rating: 4.7,
        gamesPlayed: 12,
        timeAgo: '12 phút trước',
        note: 'Mình chơi level trung bình, ổn không bạn?',
      ),
      const JoinRequest(
        id: 'r3',
        name: 'Đỗ Khánh',
        avatarColor: Color(0xFFDB2777),
        initials: 'ĐK',
        rating: 4.6,
        gamesPlayed: 7,
        timeAgo: '20 phút trước',
      ),
    ];

    emit(ParticipantManagementLoaded(
      confirmed: confirmed,
      pending: pending,
      maxPlayers: 4,
      slot: slot,
    ));
  }

  void approve(JoinRequest request) {
    final s = state;
    if (s is! ParticipantManagementLoaded) return;

    final newParticipant = SlotParticipant(
      id: request.id,
      name: request.name,
      avatarColor: request.avatarColor,
      initials: request.initials,
      subtitle: '⭐ ${request.rating} · ${request.gamesPlayed} trận',
    );

    emit(s.copyWith(
      confirmed: [...s.confirmed, newParticipant],
      pending: s.pending.where((r) => r.id != request.id).toList(),
      toastMessage: 'Đã chấp nhận ${request.name}',
      toastDanger: false,
    ));
  }

  void reject(JoinRequest request) {
    final s = state;
    if (s is! ParticipantManagementLoaded) return;

    emit(s.copyWith(
      pending: s.pending.where((r) => r.id != request.id).toList(),
      toastMessage: 'Đã từ chối ${request.name}',
      toastDanger: true,
    ));
  }

  void remove(String participantId) {
    final s = state;
    if (s is! ParticipantManagementLoaded) return;

    final removed = s.confirmed.firstWhere(
      (p) => p.id == participantId,
      orElse: () => const SlotParticipant(
        id: '',
        name: 'Người chơi',
        avatarColor: Colors.grey,
        initials: '?',
      ),
    );

    emit(s.copyWith(
      confirmed: s.confirmed.where((p) => p.id != participantId).toList(),
      toastMessage: 'Đã gỡ ${removed.name}',
      toastDanger: true,
    ));
  }

  void clearToast() {
    final s = state;
    if (s is! ParticipantManagementLoaded) return;
    emit(s.copyWith(toastMessage: null, toastDanger: false));
  }
}
