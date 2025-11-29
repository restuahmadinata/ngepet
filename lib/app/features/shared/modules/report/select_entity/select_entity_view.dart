import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../common/widgets/lottie_loading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../common/widgets/rectangle_search_bar.dart';
import '../../../../../theme/app_colors.dart';
import 'select_entity_controller.dart';

class SelectEntityView extends GetView<SelectEntityController> {
  const SelectEntityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
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
        title: Obx(() => Text(
          controller.entityType.value.value == 'user'
              ? 'Select User to Report'
              : 'Select Shelter to Report',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        )),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RectangleSearchBar(
                hintText: 'Search by name, email, or city...',
                onChanged: controller.onSearchChanged,
                controller: controller.searchController,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: LottieLoading(),
                    );
                  }

                  if (controller.filteredEntities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.searchQuery.value.isEmpty
                                ? 'No ${controller.entityType.value.value}s found'
                                : 'No results found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.filteredEntities.length,
                    itemBuilder: (context, index) {
                      final entity = controller.filteredEntities[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: entity['photoUrl'] != null
                              ? CachedNetworkImage(
                                  imageUrl: entity['photoUrl'],
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                    backgroundImage: imageProvider,
                                    radius: 28,
                                  ),
                                  placeholder: (context, url) => CircleAvatar(
                                    backgroundColor: Colors.grey[200],
                                    radius: 28,
                                    child: Icon(
                                      controller.entityType.value.value == 'user'
                                          ? Icons.person
                                          : Icons.store,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                    backgroundColor: Colors.grey[200],
                                    radius: 28,
                                    child: Icon(
                                      controller.entityType.value.value == 'user'
                                          ? Icons.person
                                          : Icons.store,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  radius: 28,
                                  child: Icon(
                                    controller.entityType.value.value == 'user'
                                        ? Icons.person
                                        : Icons.store,
                                    color: AppColors.primary,
                                  ),
                                ),
                          title: Text(
                            entity['name'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                entity['email'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (entity['city'] != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      entity['city'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          onTap: () => controller.selectEntity(entity),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
