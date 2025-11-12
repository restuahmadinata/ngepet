# 🔥 Firebase Firestore Structure - Ngepet App

## 📋 Database Structure Overview

This document explains the Firestore database structure for the Ngepet app (Pet Adoption Platform).

---

## 📊 Collections

### 1️⃣ **users** Collection
Stores application user data (adopters/potential adopters).

```javascript
users/{user_id}
{
  // Authentication & Identity
  "userId": string,              // PK - Firebase Auth UID
  "email": string,               // UK - User email from auth
  
  // Profile Information
  "fullName": string,            // User's full name
  "phoneNumber": string,         // Phone number
  "address": string,             // Full address
  "city": string,                // City/regency
  "dateOfBirth": Timestamp,      // Date of birth
  "gender": string,              // enum: "Male", "Female"
  "profilePhoto": string,        // Profile photo URL
  
  // Account Status
  "accountStatus": string,       // enum: "active", "suspended", "banned"
  
  // Timestamps
  "createdAt": Timestamp,        // Account creation time
  "updatedAt": Timestamp         // Last update time
}
```

**Indexes:**
- `email` (unique)
- `accountStatus`

---

### 2️⃣ **shelters** Collection
Stores shelter/animal shelter data.

```javascript
shelters/{shelter_id}
{
  // Identity
  "shelterId": string,           // PK - Firebase auth UID
  
  // Shelter Information
  "shelterName": string,         // Shelter name
  "description": string,         // Shelter description
  "city": string,                // City/regency
  "geoPoint": GeoPoint,          // Full shelter address using geoPoint, converted to text after selecting location
  
  // Contact Information
  "shelterPhone": string,        // Shelter phone number
  "shelterEmail": string,        // Shelter email from auth
  
  // Media
  "shelterPhoto": string,        // Shelter profile photo URL
  
  // Verification
  "verificationStatus": string,  // enum: "pending", "approved", "rejected"
  "verificationDate": Timestamp, // Verification date
  "legalNumber": string,         // Shelter legal number
  "rejectionReason": string,     // Rejection reason (if rejected)
  
  // Timestamps
  "createdAt": Timestamp,        // Creation time
  "updatedAt": Timestamp         // Last update time
}
```

**Indexes:**
- `userId`
- `verificationStatus`
- `city`

---

### 3️⃣ **followers** Collection
Stores shelter follower data.

```javascript
followers/{follower_id}
{
  "followerId": string,          // PK - auto-generated
  "userId": string,              // FK - user who is following
  "shelterId": string,           // FK - shelter being followed
  "followedAt": Timestamp        // Follow start time
}
```

**Indexes:**
- Composite: `userId` + `shelterId` (unique)
- `shelterId`

---

### 4️⃣ **pets** Collection
Stores data for pets available for adoption.

```javascript
pets/{pet_id}
{
  // Identity
  "petId": string,               // PK - auto-generated
  "shelterId": string,           // FK - owner shelter
  
  // Category
  "category": string,            // Pet type (Dog, Cat, Rabbit, Bird, etc.)
  
  // Basic Information
  "petName": string,             // Pet name
  "gender": string,              // enum: "Male", "Female"
  "ageMonths": number,           // Age in months
  "breed": string,               // Pet breed
  "description": string,         // Pet description
  
  // Health & Status
  "healthCondition": string,     // Health condition
  "adoptionStatus": string,      // enum: "available", "pending", "adopted"
  
  // Location
  "location": string,            // Pet location (from shelter address)
  
  // Shelter Info (denormalized for quick access)
  "shelterName": string,         // Shelter name
  
  // Photos (stored as array in document)
  "imageUrls": array<string>,    // Array of pet photo URLs, index 0 = primary/thumbnail
  
  // Timestamps
  "createdAt": Timestamp,        // Creation time
  "updatedAt": Timestamp         // Last update time
}
```

**Indexes:**
- `shelterId`
- `category`
- `adoptionStatus`
- Composite: `adoptionStatus` + `createdAt`

---

### 5️⃣ **adoption_applications** Collection
Stores adoption applications from users.

```javascript
adoption_applications/{application_id}
{
  // Identity
  "applicationId": string,       // PK - auto-generated
  "petId": string,               // FK - pet being applied for
  "userId": string,              // FK - applicant user
  "shelterId": string,           // FK - pet owner shelter
  
  // Application Details
  "adoptionReason": string,      // Reason for wanting to adopt
  "petExperience": string,       // Experience caring for pets
  "residenceStatus": string,     // enum: "own_house", "rental", "boarding"
  "hasYard": boolean,            // Has a yard
  "familyMembers": number,       // Number of family members
  "environmentDescription": string, // Description of living environment
  
  // Status & Processing
  "applicationStatus": string,   // enum: "pending", "approved", "rejected", "completed"
  "shelterNotes": string,        // Notes from shelter
  
  // Timestamps
  "applicationDate": Timestamp,  // Application submission time
  "processedDate": Timestamp,    // Processing time by shelter
  "updatedAt": Timestamp         // Last update time
}
```

**Indexes:**
- `petId`
- `userId`
- `shelterId`
- `applicationStatus`
- Composite: `shelterId` + `applicationStatus`

---

### 6️⃣ **messages** Collection
Stores messages in adoption chat.

```javascript
messages/{message_id}
{
  "messageId": string,           // PK - auto-generated
  "applicationId": string,       // FK - related application
  "senderId": string,            // FK - sender user
  "messageContent": string,      // Message content
  "isRead": boolean,             // Read status
  "sentAt": Timestamp            // Sending time
}
```

**Indexes:**
- `applicationId` + `sentAt`
- `senderId`

---

### 7️⃣ **events** Collection
Stores event data organized by shelters.

```javascript
events/{event_id}
{
  // Identity
  "eventId": string,             // PK - auto-generated
  "shelterId": string,           // FK - organizer shelter
  
  // Event Information
  "eventTitle": string,          // Event title
  "eventDescription": string,    // Event description
  "location": string,            // Event location
  "eventDate": Timestamp,        // Event date
  "startTime": string,           // Start time (HH:mm)
  "endTime": string,             // End time (HH:mm)
  
  // Media
  "imageUrls": string,           // Event banner URL
  
  // Status
  "eventStatus": string,         // enum: "upcoming", "ongoing", "completed", "cancelled"
  
  // Timestamps
  "createdAt": Timestamp,        // Creation time
  "updatedAt": Timestamp         // Update time
}
```

**Indexes:**
- `shelterId`
- `eventStatus`
- `eventDate`

---

### 8️⃣ **reports** Collection
Stores violation reports.

```javascript
reports/{report_id}
{
  // Identity
  "reportId": string,            // PK - auto-generated
  "reporterId": string,          // FK - reporter user
  "reportedId": string,          // FK - reported user/shelter
  
  // Report Details
  "entityType": string,          // enum: "user", "shelter", "pet"
  "violationCategory": string,   // enum: "fraud", "animal_abuse", "spam", "inappropriate_content"
  "reportDescription": string,   // Report description
  "incidentLocation": string,    // Incident location
  "evidenceAttachment": string,  // Evidence URL (photo/document)
  
  // Status & Processing
  "reportStatus": string,        // enum: "pending", "reviewing", "resolved", "rejected"
  "adminId": string,             // FK - reviewing admin
  "adminNotes": string,          // Notes from admin
  
  // Timestamps
  "reportDate": Timestamp,       // Report creation time
  "reviewedDate": Timestamp      // Admin review time
}
```

**Indexes:**
- `reporterId`
- `reportedId`
- `reportStatus`
- `adminId`

---

### 🔟 **admins** Collection
Stores platform admin data.

```javascript
admins/{admin_id}
{
  "adminId": string,             // PK
  "adminName": string,           // Admin name
  "createdAt": Timestamp         // Creation time
}
```

**Indexes:**
- `adminId`
- `accessLevel`

---


### 1️⃣3️⃣ **platform_analytics** Collection
Stores platform analytics data per day.

```javascript
platform_analytics/{analytics_id}
{
  "analyticsId": string,         // PK - auto-generated
  "recordDate": Timestamp,       // Record date (date only)
  
  // Metrics
  "totalActiveUsers": number,    // Total active users
  "totalSuccessfulAdoptions": number, // Total successful adoptions
  "totalNewApplications": number, // Total new applications
  "totalIncomingReports": number, // Total incoming reports
  "totalAvailablePets": number,  // Total available pets
  
  // Timestamp
  "createdAt": Timestamp         // Record creation time
}
```

**Indexes:**
- `recordDate` (unique)

---