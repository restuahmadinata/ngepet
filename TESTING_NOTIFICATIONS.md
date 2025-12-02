# Testing Chat Notifications

## Quick Test Guide

### Prerequisites
- Two devices/emulators (or one device + one emulator)
- App installed on both
- Two different accounts (one regular user, one shelter)

### Test Steps

#### 1. Setup
```
Device A: Login as Regular User (e.g., user@example.com)
Device B: Login as Shelter Account (e.g., shelter@example.com)
```

#### 2. Start Conversation
- On Device A (User): Browse pets and start a chat with a shelter
- This creates a conversation between the user and shelter

#### 3. Test Notification Flow

**Send from User → Receive on Shelter:**
1. On Device A (User): Send a message "Hello, is this pet still available?"
2. On Device B (Shelter): 
   - Keep app in background or on home screen
   - You should see a notification appear
   - Notification shows: User's name + message preview
   - Tap the notification → Opens chat conversation

**Send from Shelter → Receive on User:**
1. On Device B (Shelter): Reply with "Yes, the pet is available!"
2. On Device A (User):
   - Keep app in background
   - You should see a notification appear
   - Notification shows: Shelter's name + message preview
   - Tap the notification → Opens chat conversation

#### 4. Test Scenarios

✅ **App in Background**: Notifications should appear  
✅ **App in Foreground (other screen)**: Notifications should appear  
✅ **Own Messages**: Should NOT show notifications for your own messages  
✅ **Multiple Messages**: Each new message triggers a notification  
✅ **Tap Notification**: Should open the specific chat conversation  

❌ **App Fully Closed**: Won't receive notifications (by design - this is normal for local notifications)

### Expected Behavior

#### Notification Appearance
```
┌─────────────────────────────────┐
│ 🐾 Ngepet                       │
├─────────────────────────────────┤
│ John Doe                        │ ← Sender name
│ Hello, is this pet available?   │ ← Message preview
└─────────────────────────────────┘
```

#### What Gets Notified
- ✅ New messages from other users
- ✅ Messages in any conversation
- ✅ Messages while app is in background
- ✅ Messages while app is in foreground (on different screen)

#### What Doesn't Get Notified
- ❌ Your own messages
- ❌ Messages when you're already viewing that chat
- ❌ Messages when app is completely closed/terminated
- ❌ Already-read messages

### Debugging

#### Check Permissions (Android 13+)
```
Settings → Apps → Ngepet → Notifications → Allow
```

#### Console Logs
When a message is sent, you should see in the console:
```
[ChatNotificationService] New message from: <sender_name>
[ChatNotificationService] Showing notification...
```

#### Common Issues

**Problem**: No notifications appearing
**Solutions**:
1. Check notification permissions in app settings
2. Ensure app is in background/foreground (not fully closed)
3. Verify both users are in the same conversation
4. Check console for any errors

**Problem**: Notifications for own messages
**Solutions**:
1. This shouldn't happen - check the service code
2. Verify user authentication is working correctly

**Problem**: Duplicate notifications
**Solutions**:
1. The service has duplicate detection
2. Should only show once per new message

### Testing Checklist

- [ ] Install app on 2 devices
- [ ] Login with different accounts (user + shelter)
- [ ] Grant notification permissions
- [ ] Start a conversation about a pet
- [ ] Send message from Device A
- [ ] Verify notification on Device B
- [ ] Tap notification and verify it opens chat
- [ ] Send reply from Device B
- [ ] Verify notification on Device A
- [ ] Test with app in background
- [ ] Test with app in foreground (different screen)
- [ ] Verify own messages don't trigger notifications

### Demo Tips for Final Project

1. **Prepare in advance**: Have both devices ready and logged in
2. **Show the flow**: User sends message → Notification appears → Tap to open
3. **Explain the approach**: "Using local notifications for simplicity and zero cost"
4. **Mention limitations**: "Works when app is running, perfect for final project scope"
5. **Highlight benefits**: "Real-time, free, simple to maintain"

### Success Criteria

✅ Notifications appear for new messages  
✅ Notifications show sender name and message preview  
✅ Tapping notification opens the correct chat  
✅ No notifications for own messages  
✅ Works consistently in foreground/background mode

## Need Help?

If notifications aren't working:
1. Check `CHAT_NOTIFICATIONS.md` for architecture details
2. Review `lib/app/services/chat_notification_service.dart`
3. Ensure Firebase is properly initialized
4. Verify Firestore security rules allow reading conversations
