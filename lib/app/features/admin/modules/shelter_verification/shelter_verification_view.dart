import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../common/widgets/lottie_loading.dart';
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
          automaticallyImplyLeading: false,
          leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/back-icon.svg',
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            width: 24,
            height: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Manage Shelters',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
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
              return const Center(child: LottieLoading());
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
              return const Center(child: LottieLoading());
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
    final String accountStatus = request['accountStatus'] ?? 'active';
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
      color: Colors.white,
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
                                color: accountStatus == 'active'
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                accountStatus == 'active' ? 'Active' : 'Suspended',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: accountStatus == 'active' ? AppColors.primary : Colors.red,
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
                    if (value == 'suspend') {
                      _showSuspendDialog(uid, shelterName);
                    } else if (value == 'lift_suspension') {
                      controller.liftSuspension(uid, shelterName);
                    }
                  },
                  itemBuilder: (context) => [
                    if (accountStatus != 'suspended')
                      PopupMenuItem(
                        value: 'suspend',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, color: AppColors.neutral700),
                            const SizedBox(width: 8),
                            const Text('Suspend'),
                          ],
                        ),
                      ),
                    if (accountStatus == 'suspended')
                      PopupMenuItem(
                        value: 'lift_suspension',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text('Lift Suspension'),
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

  void _showSuspendDialog(String uid, String shelterName) {
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _SuspendShelterDialog(
          uid: uid,
          name: shelterName,
          controller: controller,
        );
      },
    );
  }
}

class _SuspendShelterDialog extends StatefulWidget {
  final String uid;
  final String name;
  final ShelterVerificationController controller;

  const _SuspendShelterDialog({
    required this.uid,
    required this.name,
    required this.controller,
  });

  @override
  State<_SuspendShelterDialog> createState() => _SuspendShelterDialogState();
}

class _SuspendShelterDialogState extends State<_SuspendShelterDialog> {
  late final TextEditingController _reasonController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _isDisposing = true;
    try {
      _reasonController.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposing) {
      return const SizedBox.shrink();
    }
    
    return AlertDialog(
      title: Text(
        'Suspend Shelter',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suspend shelter: "${widget.name}"',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Start Date
            Text(
              'Suspension Start:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null && mounted && !_isDisposing) {
                  setState(() {
                    _startDate = picked;
                    if (_endDate.isBefore(picked)) {
                      _endDate = picked.add(const Duration(days: 1));
                    }
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.neutral600),
                    const SizedBox(width: 8),
                    Text(
                      '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // End Date
            Text(
              'Suspension End:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate.add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null && mounted && !_isDisposing) {
                  setState(() {
                    _endDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.neutral600),
                    const SizedBox(width: 8),
                    Text(
                      '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Reason
            Text(
              'Reason for Suspension:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for suspension...',
                hintStyle: GoogleFonts.poppins(fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) {
              return;
            }
            Navigator.of(context).pop();
            widget.controller.suspendShelter(widget.uid, _startDate, _endDate, reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC1C1),
            foregroundColor: Colors.black,
          ),
          child: const Text('Suspend'),
        ),
      ],
    );
  }
}
