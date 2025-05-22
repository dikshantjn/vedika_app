import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/EditPersonalProfileScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PersonalProfileHeader extends StatelessWidget {
  final UserPersonalProfileViewModel viewModel;

  PersonalProfileHeader({required this.viewModel});

  double calculateProfileCompletion() {
    if (viewModel.personalProfile == null) return 0.0;

    List<bool> essentialFields = [
      viewModel.personalProfile!.name.isNotEmpty,
      viewModel.personalProfile!.phoneNumber.isNotEmpty,
      viewModel.personalProfile!.email.isNotEmpty,
      viewModel.personalProfile!.dateOfBirth != null,
      viewModel.personalProfile!.gender.isNotEmpty,
      viewModel.personalProfile!.bloodGroup.isNotEmpty,
      viewModel.personalProfile!.height != null,
      viewModel.personalProfile!.weight != null,
      viewModel.personalProfile!.emergencyContactNumber.isNotEmpty,
      viewModel.personalProfile!.location.isNotEmpty,
    ];

    int filledEssentialFields = essentialFields.where((isFilled) => isFilled).length;
    return filledEssentialFields / essentialFields.length;
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.personalProfile == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
        ),
      );
    }

    double profileCompletion = calculateProfileCompletion();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorPalette.primaryColor,
            ColorPalette.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture with completion indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: profileCompletion,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: viewModel.personalProfile?.photoUrl.isNotEmpty == true
                          ? CachedNetworkImage(
                              imageUrl: viewModel.personalProfile!.photoUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                                    ),
                              errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                size: 30,
                                  color: Colors.grey[400],
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(profileCompletion * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // User information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            viewModel.personalProfile!.name.isNotEmpty
                                ? viewModel.personalProfile!.name
                                : 'Name not available',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPersonalProfileScreen(viewModel: viewModel),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            viewModel.personalProfile!.phoneNumber.isNotEmpty
                                ? viewModel.personalProfile!.phoneNumber
                                : 'Phone Number not available',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (viewModel.personalProfile?.email.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.personalProfile!.email,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
