import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import 'user_management_controller.dart';

class UserManagementView extends GetView<UserManagementController> {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Manage Users',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RectangleSearchBar(
              hintText: 'Search by name or email...',
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),
          // User List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final displayUsers = controller.filteredUsers;

              if (displayUsers.isEmpty) {
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
                        'No users found',
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
                onRefresh: controller.fetchUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayUsers.length,
                  itemBuilder: (context, index) {
                    final user = displayUsers[index];
                    return _buildUserCard(user);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String uid = user['uid'] ?? '';
    final String name = user['fullName'] ?? user['name'] ?? 'No Name';
    final String email = user['email'] ?? 'No Email';
    final bool isActive = user['isActive'] ?? true;
    final String accountStatus = user['accountStatus'] ?? 'active';
    final String? profilePicture = user['profilePicture'];

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
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: profilePicture != null && profilePicture.isNotEmpty
                      ? NetworkImage(profilePicture)
                      : null,
                  child: profilePicture == null || profilePicture.isEmpty
                      ? Icon(
                          Icons.person,
                          color: AppColors.primary,
                        )
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
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accountStatus == 'suspended'
                                  ? Colors.orange.shade100
                                  : isActive
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              accountStatus == 'suspended'
                                  ? 'Suspended'
                                  : isActive
                                      ? 'Aktif'
                                      : 'Nonaktif',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: accountStatus == 'suspended'
                                    ? Colors.orange
                                    : isActive
                                        ? AppColors.primary
                                        : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.neutral500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action Buttons
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
                      controller.toggleUserStatus(uid, isActive);
                    } else if (value == 'suspend') {
                      _showSuspendDialog(uid, name);
                    } else if (value == 'lift_suspension') {
                      controller.liftSuspension(uid, name);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(uid, name);
                    }
                  },
                  itemBuilder: (context) => [
                    if (accountStatus != 'suspended')
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
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String uid, String name) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Confirmation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete user "$name"?\nThis action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.deleteUser(uid);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(String uid, String name) {
    final reasonController = TextEditingController();
    final startDate = Rx<DateTime>(DateTime.now());
    final endDate = Rx<DateTime>(DateTime.now().add(const Duration(days: 7)));
    bool isDisposed = false;

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          if (!isDisposed) {
            reasonController.dispose();
            isDisposed = true;
          }
          return true;
        },
        child: AlertDialog(
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
                  'Suspend user: "$name"',
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
                Obx(() => InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: Get.context!,
                      initialDate: startDate.value,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      startDate.value = picked;
                      // Ensure end date is after start date
                      if (endDate.value.isBefore(picked)) {
                        endDate.value = picked.add(const Duration(days: 1));
                      }
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
                          '${startDate.value.day}/${startDate.value.month}/${startDate.value.year}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )),
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
                Obx(() => InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: Get.context!,
                      initialDate: endDate.value,
                      firstDate: startDate.value.add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      endDate.value = picked;
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
                          '${endDate.value.day}/${endDate.value.month}/${endDate.value.year}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )),
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
                  controller: reasonController,
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
              onPressed: () {
                if (!isDisposed) {
                  reasonController.dispose();
                  isDisposed = true;
                }
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  // Don't use snackbar, just return
                  return;
                }
                
                // Store values
                final start = startDate.value;
                final end = endDate.value;
                
                // Close dialog first
                Get.back();
                
                // Wait for dialog to fully close, then dispose
                await Future.delayed(const Duration(milliseconds: 100));
                if (!isDisposed) {
                  reasonController.dispose();
                  isDisposed = true;
                }
                
                // Call suspend
                controller.suspendUser(uid, start, end, reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Suspend'),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Ensure disposal if dialog is dismissed by tapping outside
      if (!isDisposed) {
        reasonController.dispose();
        isDisposed = true;
      }
    });
  }
}
