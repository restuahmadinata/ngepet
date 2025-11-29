import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../models/enums.dart';

class ReportTimelineView extends StatelessWidget {
  const ReportTimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final reportId = Get.arguments['reportId'] as String?;
    final entityType = Get.arguments['entityType'] as EntityType?;
    final reportedId = Get.arguments['reportedId'] as String?;
    final reportedName = Get.arguments['reportedName'] as String?;
    if (reportId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Report Timeline')),
        body: Center(child: Text('Invalid report ID')),
      );
    }

    return Scaffold(
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
          'Report Timeline',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Report Again',
            onPressed: () {
              // Navigate to report form for the same entity
              Get.toNamed('/report-form', arguments: {
                'reportedId': reportedId,
                'reportedName': reportedName,
                'entityType': entityType,
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('reports').doc(reportId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Report not found'));
          }

          final report = snapshot.data!.data() as Map<String, dynamic>;
          final status = report['reportStatus'] as String;
          final reportDate = (report['reportDate'] as Timestamp).toDate();
          final reviewedDate = report['reviewedDate'] != null ? (report['reviewedDate'] as Timestamp).toDate() : null;

          final steps = [
            {
              'title': 'Report Submitted',
              'subtitle': 'Your report has been submitted',
              'date': reportDate,
              'isCompleted': true,
            },
            {
              'title': 'Under Review',
              'subtitle': 'Admin is reviewing your report',
              'date': reviewedDate ?? reportDate,
              'isCompleted': ['reviewing', 'resolved', 'rejected'].contains(status),
            },
            if (status == 'resolved' || status == 'rejected')
              {
                'title': status == 'resolved' ? 'Resolved' : 'Rejected',
                'subtitle': status == 'resolved' ? 'Action has been taken' : 'Report was dismissed',
                'date': reviewedDate!,
                'isCompleted': true,
              },
          ];

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index] as Map<String, dynamic>;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(
                        step['isCompleted'] ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: step['isCompleted'] ? AppColors.primary : Colors.grey,
                      ),
                      if (index < steps.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: (steps[index + 1]['isCompleted'] as bool) ? AppColors.primary : Colors.grey,
                        ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          step['subtitle'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(step['date']),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}