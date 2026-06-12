import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/features/slots/cubit/participant_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParticipantManagementCubit
    extends Cubit<ParticipantManagementState> {
  ParticipantManagementCubit({
    required BookingApiClient api,
  })  : _api = api,
        super(ParticipantManagementLoading());

  final BookingApiClient _api;

  Future<void> loadParticipants(String slotId) async {
    try {
      final data = await _api.getSlotParticipants(slotId);

      final confirmed = _parseParticipants(
        data['confirmed'] as List<dynamic>? ?? [],
      );
      final pending = _parsePendingRequests(
        data['pending'] as List<dynamic>? ?? [],
      );
      final maxPlayers = data['max_players'] as int? ?? 4;

      // Get slot info from data
      final slotData = data['slot'] as Map<String, dynamic>? ?? {};
      final slot = SlotSummary(
        courtName: slotData['court_name'] as String? ?? 'Unknown',
        sportType: slotData['sport_type'] as String? ?? 'Unknown',
        startTime: slotData['start_at'] != null
            ? DateTime.parse(slotData['start_at'] as String)
            : DateTime.now(),
        endTime: slotData['end_at'] != null
            ? DateTime.parse(slotData['end_at'] as String)
            : DateTime.now().add(const Duration(hours: 1)),
      );

      emit(ParticipantManagementLoaded(
        confirmed: confirmed,
        pending: pending,
        maxPlayers: maxPlayers,
        slot: slot,
      ));
    } on BookingApiException catch (e) {
      appLogger.e('Failed to load participants: $e');
      emit(ParticipantManagementError(
        e.detail ?? 'Không thể tải danh sách người chơi',
      ));
    } catch (e) {
      appLogger.e('Unexpected error loading participants: $e');
      emit(ParticipantManagementError('Có lỗi xảy ra'));
    }
  }

  List<SlotParticipant> _parseParticipants(List<dynamic> raw) {
    return [
      for (final p in raw)
        if (p is Map<String, dynamic>)
          SlotParticipant(
            id: p['id'] as String? ?? '',
            name: p['name'] as String? ?? 'Unknown',
            avatarColor: _colorFromString(p['avatar_color'] as String?),
            initials: (p['name'] as String? ?? '?').split(' ').map((s) => s[0]).join().toUpperCase(),
            subtitle: p['subtitle'] as String?,
            isHost: p['is_host'] as bool? ?? false,
          ),
    ];
  }

  List<JoinRequest> _parsePendingRequests(List<dynamic> raw) {
    return [
      for (final r in raw)
        if (r is Map<String, dynamic>)
          JoinRequest(
            id: r['id'] as String? ?? '',
            name: r['name'] as String? ?? 'Unknown',
            avatarColor: _colorFromString(r['avatar_color'] as String?),
            initials: (r['name'] as String? ?? '?').split(' ').map((s) => s[0]).join().toUpperCase(),
            rating: (r['rating'] as num?)?.toDouble() ?? 0.0,
            gamesPlayed: r['games_played'] as int? ?? 0,
            timeAgo: r['time_ago'] as String? ?? 'Recently',
            note: r['note'] as String?,
          ),
    ];
  }

  Color _colorFromString(String? hex) {
    if (hex == null) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }

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

  Future<void> approve(JoinRequest request) async {
    final s = state;
    if (s is! ParticipantManagementLoaded) return;

    try {
      await _api.approveJoinRequest(request.id);

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
    } on BookingApiException catch (e) {
      appLogger.e('Failed to approve: $e');
      emit(s.copyWith(
        toastMessage: 'Lỗi: ${e.detail ?? 'Không thể chấp nhận'}',
        toastDanger: true,
      ));
    }
  }

  Future<void> reject(JoinRequest request) async {
    final s = state;
    if (s is! ParticipantManagementLoaded) return;

    try {
      await _api.rejectJoinRequest(request.id);

      emit(s.copyWith(
        pending: s.pending.where((r) => r.id != request.id).toList(),
        toastMessage: 'Đã từ chối ${request.name}',
        toastDanger: true,
      ));
    } on BookingApiException catch (e) {
      appLogger.e('Failed to reject: $e');
      emit(s.copyWith(
        toastMessage: 'Lỗi: ${e.detail ?? 'Không thể từ chối'}',
        toastDanger: true,
      ));
    }
  }

  // TODO: Wire to DELETE /api/slots/{slotId}/participants/{participantId}
  // once backend endpoint is available
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
