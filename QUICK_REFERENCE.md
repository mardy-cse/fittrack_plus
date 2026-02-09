# FitTrack+ Quick Reference Guide

## 🚀 Quick Start Tasks

### Adding a New Feature

1. **Create Model** (if needed)
   ```dart
   // lib/app/models/my_feature.dart
   class MyFeature {
     final String id;
     final String name;
     // ... fields
     
     MyFeature({required this.id, required this.name});
     
     Map<String, dynamic> toMap() { ... }
     factory MyFeature.fromDocument(DocumentSnapshot doc) { ... }
   }
   ```

2. **Create Service**
   ```dart
   // lib/app/services/my_feature_service.dart
   class MyFeatureService extends GetxService {
     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
     
     Future<void> saveData() async { ... }
     Stream<List<MyFeature>> watchData() { ... }
   }
   ```

3. **Create Controller**
   ```dart
   // lib/app/controllers/my_feature_controller.dart
   class MyFeatureController extends GetxController {
     final MyFeatureService _service = Get.find();
     final RxList<MyFeature> items = <MyFeature>[].obs;
     
     @override
     void onInit() {
       super.onInit();
       loadData();
     }
   }
   ```

4. **Create Binding**
   ```dart
   // lib/app/bindings/my_feature_binding.dart
   class MyFeatureBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<MyFeatureController>(() => MyFeatureController());
     }
   }
   ```

5. **Create View**
   ```dart
   // lib/app/views/my_feature/my_feature_view.dart
   class MyFeatureView extends GetView<MyFeatureController> {
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         body: Obx(() => ListView(...)),
       );
     }
   }
   ```

6. **Add Route**
   ```dart
   // lib/app/routes/app_pages.dart
   GetPage(
     name: '/my-feature',
     page: () => MyFeatureView(),
     binding: MyFeatureBinding(),
   ),
   ```

---

## 🔧 Common Code Patterns

### 1. Observable State with GetX
```dart
// Controller
final RxInt counter = 0.obs;
final RxBool isLoading = false.obs;
final RxList<Item> items = <Item>[].obs;
final Rx<User?> user = Rx<User?>(null);

// View
Obx(() => Text('${controller.counter.value}'))
Obx(() => controller.isLoading.value ? Loading() : Content())
```

### 2. Firestore CRUD Operations

**Create:**
```dart
Future<String?> createItem(Item item) async {
  try {
    final docRef = await _firestore
      .collection('items')
      .add(item.toMap());
    return docRef.id;
  } catch (e) {
    debugPrint('Error: $e');
    return null;
  }
}
```

**Read (One-time):**
```dart
Future<List<Item>> getItems(String userId) async {
  try {
    final snapshot = await _firestore
      .collection('items')
      .where('userId', isEqualTo: userId)
      .get();
    
    return snapshot.docs
      .map((doc) => Item.fromDocument(doc))
      .toList();
  } catch (e) {
    return [];
  }
}
```

**Read (Real-time):**
```dart
Stream<List<Item>> watchItems(String userId) {
  return _firestore
    .collection('items')
    .where('userId', isEqualTo: userId)
    .snapshots()
    .map((snapshot) {
      return snapshot.docs
        .map((doc) => Item.fromDocument(doc))
        .toList();
    });
}
```

**Update:**
```dart
Future<bool> updateItem(String id, Map<String, dynamic> data) async {
  try {
    await _firestore
      .collection('items')
      .doc(id)
      .set(data, SetOptions(merge: true));
    return true;
  } catch (e) {
    return false;
  }
}
```

**Delete:**
```dart
Future<bool> deleteItem(String id) async {
  try {
    await _firestore.collection('items').doc(id).delete();
    return true;
  } catch (e) {
    return false;
  }
}
```

### 3. Navigation Patterns

**Navigate to new screen:**
```dart
Get.toNamed('/workout-detail', arguments: workout);
```

**Navigate and replace:**
```dart
Get.offNamed('/home');
```

**Navigate and remove all previous:**
```dart
Get.offAllNamed('/login');
```

**Go back:**
```dart
Get.back();
```

**Get arguments:**
```dart
final workout = Get.arguments as Workout;
```

### 4. Loading States

```dart
// Controller
final RxBool isLoading = false.obs;

Future<void> loadData() async {
  try {
    isLoading.value = true;
    // ... load data
  } catch (e) {
    // ... handle error
  } finally {
    isLoading.value = false;
  }
}

// View
Obx(() {
  if (controller.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }
  return ListView(...);
})
```

### 5. Error Handling

```dart
try {
  await someOperation();
  Get.snackbar(
    'Success',
    'Operation completed',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
  );
} catch (e) {
  Get.snackbar(
    'Error',
    'Something went wrong: $e',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
  );
}
```

---

## 📝 Firestore Data Modeling Best Practices

### 1. Always Include These Fields
```dart
class MyModel {
  final String id;              // Document ID
  final DateTime createdAt;     // Timestamp
  final String userId;          // Owner reference
  
  MyModel({
    required this.id,
    DateTime? createdAt,
    required this.userId,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      // ... other fields
    };
  }
  
  factory MyModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MyModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
```

### 2. Use Timestamps
```dart
// Save
'createdAt': Timestamp.fromDate(DateTime.now())

// Read
createdAt: (data['createdAt'] as Timestamp).toDate()
```

### 3. Handle Null Values
```dart
name: data['name'] ?? '',
age: data['age'] ?? 0,
isActive: data['isActive'] ?? false,
items: List<String>.from(data['items'] ?? []),
```

---

## 🎨 UI Patterns

### 1. Responsive Card
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: isDark ? Color(0xFF1C1C1E) : Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: isDark ? [] : [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ...,
)
```

### 2. Stats Card Pattern
```dart
Widget _buildStatCard(String label, String value, IconData icon, Color color) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}
```

### 3. Loading Overlay
```dart
Stack(
  children: [
    // Main content
    YourContent(),
    
    // Loading overlay
    if (controller.isLoading.value)
      Container(
        color: Colors.black54,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
  ],
)
```

---

## 🐛 Debugging Checklist

### When a feature is not working:

- [ ] Check console for errors
- [ ] Verify Firebase connection (internet)
- [ ] Check Firestore rules
- [ ] Verify user is authenticated
- [ ] Check controller is initialized (binding)
- [ ] Verify observable is wrapped in Obx()
- [ ] Check for typos in collection names
- [ ] Verify data model matches Firestore structure
- [ ] Check null safety
- [ ] Look for try-catch blocks catching errors silently

### Common GetX Issues:

**Controller not found:**
```dart
// Solution: Add to binding
Get.lazyPut<MyController>(() => MyController());
```

**UI not updating:**
```dart
// Solution: Wrap in Obx() and use .value
Obx(() => Text('${controller.count.value}'))
```

**Service not initialized:**
```dart
// Solution: Initialize in main.dart
await Get.putAsync(() => MyService().init());
```

---

## 📊 Performance Tips

### 1. Use lazyPut for Controllers
```dart
// Good - only creates when needed
Get.lazyPut<MyController>(() => MyController());

// Bad - creates immediately
Get.put(MyController());
```

### 2. Dispose Streams Properly
```dart
StreamSubscription? _subscription;

@override
void onInit() {
  _subscription = stream.listen(...);
}

@override
void onClose() {
  _subscription?.cancel();
  super.onClose();
}
```

### 3. Optimize Firestore Queries
```dart
// Good - filter on server
.where('userId', isEqualTo: userId)

// Bad - loads all then filters
.get().then((snapshot) => filter locally)
```

### 4. Cache Data When Appropriate
```dart
final RxList<Item> _cachedItems = <Item>[].obs;
DateTime? _lastFetch;

Future<void> loadItems({bool forceRefresh = false}) async {
  if (!forceRefresh && 
      _cachedItems.isNotEmpty && 
      _lastFetch != null &&
      DateTime.now().difference(_lastFetch!) < Duration(minutes: 5)) {
    return; // Use cached data
  }
  
  // Fetch fresh data
  _cachedItems.value = await _service.getItems();
  _lastFetch = DateTime.now();
}
```

---

## 🔐 Security Best Practices

### 1. Never Hardcode Sensitive Data
```dart
// Bad
const apiKey = 'AIza...';

// Good - use environment variables or Firebase config
final apiKey = FirebaseOptions.currentPlatform.apiKey;
```

### 2. Validate Input
```dart
Future<void> saveData(String input) async {
  if (input.trim().isEmpty) {
    throw Exception('Input cannot be empty');
  }
  
  if (input.length > 100) {
    throw Exception('Input too long');
  }
  
  // Sanitize
  final sanitized = input.trim();
  // ... save
}
```

### 3. Use Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /workout_sessions/{sessionId} {
      allow read, write: if request.auth != null 
                       && request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## 📱 Testing Workflow

### Manual Testing Checklist:

**New Feature:**
- [ ] Happy path works
- [ ] Edge cases handled
- [ ] Error states shown properly
- [ ] Loading states work
- [ ] Navigation flows correctly
- [ ] Works on Android
- [ ] Works on iOS
- [ ] Works on Web (if applicable)
- [ ] Dark mode looks good
- [ ] Light mode looks good

**Before Release:**
- [ ] No console errors
- [ ] All features tested
- [ ] Authentication flow works
- [ ] Data persists correctly
- [ ] Logout and login works
- [ ] New user onboarding works
- [ ] Performance is acceptable

---

## 🚀 Deployment Checklist

### Before Deploying:

- [ ] Update version in pubspec.yaml
- [ ] Test on physical devices
- [ ] Check Firestore indexes created
- [ ] Verify Firebase security rules
- [ ] Update documentation
- [ ] Check error handling everywhere
- [ ] Remove debug prints (or use kDebugMode)
- [ ] Build release version
- [ ] Test release build

### Build Commands:

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## 📚 Useful Resources

### FitTrack+ Specific:
- Main Documentation: `APP_WORKFLOW_DOCUMENTATION.md`
- Bangla Documentation: `APP_WORKFLOW_DOCUMENTATION_BN.md`
- Project Status: `PROJECT_STATUS.md`
- Setup Guide: `SETUP_GUIDE.md`

### External Resources:
- GetX Documentation: https://pub.dev/packages/get
- Firebase Flutter: https://firebase.flutter.dev/
- Flutter Documentation: https://flutter.dev/docs
- Dart Language: https://dart.dev/guides

---

**Last Updated**: February 9, 2026
