import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';

class MedicalInfoSection extends StatelessWidget {
  const MedicalInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: viewModel.workingTimeController,
          decoration: const InputDecoration(
            labelText: 'Working Time',
            border: OutlineInputBorder(),
            hintText: 'e.g., 9:00 AM - 9:00 PM',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter working time';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: viewModel.workingDaysController,
          decoration: const InputDecoration(
            labelText: 'Working Days',
            border: OutlineInputBorder(),
            hintText: 'e.g., Monday to Saturday',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter working days';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: viewModel.feesRangeController,
          decoration: const InputDecoration(
            labelText: 'Fees Range',
            border: OutlineInputBorder(),
            hintText: 'e.g., ₹500 - ₹2000',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter fees range';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: TextEditingController(
            text: viewModel.bedsAvailable.toString(),
          ),
          decoration: const InputDecoration(
            labelText: 'Number of Beds Available',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            viewModel.updateBedsAvailable(int.tryParse(value) ?? 0);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter number of beds';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Speciality Types',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'Cardiology',
            'Neurology',
            'Orthopedics',
            'Pediatrics',
            'Gynecology',
            'Dermatology',
            'ENT',
            'Ophthalmology',
            'Dentistry',
            'General Medicine',
          ].map((speciality) {
            final isSelected = viewModel.specialityTypes.contains(speciality);
            return FilterChip(
              label: Text(speciality),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(viewModel.specialityTypes);
                if (selected) {
                  newList.add(speciality);
                } else {
                  newList.remove(speciality);
                }
                viewModel.updateSpecialityTypes(newList);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Services Offered',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'Emergency Care',
            'OPD',
            'IPD',
            'Diagnostic Services',
            'Pharmacy',
            'Ambulance Service',
            'ICU',
            'Operation Theater',
            'Laboratory',
            'Radiology',
          ].map((service) {
            final isSelected = viewModel.servicesOffered.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(viewModel.servicesOffered);
                if (selected) {
                  newList.add(service);
                } else {
                  newList.remove(service);
                }
                viewModel.updateServicesOffered(newList);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Other Facilities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'In-House Path Lab',
            'X-Ray',
            'MRI',
            'CT Scan',
            'Blood Bank',
            'Cafeteria',
            'Waiting Area',
            'Prayer Room',
            'ATM',
            'WiFi',
          ].map((facility) {
            final isSelected = viewModel.otherFacilities.contains(facility);
            return FilterChip(
              label: Text(facility),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(viewModel.otherFacilities);
                if (selected) {
                  newList.add(facility);
                } else {
                  newList.remove(facility);
                }
                viewModel.updateOtherFacilities(newList);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Insurance Companies',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'ICICI Lombard',
            'HDFC Ergo',
            'Bajaj Allianz',
            'Star Health',
            'New India Assurance',
            'United India Insurance',
            'Oriental Insurance',
            'National Insurance',
            'Reliance General',
            'Tata AIG',
          ].map((company) {
            final isSelected = viewModel.insuranceCompanies.contains(company);
            return FilterChip(
              label: Text(company),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(viewModel.insuranceCompanies);
                if (selected) {
                  newList.add(company);
                } else {
                  newList.remove(company);
                }
                viewModel.updateInsuranceCompanies(newList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
} 