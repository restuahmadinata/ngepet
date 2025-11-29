import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../common/widgets/lottie_loading.dart';
import 'adoption_management_controller.dart';

class ShelterAdoptionManagementView extends GetView<ShelterAdoptionManagementController> {
  const ShelterAdoptionManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
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
          'Adoption Requests',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: LottieLoading(),
          );
        }

        if (controller.adoptionRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No adoption requests yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadAdoptionRequests,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.adoptionRequests.length,
            itemBuilder: (context, index) {
              final request = controller.adoptionRequests[index];
              return _buildRequestCard(request);
            },
          ),
        );
      }),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final petData = request['petData'] as Map<String, dynamic>?;
    final userData = request['userData'] as Map<String, dynamic>?;

    final petName = petData?['petName'] ?? 'Unknown Pet';
    final userName = userData?['fullName'] ?? 'Unknown User';

    // Get image URL
    String imageUrl = 'https://via.placeholder.com/100x100?text=Pet';
    if (petData?['imageUrls'] != null &&
        petData!['imageUrls'] is List &&
        (petData['imageUrls'] as List).isNotEmpty) {
      imageUrl = petData['imageUrls'][0].toString();
    }

    // Get application date
    String applicationDate = 'N/A';
    if (request['applicationDate'] != null) {
      final date = (request['applicationDate'] as Timestamp).toDate();
      applicationDate = DateFormat('dd MMM yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showManageDialog(request),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Pet image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Center(child: LottieLoading(width: 40, height: 40)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.pets, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Request info
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              petName,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.person, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  applicationDate,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Status indicator
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Timeline
                _buildTimeline(request),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Map<String, dynamic> request) {
    final requestStatus = request['requestStatus'] ?? 'pending';
    final surveyStatus = request['surveyStatus'] ?? 'not_started';
    final handoverStatus = request['handoverStatus'] ?? 'not_started';

    return Row(
      children: [
        // Stage 1: Request
        Expanded(
          child: _buildTimelineStage(
            number: '1',
            label: 'Request',
            status: requestStatus,
          ),
        ),

        // Connector
        _buildConnector(requestStatus == 'approved'),

        // Stage 2: Survey
        Expanded(
          child: _buildTimelineStage(
            number: '2',
            label: 'Survey',
            status: surveyStatus,
          ),
        ),

        // Connector
        _buildConnector(surveyStatus == 'approved'),

        // Stage 3: Handover
        Expanded(
          child: _buildTimelineStage(
            number: '3',
            label: 'Handover',
            status: handoverStatus,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStage({
    required String number,
    required String label,
    required String status,
  }) {
    Color dotColor;
    Color textColor;
    IconData? icon;

    switch (status) {
      case 'approved':
      case 'completed':
        dotColor = Colors.green;
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        dotColor = Colors.red;
        textColor = Colors.red;
        icon = Icons.cancel;
        break;
      case 'pending':
        dotColor = Colors.orange;
        textColor = Colors.orange;
        icon = Icons.access_time;
        break;
      default:
        dotColor = Colors.grey[300]!;
        textColor = Colors.grey[400]!;
        icon = Icons.radio_button_unchecked;
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: dotColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 2),
          ),
          child: Center(
            child: Icon(icon, color: dotColor, size: 20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          _getStatusLabel(status),
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 30,
      height: 2,
      color: isActive ? Colors.green : Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 40),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      case 'not_started':
        return 'Waiting';
      default:
        return status;
    }
  }

  void _showManageDialog(Map<String, dynamic> request) {
    final requestStatus = request['requestStatus'] ?? 'pending';
    final surveyStatus = request['surveyStatus'] ?? 'not_started';
    final handoverStatus = request['handoverStatus'] ?? 'not_started';

    // Debug logging
    print('📋 Opening manage dialog for request:');
    print('   Request ID: ${request['id']}');
    print('   User Data available: ${request['userData'] != null}');
    if (request['userData'] != null) {
      print('   User Name: ${request['userData']?['fullName']}');
      print('   User Phone: ${request['userData']?['phoneNumber']}');
    } else {
      print('   ⚠️ User data is NULL!');
    }
    print('   Adoption Reason: ${request['adoptionReason']}');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.assignment, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Manage Adoption Request',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Applicant Info
                _buildSectionTitle('Applicant Information'),
                _buildDetailRow(
                  'Name', 
                  request['userData']?['fullName']?.toString() ?? 
                  'Loading...'
                ),
                _buildDetailRow(
                  'Phone', 
                  request['userData']?['phoneNumber']?.toString() ?? 
                  'Not provided'
                ),
                _buildDetailRow(
                  'Address', 
                  request['userData']?['address']?.toString() ?? 
                  'Not provided'
                ),
                _buildDetailRow(
                  'City', 
                  request['userData']?['city']?.toString() ?? 
                  'Not provided'
                ),
                
                const SizedBox(height: 16),
                
                // Application Details
                _buildSectionTitle('Application Details'),
                _buildDetailRow(
                  'Adoption Reason', 
                  request['adoptionReason']?.toString()
                ),
                _buildDetailRow(
                  'Pet Experience', 
                  request['petExperience']?.toString()
                ),
                _buildDetailRow(
                  'Residence', 
                  _formatResidence(request['residenceStatus']?.toString())
                ),
                _buildDetailRow(
                  'Has Yard', 
                  request['hasYard'] == true ? 'Yes' : 'No'
                ),
                _buildDetailRow(
                  'Family Members', 
                  request['familyMembers']?.toString()
                ),
                _buildDetailRow(
                  'Environment', 
                  request['environmentDescription']?.toString()
                ),
                
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Stage 1: Request Management
                _buildStageManagement(
                  stageNumber: 1,
                  stageTitle: 'Stage 1: Request Review',
                  status: requestStatus,
                  notes: request['requestNotes'],
                  onApprove: requestStatus == 'pending'
                      ? () => _showApproveDialog(
                            requestId: request['id'],
                            stage: 'request',
                          )
                      : null,
                  onReject: requestStatus == 'pending'
                      ? () => _showRejectDialog(
                            requestId: request['id'],
                            stage: 'request',
                          )
                      : null,
                ),

                const SizedBox(height: 16),

                // Stage 2: Survey Management
                _buildStageManagement(
                  stageNumber: 2,
                  stageTitle: 'Stage 2: Home Survey',
                  status: surveyStatus,
                  notes: request['surveyNotes'],
                  onApprove: surveyStatus == 'pending'
                      ? () => _showApproveDialog(
                            requestId: request['id'],
                            stage: 'survey',
                          )
                      : null,
                  onReject: surveyStatus == 'pending'
                      ? () => _showRejectDialog(
                            requestId: request['id'],
                            stage: 'survey',
                          )
                      : null,
                ),

                const SizedBox(height: 16),

                // Stage 3: Handover Management
                _buildStageManagement(
                  stageNumber: 3,
                  stageTitle: 'Stage 3: Pet Handover',
                  status: handoverStatus,
                  notes: request['handoverNotes'],
                  onComplete: handoverStatus == 'pending'
                      ? () => _showCompleteHandoverDialog(
                            requestId: request['id'],
                            petId: request['petId'],
                          )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value ?? '-',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageManagement({
    required int stageNumber,
    required String stageTitle,
    required String status,
    String? notes,
    VoidCallback? onApprove,
    VoidCallback? onReject,
    VoidCallback? onComplete,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'approved':
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = status == 'completed' ? 'Completed' : 'Approved';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Pending Action';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.radio_button_unchecked;
        statusText = 'Not Started';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stageTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: $notes',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onApprove != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(
                        'Approve',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (onReject != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(
                        'Reject',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                if (onComplete != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.done_all, size: 16),
                      label: Text(
                        'Complete Handover',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 2,
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
    );
  }

  void _showApproveDialog({
    required String requestId,
    required String stage,
  }) {
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Approve ${stage == 'request' ? 'Request' : 'Survey'}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add notes for the applicant (optional):',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Enter notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel', 
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (stage == 'request') {
                controller.updateRequestStatus(
                  requestId: requestId,
                  status: 'approved',
                  notes: notesController.text.trim(),
                );
              } else {
                controller.updateSurveyStatus(
                  requestId: requestId,
                  status: 'approved',
                  notes: notesController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: Text(
              'Approve', 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog({
    required String requestId,
    required String stage,
  }) {
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Reject ${stage == 'request' ? 'Request' : 'Survey'}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide a reason for rejection:',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel', 
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (notesController.text.trim().isEmpty) {
                Get.snackbar(
                  'Required',
                  'Please provide a reason for rejection',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }

              if (stage == 'request') {
                controller.updateRequestStatus(
                  requestId: requestId,
                  status: 'rejected',
                  notes: notesController.text.trim(),
                );
              } else {
                controller.updateSurveyStatus(
                  requestId: requestId,
                  status: 'rejected',
                  notes: notesController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: Text(
              'Reject', 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteHandoverDialog({
    required String requestId,
    required String petId,
  }) {
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Complete Handover',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will mark the pet as adopted. Add final notes (optional):',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Enter handover notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel', 
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateHandoverStatus(
                requestId: requestId,
                petId: petId,
                notes: notesController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: Text(
              'Complete', 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatResidence(String? status) {
    switch (status) {
      case 'own_house':
        return 'Own House';
      case 'rental':
        return 'Rental';
      case 'boarding':
        return 'Boarding';
      default:
        return status ?? '-';
    }
  }
}
