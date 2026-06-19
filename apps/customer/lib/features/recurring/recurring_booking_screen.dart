import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:customer/features/recurring/widgets/recurring_common.dart';
import 'package:customer/features/recurring/widgets/recurring_time_slots.dart';
import 'package:customer/features/recurring/widgets/recurring_schedule_controls.dart';
import 'package:customer/features/recurring/widgets/recurring_summary.dart';

class RecurringBookingScreen extends StatelessWidget {
  const RecurringBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đặt sân định kỳ'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: const Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 110),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  CourtChip(),
                  SectionLabel(
                    n: '1',
                    title: 'Khung giờ',
                    sub: 'Áp dụng cho mỗi buổi chơi',
                  ),
                  TimeSlotGrid(),
                  SectionLabel(n: '2', title: 'Lặp lại'),
                  RepeatChips(),
                  SizedBox(height: 12),
                  DowSelector(),
                  SizedBox(height: 8),
                  Text(
                    'Mỗi thứ ba và thứ năm hàng tuần',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  SectionLabel(n: '3', title: 'Bắt đầu từ'),
                  StartDateRow(),
                  SectionLabel(n: '4', title: 'Kết thúc'),
                  EndChips(),
                  SizedBox(height: 12),
                  SessionCountRow(),
                  SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '8 buổi · kết thúc ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        TextSpan(
                          text: 'thứ năm, 11/06/2026',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SummaryPreviewCard(),
                ],
              ),
            ),
          ),
          BottomCta(),
        ],
      ),
    );
  }
}
