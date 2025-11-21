# 🔥 Firebase Firestore Structure - Ngepet App

## 📋 Database Structure Overview

This document explains the Firestore database structure for the Ngepet app (Pet Adoption Platform).

**⚠️ IMPORTANT: Type Safety with Enums**

All enum fields are strictly enforced in the Dart models through the `enums.dart` file. When storing data to Firestore, enum values are converted to their string representations. When reading from Firestore, strings are parsed back to enums with proper defaults.

See `lib/app/models/enums.dart` for all enum definitions.

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
  "gender": string,              // ENUM: "Male", "Female" (see Gender enum)
  "profilePhoto": string,        // Profile photo URL
  
  // Account Status
  "accountStatus": string,       // ENUM: "active", "suspended", "banned" (see AccountStatus enum)
  "isActive": boolean,           // Account active status (for quick filtering)
  
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
  "verificationStatus": string,  // ENUM: "pending", "approved", "rejected" (see VerificationStatus enum)
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
  "category": string,            // ENUM: Pet type (Dog, Cat, Rabbit, Bird, Hamster, Guinea Pig, Fish, Turtle, Other) (see PetCategory enum)
  
  // Basic Information
  "petName": string,             // Pet name
  "gender": string,              // ENUM: "Male", "Female" (see Gender enum)
  "ageMonths": number,           // Age in months (MUST be in months - strictly enforced)
  "breed": string,               // Pet breed
  "description": string,         // Pet description
  
  // Health & Status
  "healthCondition": string,     // Health condition
  "adoptionStatus": string,      // ENUM: "available", "pending", "adopted" (see AdoptionStatus enum)
  
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
  "residenceStatus": string,     // ENUM: "own_house", "rental", "boarding" (see ResidenceStatus enum)
  "hasYard": boolean,            // Has a yard
  "familyMembers": number,       // Number of family members
  "environmentDescription": string, // Description of living environment
  
  // Status & Processing
  "applicationStatus": string,   // ENUM: "pending", "approved", "rejected", "completed" (see ApplicationStatus enum)
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
  "eventStatus": string,         // ENUM: "upcoming", "ongoing", "completed", "cancelled" (see EventStatus enum)
  
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
  "entityType": string,          // ENUM: "user", "shelter", "pet" (see EntityType enum)
  "violationCategory": string,   // ENUM: "fraud", "animal_abuse", "spam", "inappropriate_content" (see ViolationCategory enum)
  "reportDescription": string,   // Report description
  "incidentLocation": string,    // Incident location
  "evidenceAttachments": array,  // Array of evidence URLs (photos/documents)
  
  // Status & Processing
  "reportStatus": string,        // ENUM: "pending", "reviewing", "resolved", "rejected" (see ReportStatus enum)
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

### 9️⃣ **suspensions** Collection
Stores user suspension records and history.

```javascript
suspensions/{suspension_id}
{
  // Identity
  "suspensionId": string,        // PK - auto-generated
  "userId": string,              // FK - suspended user
  "adminId": string,             // FK - admin who issued suspension (optional)
  "reportId": string,            // FK - related report (if from report)
  
  // Suspension Details
  "reason": string,              // Reason for suspension
  "violationCategory": string,   // ENUM: violation category from report (optional)
  "suspensionStart": Timestamp,  // Suspension start date/time
  "suspensionEnd": Timestamp,    // Suspension end date/time
  
  // Status
  "suspensionStatus": string,    // ENUM: "active", "lifted", "expired"
  "liftedBy": string,            // FK - admin who lifted (if applicable)
  "liftedAt": Timestamp,         // Time when suspension was lifted
  "liftReason": string,          // Reason for lifting suspension early
  
  // Timestamps
  "createdAt": Timestamp,        // Record creation time
  "updatedAt": Timestamp         // Last update time
}
```

**Indexes:**
- `userId`
- `suspensionStatus`
- Composite: `userId` + `suspensionStatus`
- Composite: `suspensionEnd` + `suspensionStatus`

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

## 🎯 ENUM Definitions

All enum fields in the database are strictly type-checked in the Dart application layer. Below are all the enums used:

### User & Authentication Enums

**Gender**
- `Male`
- `Female`

**AccountStatus**
- `active` - User can access the app normally
- `suspended` - Temporarily cannot access (e.g., pending review)
- `banned` - Permanently blocked from the platform

### Shelter Enums

**VerificationStatus**
- `pending` - Awaiting admin verification
- `approved` - Shelter verified and active
- `rejected` - Verification rejected

### Pet Enums

**PetCategory** (Extensible list)
- `Dog`
- `Cat`
- `Rabbit`
- `Bird`
- `Hamster`
- `Guinea Pig`
- `Fish`
- `Turtle`
- `Other`

**AdoptionStatus**
- `available` - Pet can be adopted
- `pending` - Adoption application in progress
- `adopted` - Pet has been adopted

### Adoption Application Enums

**ResidenceStatus**
- `own_house` - Applicant owns their home
- `rental` - Living in rental property
- `boarding` - Boarding/temporary housing

**ApplicationStatus** (Overall status)
- `pending` - Application submitted, under review
- `approved` - Application approved
- `rejected` - Application rejected
- `completed` - Adoption completed

**RequestStatus** (Stage 1)
- `pending` - Request under review
- `approved` - Request approved, moving to survey
- `rejected` - Request rejected

**SurveyStatus** (Stage 2)
- `not_started` - Survey stage not yet begun
- `pending` - Survey scheduled or in progress
- `approved` - Survey passed, moving to handover
- `rejected` - Survey failed

**HandoverStatus** (Stage 3)
- `not_started` - Handover not yet begun
- `pending` - Handover scheduled
- `completed` - Pet successfully handed over

### Event Enums

**EventStatus**
- `upcoming` - Event scheduled for future
- `ongoing` - Event currently happening
- `completed` - Event finished
- `cancelled` - Event cancelled

### Report & Moderation Enums

**EntityType** (What is being reported)
- `user` - Reporting a user
- `shelter` - Reporting a shelter
- `pet` - Reporting a pet listing

**ViolationCategory**
- `fraud` - Fraudulent activity
- `animal_abuse` - Animal abuse/neglect
- `spam` - Spam content
- `inappropriate_content` - Inappropriate content

**ReportStatus**
- `pending` - Report submitted, awaiting review
- `reviewing` - Admin is reviewing the report
- `resolved` - Report resolved/action taken
- `rejected` - Report dismissed as invalid

**SuspensionStatus**
- `active` - Suspension currently in effect
- `lifted` - Suspension lifted early by admin
- `expired` - Suspension period ended naturally

---

## 📝 Validation Rules

### Age Validation
- **Pet Age (`ageMonths`)**: MUST be in months only. No years, no mixed units. This is strictly enforced by the integer type and model parsing logic.
  - Example: A 2-year-old pet should be stored as `24` months
  - The UI can display "2 years" but must store as `24` months

### Enum Validation
- All enum fields have default values if invalid data is encountered
- String values in Firestore must match enum values exactly (case-insensitive parsing)
- When creating/updating documents, use enum `.value` property to get the string representation

### Implementation Example
```dart
// Creating a pet with enums
Pet pet = Pet(
  category: PetCategory.dog,  // Enum type
  gender: Gender.male,         // Enum type
  ageMonths: 24,               // Integer (2 years)
  adoptionStatus: AdoptionStatus.available,  // Enum type
  // ... other fields
);

// Convert to Firestore document
Map<String, dynamic> data = pet.toMap();
// category becomes "Dog", gender becomes "Male", etc.

// Reading from Firestore
Pet petFromDb = Pet.fromFirestore(docSnapshot);
// String values parsed back to enums automatically
```

---