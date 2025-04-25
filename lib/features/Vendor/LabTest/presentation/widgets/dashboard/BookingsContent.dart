import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/dashboard/BookingList.dart';

class BookingsContent extends StatefulWidget {
  const BookingsContent({Key? key}) : super(key: key);

  @override
  State<BookingsContent> createState() => _BookingsContentState();
}

class _BookingsContentState extends State<BookingsContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: LabTestColorPalette.backgroundPrimary,
          child: TabBar(
            controller: _tabController,
            labelColor: LabTestColorPalette.primaryBlue,
            unselectedLabelColor: LabTestColorPalette.textSecondary,
            indicatorColor: LabTestColorPalette.primaryBlue,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              BookingList(type: 'today'),
              BookingList(type: 'upcoming'),
              BookingList(type: 'past'),
            ],
          ),
        ),
      ],
    );
  }
} 