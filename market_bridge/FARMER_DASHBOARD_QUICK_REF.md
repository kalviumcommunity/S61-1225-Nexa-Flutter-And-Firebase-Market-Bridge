# Farmer Dashboard - Quick Reference Guide

## 🎯 Main Features at a Glance

### 📊 Dashboard Header
Shows real-time statistics:
- Active listings count
- Sold items count  
- Total inventory value (₹)
- Total views across all listings

### 🔍 Search & Filter Bar
| Feature | How to Use |
|---------|-----------|
| Search | Type crop name, instant filter |
| Clear Search | Click X button |
| Sort | Click "Sort" → Choose option |
| Status Filter | Click status chip → Select filter |
| Selection Mode | Click "Select" → Enable multi-select |

### 📋 Tab Navigation
- **Active**: Currently available for sale
- **Sold**: Completed transactions
- **Expired**: Old listings
- **All**: All listings combined

### 🎴 Listing Card Features
```
┌─────────────────────────────────┐
│ 🍅 Tomato         ✅ ACTIVE     │ ← Status badge
│ 50 Kg                            │
│ Jan 15, 2024                     │
├─────────────────────────────────┤
│ ₹250/Kg                          │
│ 👁 342 views  💬 12 inquiries    │
│ [Edit]  [⋮ More Options]         │
└─────────────────────────────────┘
```

### 💬 Long-Press Menu Options
Long-press on any listing card:

```
┌──────────────────────────────┐
│ 🍅 Tomato                     │
│ 50 Kg                         │
├──────────────────────────────┤
│ ✏️ Edit Listing              │
│ 👁 Mark Out of Stock (or ↔️) │
│ 🛍️ Mark as Sold             │
│ 📤 Share Listing             │
├──────────────────────────────┤
│ 🗑️ Delete Listing            │
└──────────────────────────────┘
```

### 🖱️ Three Dots Menu
Same options as long-press:
- Edit listing
- Toggle in-stock status
- Mark as sold
- Share listing
- Delete listing

### ✅ Bulk Selection Mode

1. Click "Select" filter chip
2. Checkboxes appear on cards
3. Tap checkboxes to select
4. FAB shows count: "3 selected"
5. Click FAB for bulk actions:
   - Mark as Sold
   - Delete Selected
6. Click X to exit selection mode

### 🗑️ Delete Behavior

**Before**: Items were permanently deleted  
**Now**: Items moved to "deleted" status (soft delete)

**Undo Process**:
```
User clicks Delete
↓
Confirmation dialog appears
↓
Click "Delete"
↓
SnackBar with "UNDO" button appears
↓
Tap "UNDO" within 4 seconds to restore
```

### 📤 Share Functionality

1. Long-press listing or click ⋮
2. Select "Share Listing"
3. Choose platform:
   - WhatsApp
   - Email
   - SMS
   - Messaging apps
   - Others (device-dependent)

**Share Format**:
```
"Check out this fresh [crop] for ₹[price] per [unit] 
on MarketBridge! 🌾"
```

### 🔄 Pull to Refresh

Swipe down on listing area to:
- Refresh data from Firebase
- Update statistics
- Show latest changes

### 🌐 Bottom Navigation

| Icon | Function |
|------|----------|
| 🏠 Home | Return to home screen |
| 🏪 Marketplace | Browse all marketplace listings |
| 👤 Dashboard | Current page (highlighted) |

## 🎨 Color Coding

| Status | Color | Meaning |
|--------|-------|---------|
| Active | 🟢 Green | Available for sale |
| Sold | 🔵 Blue | Transaction completed |
| Expired | 🟠 Orange | Listing expired |
| Deleted | 🔴 Red | Moved to trash |
| Out of Stock | 🟠 Orange | In-stock: false |

## 📱 Crop Emoji Icons

| Crop | Emoji | Crop | Emoji |
|------|-------|------|-------|
| Tomato | 🍅 | Wheat | 🌾 |
| Onion | 🧅 | Rice | 🌾 |
| Potato | 🥔 | Corn | 🌽 |
| Carrot | 🥕 | Cucumber | 🥒 |
| Cabbage | 🥬 | Pepper | 🌶️ |
| Broccoli | 🥦 | Apple | 🍎 |

## 🎯 Common Tasks

### How to Edit a Listing
1. Click "Edit" button on card, OR
2. Long-press → "Edit Listing", OR
3. Click ⋮ → "Edit Listing"
→ Navigates to edit screen

### How to Mark as Out of Stock
1. Long-press card OR click ⋮
2. Select "Mark Out of Stock"
3. Item shows "Out of Stock" badge
4. Still visible in marketplace with indicator

### How to Mark as Sold
1. Long-press OR click ⋮
2. Select "Mark as Sold"
3. Moves to "Sold" tab
4. Timestamp recorded

### How to Permanently Delete
1. Delete item (moves to deleted status)
2. OR: View in deleted tab
3. Then permanently remove (implement in future)

### How to Search
1. Focus on search bar
2. Type crop name
3. Results filter in real-time
4. Click X to clear

### How to Sort
1. Click "Sort" chip
2. Select option:
   - Recent (newest first)
   - Price: Low to High
   - Price: High to Low
   - Most Viewed
3. Results reorder instantly

## ⚙️ Settings & Preferences

Currently available:
- Search history (auto-clears on app restart)
- Sort preference (resets on navigation)
- Tab navigation (persists)
- Selection mode (auto-exits on action)

## 🔐 Data Privacy

- ✅ Your listings only visible to you
- ✅ Status changes private
- ✅ Delete undoable for 4 seconds
- ✅ Share only what you want
- ✅ Timestamps logged for tracking

## ⚡ Performance Tips

1. **Search first**: Find items before bulk actions
2. **Clear search**: Helps if results seem wrong
3. **Refresh**: Pull down if data seems stale
4. **Exit selection**: Faster list scrolling
5. **Reorder**: Sort by most relevant first

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| Items not showing | Pull to refresh |
| Search not working | Clear and try again |
| Undo button disappeared | Restore from deleted tab |
| Status not updating | Check connection, refresh |
| Image not loading | Item shows emoji instead |

## 📞 Need Help?

Check the main FARMER_DASHBOARD_FEATURES.md for:
- Detailed feature explanations
- Data structure information
- Future enhancement plans
- Testing checklists

---

**Pro Tip**: Most actions have multiple access points (button + menu). Choose what's fastest for you!
