import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../common/widgets/lottie_loading.dart';
import 'shelter_dashboard_controller.dart';

class ShelterDashboardView extends GetView<ShelterDashboardController> {
  const ShelterDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Obx(() => Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.neutral500,
                ),
              ),
              Text(
                '${controller.shelterName.value}!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
        )),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics cards in a row
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'My Pets',
                        controller.petCount.value.toString(),
                        Icons.pets,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'My Events',
                        controller.eventCount.value.toString(),
                        Icons.event,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Adoption Requests Line Chart
              _buildLineChartCard(
                icon: Icons.assignment,
                title: 'Adoption Requests',
                color: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Followers Line Chart
              _buildLineChartCard(
                icon: Icons.people,
                title: 'Followers',
                color: Colors.purple,
              ),
              const SizedBox(height: 100), // Space for navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    Map<DateTime, int> getTimeSeriesData() {
      if (title == 'Adoption Requests') {
        return controller.adoptionRequestTimeSeriesData;
      } else if (title == 'Followers') {
        return controller.followerTimeSeriesData;
      }
      return {};
    }

    return Obx(() {
      final timeSeriesData = getTimeSeriesData();
      final isLoading = controller.isLoading.value;

      return SizedBox(
        height: 220,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(icon, size: 20, color: color.withOpacity(0.6)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: LottieLoading(width: 80, height: 80),
                      )
                    : timeSeriesData.isEmpty
                        ? Center(
                            child: Text(
                              'No data',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final sortedDates =
                                          timeSeriesData.keys.toList()..sort();
                                      if (value.toInt() < 0 ||
                                          value.toInt() >= sortedDates.length) {
                                        return const SizedBox();
                                      }
                                      final date = sortedDates[value.toInt()];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${date.month}/${date.day}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 8,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: (timeSeriesData.length - 1).toDouble(),
                              minY: 0,
                              maxY:
                                  _getMaxCumulative(timeSeriesData).toDouble() +
                                      1,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _getCumulativeSpots(timeSeriesData),
                                  isCurved: true,
                                  color: color,
                                  barWidth: 2.5,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 3,
                                        color: color,
                                        strokeWidth: 1.5,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        color.withOpacity(0.25),
                                        color.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (touchedSpot) =>
                                      color.withOpacity(0.9),
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      final sortedDates =
                                          timeSeriesData.keys.toList()..sort();
                                      final date = sortedDates[spot.x.toInt()];
                                      return LineTooltipItem(
                                        '${date.month}/${date.day}\n${spot.y.toInt()}',
                                        GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<FlSpot> _getCumulativeSpots(Map<DateTime, int> timeSeriesData) {
    final sortedEntries = timeSeriesData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final List<FlSpot> spots = [];
    int cumulative = 0;

    for (int i = 0; i < sortedEntries.length; i++) {
      cumulative += sortedEntries[i].value;
      spots.add(FlSpot(i.toDouble(), cumulative.toDouble()));
    }

    return spots;
  }

  int _getMaxCumulative(Map<DateTime, int> timeSeriesData) {
    final sortedEntries = timeSeriesData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    int cumulative = 0;
    for (var entry in sortedEntries) {
      cumulative += entry.value;
    }

    return cumulative;
  }
}
