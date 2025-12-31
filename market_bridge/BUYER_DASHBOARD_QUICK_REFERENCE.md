# Buyer Dashboard Quick Reference Guide

## 🚀 Quick Start

### File Location
```
lib/screens/buyer_dashboard_screen.dart
```

### Key Classes
- `BuyerDashboardScreen` - StatefulWidget
- `_BuyerDashboardScreenState` - State with SingleTickerProviderStateMixin

---

## 📋 State Variables Reference

| Variable | Type | Purpose |
|----------|------|---------|
| `_selectedIndex` | int | Bottom nav index |
| `_tabController` | TabController | Controls 3 tabs |
| `_searchQuery` | String | Current search text |
| `_sortBy` | String | Sort method (recent/oldest/price_low/price_high) |
| `_filterStatus` | String | Filter (all/delivered/pending) |
| `_selectedOrders` | Set<String> | IDs of selected orders |
| `_isSelectMode` | bool | Toggle selection mode |
| `_refreshKey` | GlobalKey | For pull-to-refresh |
| `favoriteListings` | List | Bookmarked items |
| `_loadingFavorites` | bool | Loading state for favorites |

---

## 🔧 Method Quick Reference

### Search & Filter Methods
```dart
_filterAndSortOrders()      // Apply all filters to orders
_toggleSelectMode()          // Turn selection mode on/off
_toggleOrderSelection()       // Select/deselect single order
```

### Display Methods
```dart
_buildHeader()               // Top stats cards
_buildSearchAndFilters()     // Search bar + chips
_buildOrdersTab()            // Tab content with orders
_buildBottomNav()            // Navigation bar
_buildOrderCard()            // Individual order card
```

### Menu Methods
```dart
_showSortMenu()              // Sort options dropdown
_showStatusFilterMenu()       // Status filter dropdown
_showBulkActionMenu()        // Bulk actions menu
_showAnalytics()             // Analytics dialog
```

### Action Methods
```dart
_shareOrder()                // Share single order
_showBulkShareDialog()       // Share multiple orders
_bulkMarkAsReviewed()        // Mark multiple as reviewed
_trackOrder()                // Show tracking dialog
_showReviewDialog()          // Review dialog
_refreshOrders()             // Pull-to-refresh handler
```

### Helper Methods
```dart
_getCropIcon()               // Emoji for crop type
_getStatusBgColor()          // Status background color
_getStatusTextColor()        // Status text color
_buildEmptyOrdersState()     // Empty state UI
_buildSelectableOrderCard()  // Card with checkbox
_buildAnalyticCard()         // Stat card widget
_buildNavItem()              // Bottom nav item
```

---

## 📊 Search & Filter Flow

```
User Input (Search/Filter/Sort)
         ↓
setState() updates variables
         ↓
StreamBuilder rebuilds
         ↓
Query from Firestore
         ↓
_filterAndSortOrders() processes
         ↓
ListView.builder renders
```

---

## 🎨 Color Palette

```dart
// Primary
const Color(0xFF2196F3)  // Blue - main theme

// Status Colors
Colors.blue[700]         // Delivered
Colors.orange[700]       // Pending
Colors.green[700]        // Confirmed

// Backgrounds
const Color(0xFFF5F5F5)  // Light gray
Colors.white             // Cards

// With opacity
Color.withOpacity(0.1)   // Light backgrounds
Color.withOpacity(0.2)   // Slightly darker
Color.withOpacity(0.05)  // Very light
```

---

## 📱 Responsive Breakpoint

```dart
bool isTablet = MediaQuery.of(context).size.width > 600;

// Used for:
if (isTablet) {
  padding = 24;
} else {
  padding = 16;
}
```

---

## 🔄 Firebase Queries

### Get all orders for user
```dart
FirebaseFirestore.instance
  .collection('orders')
  .where('buyerId', isEqualTo: user.uid)
  .orderBy('createdAt', descending: true)
  .snapshots()
```

### Filter by status
```dart
.where('status', isEqualTo: 'delivered')
```

### Batch operations
```dart
final batch = FirebaseFirestore.instance.batch();
for (String docId in _selectedOrders) {
  batch.update(
    FirebaseFirestore.instance.collection('orders').doc(docId),
    {'reviewed': true}
  );
}
await batch.commit();
```

---

## 🎯 Common Tasks

### Add New Sort Option
```dart
case 'my_sort':
  orders.sort((a, b) => /* your logic */);
  break;
```

### Add New Status Filter
```dart
else if (filter == 'my_status') {
  query = query.where('status', isEqualTo: 'my_status');
}
```

### Add Analytics Metric
```dart
// In _showAnalytics()
int newMetric = 0;
for (var doc in snapshot.docs) {
  final data = doc.data();
  newMetric += /* calculate */;
}

_buildAnalyticCard('Label', '$newMetric', Icons.icon, Colors.color)
```

### Add New Action Button
```dart
ElevatedButton(
  onPressed: () => _actionMethod(),
  child: const Text('Action'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2196F3),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
  ),
)
```

---

## 🐛 Debugging Tips

### Check current filter state
```dart
print('Search: $_searchQuery');
print('Sort: $_sortBy');
print('Status: $_filterStatus');
print('Selected: ${_selectedOrders.length}');
```

### Verify Firebase connection
```dart
FirebaseFirestore.instance
  .collection('orders')
  .doc('test')
  .get()
  .then((snap) => print('Connected: ${snap.exists}'));
```

### Check tab index
```dart
print('Current tab: ${_tabController.index}');
```

### Monitor selection mode
```dart
print('Select mode: $_isSelectMode');
print('Selected count: ${_selectedOrders.length}');
```

---

## ⚡ Performance Tips

1. **Use const constructors** when possible
2. **Avoid rebuilds** with proper key management
3. **Use ListView.builder** for large lists (already done)
4. **Cache expensive operations** like _filterAndSortOrders()
5. **Lazy load images** if you add product images
6. **Dispose** resources in dispose() method (already done)

---

## 📝 Code Style

```dart
// Variable naming
String _privateVar = '';        // Private with underscore
int publicVar = 0;              // Public without underscore

// Method naming
void _privateMethod() {}         // Private with underscore
Widget _buildWidget() {}         // Build methods with _build prefix

// Constants
const Color _primaryColor = Color(0xFF2196F3);
const double _padding = 16.0;

// Comments
// Single line comment
/// Documentation comment for public API

// Formatting
List<String> items = [          // Multi-line with proper indentation
  'item1',
  'item2',
  'item3',
];
```

---

## 🔗 Related Files

| File | Purpose |
|------|---------|
| `buyer_marketplace_screen.dart` | Browse products |
| `buyer_order_history_screen.dart` | Full order history |
| `buyer_profile_screen.dart` | User profile |
| `routes.dart` | Navigation routing |
| `firebase_options.dart` | Firebase config |

---

## 📚 Key Dart/Flutter Concepts Used

| Concept | Usage |
|---------|-------|
| `StreamBuilder` | Real-time Firebase data |
| `TabController` | Tab navigation |
| `RefreshIndicator` | Pull-to-refresh |
| `ModalBottomSheet` | Dropdown menus |
| `AlertDialog` | Confirmation dialogs |
| `ListView.builder` | Efficient list rendering |
| `SingleTickerProviderStateMixin` | Tab animation provider |
| `setState()` | Trigger UI updates |
| `Navigator` | Screen navigation |

---

## ✅ Testing Checklist

```
[ ] Search works for products
[ ] Search works for farmers
[ ] Filter updates list correctly
[ ] Sort options apply correctly
[ ] Selection mode toggles
[ ] Bulk share works
[ ] Bulk mark reviewed works
[ ] Analytics display correct data
[ ] Pull-to-refresh works
[ ] Tab switching smooth
[ ] Empty states appear
[ ] Orders display correctly
[ ] Track button works
[ ] Review dialog works
[ ] Navigation works
[ ] Colors consistent
[ ] Responsive on tablet
[ ] No console errors
```

---

## 🚨 Common Issues & Solutions

### Tab index out of bounds
**Issue**: `RangeError when accessing _tabController`
**Solution**: Ensure TabController length matches tab count
```dart
_tabController = TabController(length: 3, vsync: this);  // Must be 3
```

### Search not filtering
**Issue**: Search term doesn't filter orders
**Solution**: Check _filterAndSortOrders() is called in build
```dart
final filtered = _filterAndSortOrders(snap.data!.docs);
```

### Favorites not loading
**Issue**: Favorites list empty
**Solution**: Check SharedPreferences key name
```dart
final favNames = prefs.getStringList('buyer_favorites') ?? [];
```

### Orders not updating
**Issue**: New orders don't appear
**Solution**: Verify buyerId query filter is correct
```dart
.where('buyerId', isEqualTo: user.uid)
```

### Selection mode stuck
**Issue**: Can't exit selection mode
**Solution**: Call _toggleSelectMode() or clear selection
```dart
_selectedOrders.clear();
setState(() => _isSelectMode = false);
```

---

## 💡 Optimization Ideas

1. Add order search caching
2. Implement pagination for large order lists
3. Add local notification for order updates
4. Cache analytics calculations
5. Add order filtering by date range
6. Implement order status notifications
7. Add order export (PDF, CSV)
8. Implement smart order recommendations

---

## 📞 Support References

- [Flutter TabBar Documentation](https://api.flutter.dev/flutter/material/TabBar-class.html)
- [Firebase Firestore Documentation](https://firebase.flutter.dev/docs/firestore/overview)
- [StreamBuilder Pattern](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)
- [Flutter UI Patterns](https://flutter.dev/docs/development/ui/widgets-intro)
