import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/CollectionMethodWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/DatePickerWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/LabInfoWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/PrescriptionUploadWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/SubmitButtonWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/TestSelectionWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/TimePickerWidget.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class BookLabTestAppointmentPage extends StatelessWidget {
  final LabModel lab;

  const BookLabTestAppointmentPage({Key? key, required this.lab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LabTestAppointmentViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: _buildBody(context, viewModel),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(context, viewModel),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: ColorPalette.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          "Book Lab Appointment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorPalette.primaryColor,
                ColorPalette.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                bottom: -50,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.science,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent, color: Colors.white),
          ),
          onPressed: () {
            // Show help dialog or support contact
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(BuildContext context, LabTestAppointmentViewModel viewModel) {
    return Form(
      key: viewModel.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader(
              context: context,
              title: "Lab Information",
              icon: Icons.biotech,
            ),
            _buildCard(context, LabInfoWidget(lab: lab)),
            
            const SizedBox(height: 20),
            _buildSectionHeader(
              context: context,
              title: "Select Tests",
              icon: Icons.science,
            ),
            _buildCard(context, TestSelectionWidget(lab: lab)),
            
            const SizedBox(height: 20),
            _buildSectionHeader(
              context: context,
              title: "Appointment Date",
              icon: Icons.calendar_today,
            ),
            _buildCard(context, DatePickerWidget()),
            
            const SizedBox(height: 20),
            _buildSectionHeader(
              context: context,
              title: "Appointment Time",
              icon: Icons.access_time,
            ),
            _buildCard(context, TimePickerWidget()),
            
            const SizedBox(height: 20),
            _buildSectionHeader(
              context: context,
              title: "Sample Collection Method",
              icon: Icons.home,
            ),
            _buildCard(context, CollectionMethodWidget()),
            
            const SizedBox(height: 20),
            _buildSectionHeader(
              context: context,
              title: "Prescription Upload",
              icon: Icons.file_upload,
            ),
            _buildCard(context, PrescriptionUploadWidget()),

            const SizedBox(height: 100), // Bottom padding for scroll
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ColorPalette.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorPalette.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, LabTestAppointmentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SubmitButtonWidget(viewModel: viewModel, lab: lab),
    );
  }
}

