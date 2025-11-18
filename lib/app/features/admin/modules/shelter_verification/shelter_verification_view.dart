import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import 'shelter_verification_controller.dart';

class ShelterVerificationView extends GetView<ShelterVerificationController> {
  const ShelterVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Shelter Verification',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide.none,
                ),
              ),
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: const Color.fromARGB(221, 73, 73, 73),
                indicatorColor: AppColors.primary,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'All Shelters'),
                ],
                onTap: (index) {
                  if (index == 0) {
                    controller.fetchVerificationRequests();
                  } else {
                    controller.fetchAllShelters();
                  }
                },
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [_buildPendingList(), _buildAllSheltersList()],
        ),
      ),
    );
  }

  Widget _buildPendingList() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RectangleSearchBar(
            hintText: 'Search by name, email, or phone...',
            onChanged: (value) => controller.searchQuery.value = value,
          ),
        ),
        // List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.verificationRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pending requests',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final displayRequests = controller.filteredRequests;

            if (displayRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shelters found',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchVerificationRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayRequests.length,
                itemBuilder: (context, index) {
                  final request = displayRequests[index];
                  return _buildRequestCard(request, showActions: true);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAllSheltersList() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RectangleSearchBar(
            hintText: 'Search by name, email, or phone...',
            onChanged: (value) => controller.searchQuery.value = value,
          ),
        ),
        // List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.allShelters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined, size: 64, color: AppColors.neutral400),
                    const SizedBox(height: 16),
                    Text(
                      'No registered shelters yet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final displayShelters = controller.filteredAllShelters;

            if (displayShelters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shelters found',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchAllShelters,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayShelters.length,
                itemBuilder: (context, index) {
                  final shelter = displayShelters[index];
                  return _buildRequestCard(shelter, showActions: false);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request, {
    required bool showActions,
  }) {
    final String uid = request['uid'] ?? '';
    final String shelterName = request['shelterName'] ?? 'No Name';
    final String email = request['shelterEmail'] ?? request['email'] ?? 'No Email';
    final String phone = request['shelterPhone'] ?? request['phone'] ?? '-';
    final String address = request['address'] ?? '-';
    final String description = request['description'] ?? '-';
    final String legalNumber = request['legalNumber'] ?? '-';
    final String verificationStatus =
        request['verificationStatus'] ?? 'pending';
  final bool isActive = request['isActive'] ?? true;
    final String? profilePicture = request['profilePicture'];
    
    // Format submitted date if available
    String submittedDate = '-';
    if (request['submittedAt'] != null) {
      try {
        final timestamp = request['submittedAt'] as Timestamp;
        final date = timestamp.toDate();
        submittedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        // Ignore error
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.green700.withOpacity(0.1),
                  backgroundImage: profilePicture != null && profilePicture.isNotEmpty
                      ? NetworkImage(profilePicture)
                      : null,
                  child: profilePicture == null || profilePicture.isEmpty
                      ? Icon(Icons.store, color: AppColors.green700)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              shelterName,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Show verification badge if pending/approved/rejected
                          // otherwise show active status for shelters when available
                          verificationStatus == 'pending'
                              ? _buildStatusBadge(verificationStatus)
                              : Container(),
                          if (verificationStatus != 'pending') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isActive ? 'Aktif' : 'Nonaktif',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: isActive ? AppColors.primary : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: AppColors.neutral500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.neutral500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: AppColors.neutral500),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Menu for Toggle / Delete like user management
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.neutral600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  elevation: 0,
                  color: AppColors.neutral100,
                  onSelected: (value) {
                    if (value == 'toggle_status') {
                      controller.toggleShelterStatus(uid, isActive);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(uid, shelterName);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.block : Icons.check_circle,
                            color: AppColors.neutral700,
                          ),
                          const SizedBox(width: 8),
                          Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, address),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.assignment, 'Legal No: $legalNumber'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.description, description, maxLines: 2),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Submitted: $submittedDate'),
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          controller.approveVerification(uid, shelterName),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(uid, shelterName),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'approved':
        color = AppColors.green700;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, {int? maxLines}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.neutral500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.neutral700,
            ),
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(String uid, String shelterName) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Reject Verification',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter rejection reason for "$shelterName":',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Rejection reason cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              controller.rejectVerification(
                uid,
                shelterName,
                reasonController.text.trim(),
              );
              reasonController.dispose();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String uid, String shelterName) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Confirmation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete shelter "$shelterName"?\nThis action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.deleteShelter(uid);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
