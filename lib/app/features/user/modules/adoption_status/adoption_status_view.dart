import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../theme/app_colors.dart';
import 'adoption_status_controller.dart';

class AdoptionStatusView extends GetView<AdoptionStatusController> {
  const AdoptionStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
          child: Text(
            'My Adoption Requests',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.adoptionRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No adoption requests yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start by adopting a pet!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
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
    final shelterData = request['shelterData'] as Map<String, dynamic>?;

    final petName = petData?['petName'] ?? 'Unknown Pet';
    final petBreed = petData?['breed'] ?? '';
    final shelterName = shelterData?['shelterName'] ?? 'Unknown Shelter';

    // Get image URL
    String imageUrl = 'https://via.placeholder.com/100x100?text=Pet';
    if (petData?['imageUrls'] != null &&
        petData!['imageUrls'] is List &&
        (petData['imageUrls'] as List).isNotEmpty) {
      imageUrl = petData['imageUrls'][0].toString();
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
          onTap: () => _showDetailDialog(request),
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
                          child: const Center(child: CircularProgressIndicator()),
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

                    // Pet info
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
                            if (petBreed.isNotEmpty)
                              Text(
                                petBreed,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.home, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    shelterName,
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
            isFirst: true,
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
            isLast: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStage({
    required String number,
    required String label,
    required String status,
    bool isFirst = false,
    bool isLast = false,
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

  void _showDetailDialog(Map<String, dynamic> request) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Request Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Adoption Reason', request['adoptionReason']),
              _buildDetailRow('Pet Experience', request['petExperience']),
              _buildDetailRow(
                  'Residence', _formatResidence(request['residenceStatus'])),
              _buildDetailRow('Has Yard', request['hasYard'] ? 'Yes' : 'No'),
              _buildDetailRow(
                  'Family Members', request['familyMembers']?.toString() ?? '-'),
              _buildDetailRow('Environment', request['environmentDescription']),
              
              if (request['requestNotes'] != null &&
                  request['requestNotes'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Shelter Notes (Request):',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request['requestNotes'],
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
              
              if (request['surveyNotes'] != null &&
                  request['surveyNotes'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Shelter Notes (Survey):',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request['surveyNotes'],
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
              
              if (request['handoverNotes'] != null &&
                  request['handoverNotes'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Shelter Notes (Handover):',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request['handoverNotes'],
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // If request is still pending, allow user to cancel it
              if ((request['requestStatus'] ?? 'pending').toString().toLowerCase() == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      Get.back();
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          title: Text(
                            'Cancel Request',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'Are you sure you want to cancel this adoption request?',
                            style: GoogleFonts.poppins(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: Text(
                                'No',
                                style: GoogleFonts.poppins(color: Colors.grey[700]),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: Text(
                                'Yes',
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await controller.cancelRequest(request['id'] ?? request['applicationId']);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Cancel Request',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
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
