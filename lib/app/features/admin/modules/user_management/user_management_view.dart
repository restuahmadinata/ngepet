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
                    if (value == 'suspend') {
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
  final UserManagementController controller;

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
    print('🟢 [DIALOG] initState called');
    _reasonController = TextEditingController();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 7));
    
    _reasonController.addListener(() {
      print('🔵 [DIALOG] TextField changed: ${_reasonController.text}');
    });
  }

  @override
  void dispose() {
    print('🔴 [DIALOG] dispose called - setting _isDisposing to true');
    _isDisposing = true;
    
    // Dispose immediately to prevent any pending rebuilds from using the controller
    try {
      _reasonController.dispose();
      print('🔴 [DIALOG] controller disposed successfully');
    } catch (e) {
      print('⚠️ [DIALOG] Error disposing controller: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 [DIALOG] build called - _isDisposing: $_isDisposing');
    
    if (_isDisposing) {
      print('⚠️ [DIALOG] build called while disposing - returning empty dialog');
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
                print('📅 [DIALOG] Start date picker opening');
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                print('📅 [DIALOG] Start date picked: $picked, mounted: $mounted');
                if (picked != null && mounted && !_isDisposing) {
                  setState(() {
                    _startDate = picked;
                    // Ensure end date is after start date
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
                print('📅 [DIALOG] End date picker opening');
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate.add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                print('📅 [DIALOG] End date picked: $picked, mounted: $mounted');
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
          onPressed: () {
            print('❌ [DIALOG] Cancel button pressed');
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            print('✅ [DIALOG] Suspend button pressed');
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) {
              print('⚠️ [DIALOG] Reason is empty, returning');
              return;
            }

            print('✅ [DIALOG] Calling suspendUser and closing dialog');
            // Close dialog and call suspend
            Navigator.of(context).pop();
            widget.controller.suspendUser(widget.uid, _startDate, _endDate, reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC1C1), // pastel red
            foregroundColor: Colors.black, // text color
          ),
          child: const Text('Suspend'),
        ),
      ],
    );
  }
}