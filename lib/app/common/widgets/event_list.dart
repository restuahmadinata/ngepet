import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ngepet/app/theme/app_colors.dart';
import '../../features/shared/modules/event_detail/event_detail_view.dart';

class EventListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String shelter;
  final String location;
  final String description;
  final VoidCallback? onJoinPressed;
  final Map<String, dynamic>? fullData;

  const EventListItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.shelter,
    required this.location,
    required this.description,
    this.onJoinPressed,
    this.fullData,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        color: Colors.white,
              shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.neutral300, width: 1),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (fullData != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailView(eventData: fullData!),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    httpHeaders: const {
                      'Connection': 'keep-alive',
                      'User-Agent': 'Flutter App',
                    },
                    maxHeightDiskCache: 400,
                    maxWidthDiskCache: 400,
                    memCacheHeight: 300,
                    memCacheWidth: 300,
                    fadeInDuration: const Duration(milliseconds: 200),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholder: (context, url) => Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) {
                      print('Error loading event image: $url');
                      print('Error details: $error');
                      return Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey.shade300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 48,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Failed to load photo',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              shelter,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: onJoinPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.1),
                          foregroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Detail Acara'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class EventList extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const EventList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      cacheExtent: 200,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventListItem(
          imageUrl: event['imageUrl']?.toString() ?? '',
          title: event['title']?.toString() ?? '',
          date: event['date']?.toString() ?? '',
          shelter: event['shelter']?.toString() ?? '',
          location: event['location']?.toString() ?? '',
          description: event['description']?.toString() ?? '',
          fullData: event,
          onJoinPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Melihat detail event ${event['title']}')),
            );
          },
        );
      },
    );
  }
}
