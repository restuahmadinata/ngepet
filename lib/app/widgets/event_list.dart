import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String shelter;
  final String location;
  final String description;
  final VoidCallback? onJoinPressed;

  const EventListItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.shelter,
    required this.location,
    required this.description,
    this.onJoinPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                placeholder: (context, url) => Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.event, color: Colors.grey, size: 48),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$date', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('$shelter', style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('$location', style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis, maxLines: 1),
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
                    ),
                    child: const Text('Detail Acara'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventList extends StatelessWidget {
  final List<Map<String, String>> events;

  const EventList({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventListItem(
          imageUrl: event['imageUrl']!,
          title: event['title']!,
          date: event['date']!,
          shelter: event['shelter']!,
          location: event['location']!,
          description: event['description']!,
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