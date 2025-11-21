import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../theme/app_colors.dart';
import '../../../../models/enums.dart';
import 'report_details_controller.dart';

class ReportDetailsView extends GetView<ReportDetailsController> {
  const ReportDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.reporterInfo.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final report = controller.report.value;
        if (report == null) {
          return const Center(child: Text('Report not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(report.reportStatus).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.report,
                          color: _getStatusColor(report.reportStatus),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              report.reportStatus.value.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(report.reportStatus),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reporter Info
              _buildInfoCard(
                title: 'Reporter',
                icon: Icons.person_outline,
                child: controller.reporterInfo.value != null
                    ? _buildUserInfo(controller.reporterInfo.value!)
                    : const Text('Loading...'),
              ),
              const SizedBox(height: 16),

              // Reported Entity Info
              _buildInfoCard(
                title: 'Reported ${report.entityType.value}',
                icon: report.entityType == EntityType.user
                    ? Icons.person
                    : Icons.store,
                child: controller.reportedInfo.value != null
                    ? _buildUserInfo(controller.reportedInfo.value!)
                    : const Text('Loading...'),
              ),
              const SizedBox(height: 16),

              // Violation Details
              _buildInfoCard(
                title: 'Violation Details',
                icon: Icons.warning_amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Category', report.violationCategory.displayName),
                    const SizedBox(height: 12),
                    _buildDetailRow('Description', report.reportDescription),
                    if (report.incidentLocation != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Location', report.incidentLocation!),
                    ],
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Reported On',
                      report.reportDate != null
                          ? DateFormat('MMM dd, yyyy HH:mm').format(report.reportDate!)
                          : 'N/A',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Evidence Images
              if (report.evidenceAttachments.isNotEmpty) ...[
                _buildInfoCard(
                  title: 'Evidence Images',
                  icon: Icons.photo_library,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: report.evidenceAttachments.length,
                    itemBuilder: (context, index) {
                      final imageUrl = report.evidenceAttachments[index];
                      return GestureDetector(
                        onTap: () => _showFullScreenImage(imageUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Admin Notes
              _buildInfoCard(
                title: 'Admin Notes',
                icon: Icons.note_alt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report.adminNotes != null) ...[
                      Text(
                        report.adminNotes!,
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: controller.adminNotesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add notes about this report...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (report.reportStatus != ReportStatus.resolved &&
                  report.reportStatus != ReportStatus.rejected) ...[
                // Only show "Mark Reviewing" if not already reviewing
                if (report.reportStatus != ReportStatus.reviewing) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.updateStatus(ReportStatus.reviewing),
                          icon: const Icon(Icons.visibility),
                          label: const Text('Mark Reviewing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => _showSuspendDialog(
                                  controller.report.value!.reportedId,
                                  controller.reportedInfo.value!['fullName'] ??
                                      controller.reportedInfo.value!['shelterName'] ??
                                      'Unknown',
                                ),
                        icon: const Icon(Icons.block),
                        label: const Text('Suspend User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.updateStatus(ReportStatus.rejected),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject Report'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> userInfo) {
    final photoUrl = userInfo['profilePhoto'] ?? userInfo['shelterPhoto'];
    final name = userInfo['fullName'] ?? userInfo['shelterName'] ?? 'Unknown';
    final email = userInfo['email'] ?? userInfo['shelterEmail'] ?? '';
    final city = userInfo['city'];

    return Row(
      children: [
        if (photoUrl != null)
          CachedNetworkImage(
            imageUrl: photoUrl,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundImage: imageProvider,
              radius: 24,
            ),
            placeholder: (context, url) => CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 24,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 24,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          )
        else
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            radius: 24,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                email,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (city != null)
                Text(
                  city,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
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
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.reviewing:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  void _showFullScreenImage(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuspendDialog(String uid, String name) {
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _SuspendUserDialog(
          uid: uid,
          name: name,
          controller: controller,
        );
      },
    );
  }
}

class _SuspendUserDialog extends StatefulWidget {
  final String uid;
  final String name;
  final ReportDetailsController controller;

  const _SuspendUserDialog({
    required this.uid,
    required this.name,
    required this.controller,
  });

  @override
  State<_SuspendUserDialog> createState() => _SuspendUserDialogState();
}

class _SuspendUserDialogState extends State<_SuspendUserDialog> {
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
        'Suspend User',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suspend user: "${widget.name}"',
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
            widget.controller.suspendUser(widget.uid, _startDate, _endDate, reason);
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
