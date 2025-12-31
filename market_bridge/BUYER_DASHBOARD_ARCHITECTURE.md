# Buyer Dashboard - Visual Architecture & Flows

## 🏗️ Screen Architecture

```
┌─────────────────────────────────────────┐
│         BUYER DASHBOARD SCREEN          │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐   │
│  │      HEADER SECTION              │   │
│  │  ┌──────────────────────────────┐│   │
│  │  │ Nav: Back | Analytics | Bell ││   │
│  │  └──────────────────────────────┘│   │
│  │  ┌────────────────────────────────┐  │
│  │  │ Stats Grid (2x2)               │  │
│  │  │ ┌─────────┬──────────┐         │  │
│  │  │ │ Pending │Delivered│         │  │
│  │  │ ├─────────┼──────────┤         │  │
│  │  │ │  Spent  │Favorites│         │  │
│  │  │ └─────────┴──────────┘         │  │
│  │  └────────────────────────────────┘  │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │   SEARCH & FILTER SECTION        │   │
│  │  ┌──────────────────────────────┐│   │
│  │  │ Search [___________] X       ││   │
│  │  └──────────────────────────────┘│   │
│  │  ┌────────────────────────────────┐  │
│  │  │ [Sort ▼] [Status ▼] [Select] │  │
│  │  └────────────────────────────────┘  │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │      TAB BAR                     │   │
│  │  ┌──────┬───────────┬─────────┐  │   │
│  │  │ All  │ Delivered │ Pending │  │   │
│  │  └──────┴───────────┴─────────┘  │   │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │    TAB VIEW CONTENT              │   │
│  │  ┌──────────────────────────────┐│   │
│  │  │ ┌────────────────────────┐   ││   │
│  │  │ │ 🥕 Tomato              │   ││   │
│  │  │ │ Qty: 2kg | Price: ₹200│   ││   │
│  │  │ │ From: Farmer | Today   │   ││   │
│  │  │ │ [Track] [Review]       │   ││   │
│  │  │ └────────────────────────┘   ││   │
│  │  │ ┌────────────────────────┐   ││   │
│  │  │ │ 🧅 Onion               │   ││   │
│  │  │ │ Qty: 5kg | Price: ₹120│   ││   │
│  │  │ │ From: Farmer | 2d ago  │   ││   │
│  │  │ │ [Track] [Review]       │   ││   │
│  │  │ └────────────────────────┘   ││   │
│  │  └──────────────────────────────┘│   │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │    BOTTOM NAVIGATION             │   │
│  │  [Home] [Marketplace] [Dashboard]│   │
│  └──────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📊 State Management Flow

```
                    ┌──────────────────┐
                    │  initState()     │
                    │ Initialize vars  │
                    │ Load favorites   │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │ _searchQuery = ''│
                    │ _sortBy = latest │
                    │ _filterStatus=all│
                    │ _selectedOrders=[]
                    │ _isSelectMode=false
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────────┐
                    │   User Input        │
                    │  (Search/Filter)    │
                    └────────┬────────────┘
                             │
                    ┌────────▼────────────────┐
                    │  setState() called      │
                    │  Update state variable  │
                    └────────┬────────────────┘
                             │
                    ┌────────▼────────────────────┐
                    │  StreamBuilder triggered    │
                    │  Fetch from Firebase        │
                    └────────┬────────────────────┘
                             │
                    ┌────────▼──────────────────────┐
                    │ _filterAndSortOrders()        │
                    │  - Apply search              │
                    │  - Apply filter              │
                    │  - Apply sort                │
                    └────────┬──────────────────────┘
                             │
                    ┌────────▼──────────────────────┐
                    │  ListView.builder renders    │
                    │  Display filtered orders     │
                    └──────────────────────────────┘
```

---

## 🔄 Filter & Sort Logic Flow

```
                    ┌──────────────────────┐
                    │ _filterAndSortOrders │
                    │ (QueryDocs)          │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼──────────┐
                    │ Search Filter:      │
                    │ crop.contains() ||  │
                    │ farmer.contains()   │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────────┐
                    │ Status Filter:          │
                    │ status == _filterStatus │
                    └──────────┬──────────────┘
                               │
                    ┌──────────▼──────────┐
                    │ Sorting Logic:      │
                    │                     │
                    │ ├─ recent           │
                    │ ├─ oldest           │
                    │ ├─ price_low        │
                    │ └─ price_high       │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────────┐
                    │ Return Sorted List      │
                    │ of filtered orders      │
                    └──────────────────────────┘
```

---

## 🎨 UI Component Hierarchy

```
BuyerDashboardScreen (Scaffold)
│
├─ Body: SafeArea
│  │
│  ├─ Column
│  │  ├─ _buildHeader()
│  │  │  ├─ Row (nav buttons)
│  │  │  └─ StreamBuilder
│  │  │     └─ Row of StatCards
│  │  │        ├─ StatCard (Pending)
│  │  │        ├─ StatCard (Delivered)
│  │  │        ├─ StatCard (Spent)
│  │  │        └─ StatCard (Favorites)
│  │  │
│  │  └─ Container (rounded background)
│  │     ├─ _buildSearchAndFilters()
│  │     │  ├─ TextField (search)
│  │     │  ├─ Row of FilterChips
│  │     │  │  ├─ Sort chip
│  │     │  │  ├─ Status chip
│  │     │  │  └─ Select chip
│  │     │  │
│  │     │  └─ TabBar
│  │     │     ├─ Tab: All Orders
│  │     │     ├─ Tab: Delivered
│  │     │     └─ Tab: Pending
│  │     │
│  │     └─ TabBarView
│  │        ├─ _buildOrdersTab('all')
│  │        ├─ _buildOrdersTab('delivered')
│  │        └─ _buildOrdersTab('pending')
│  │           │
│  │           └─ RefreshIndicator
│  │              └─ StreamBuilder
│  │                 └─ ListView.builder
│  │                    └─ _buildOrderCard() OR
│  │                       _buildSelectableOrderCard()
│  │
│  └─ _buildBottomNav()
│     ├─ NavItem (Home)
│     ├─ NavItem (Marketplace)
│     └─ NavItem (Dashboard)
│
└─ FloatingActionButton
   └─ Shows only when _isSelectMode = true
```

---

## 🔀 User Interaction Flows

### 1. Search Flow
```
User types in search field
        │
        ▼
onChanged: (value) => setState(...)
        │
        ▼
_searchQuery = value
        │
        ▼
StreamBuilder rebuilds
        │
        ▼
_filterAndSortOrders() applies search
        │
        ▼
Orders matching search appear
```

### 2. Selection Flow
```
User taps Select chip
        │
        ▼
_toggleSelectMode()
        │
        ▼
_isSelectMode = !_isSelectMode
        │
        ▼
setState() triggers rebuild
        │
        ▼
Order cards show checkboxes
        │
        ▼
User taps orders to select
        │
        ▼
_toggleOrderSelection(id)
        │
        ▼
_selectedOrders updated
        │
        ▼
FAB shows count
```

### 3. Bulk Share Flow
```
User selects multiple orders
        │
        ▼
Taps FAB with count
        │
        ▼
_showBulkActionMenu()
        │
        ▼
User chooses Share
        │
        ▼
_showBulkShareDialog()
        │
        ▼
Share sheet opens
        │
        ▼
User shares
        │
        ▼
Selection cleared
        │
        ▼
Mode exits
```

---

## 📈 Analytics Flow

```
User taps analytics button
        │
        ▼
_showAnalytics(user)
        │
        ▼
Fetch all orders from Firebase
        │
        ▼
Calculate metrics:
├─ totalOrders count
├─ deliveredOrders count
├─ pendingOrders count
├─ totalSpent sum
└─ topFarmers frequency
        │
        ▼
Sort top farmers by frequency
        │
        ▼
Display analytics dialog with:
├─ 4 stat cards
├─ Total spent card
└─ Top 3 farmers list
```

---

## 🔄 Pull-to-Refresh Flow

```
User pulls down on list
        │
        ▼
RefreshIndicator triggers
        │
        ▼
_refreshOrders() called
        │
        ▼
500ms delay (smoothness)
        │
        ▼
setState() triggers
        │
        ▼
StreamBuilder refreshes
        │
        ▼
New orders fetched
        │
        ▼
List updates
        │
        ▼
Refresh animation completes
```

---

## 🎯 Tab Navigation Flow

```
User swipes or taps tab
        │
        ▼
TabBar index changes
        │
        ▼
_tabController.index updated
        │
        ▼
TabBarView slides to new view
        │
        ▼
_buildOrdersTab() called with
new filter parameter:
├─ 'all'
├─ 'delivered'
└─ 'pending'
        │
        ▼
Query filtered by status
        │
        ▼
Different orders displayed
```

---

## 🎨 Color Usage Map

```
┌─────────────────────────────────────┐
│        BUYER DASHBOARD COLORS       │
├─────────────────────────────────────┤
│                                     │
│ BACKGROUNDS:                        │
│ ┌─────────────────────────────────┐│
│ │ Body: #2196F3 (Blue)           ││
│ │ Container: #F5F5F5 (Gray)      ││
│ │ Cards: White                   ││
│ │ Overlays: White with opacity   ││
│ └─────────────────────────────────┘│
│                                     │
│ TEXT:                               │
│ ┌─────────────────────────────────┐│
│ │ Headers: Dark/White            ││
│ │ Body: #333333 (Dark)           ││
│ │ Subtle: #666666 (Gray)         ││
│ │ Disabled: #999999 (Light Gray) ││
│ └─────────────────────────────────┘│
│                                     │
│ STATUS BADGES:                      │
│ ┌─────────────────────────────────┐│
│ │ Delivered: Blue (#2196F3)      ││
│ │ Pending: Orange                ││
│ │ Confirmed: Green               ││
│ └─────────────────────────────────┘│
│                                     │
│ INTERACTIVE:                        │
│ ┌─────────────────────────────────┐│
│ │ Primary Button: Blue           ││
│ │ Active Tab: Blue               ││
│ │ Active Nav: Blue               ││
│ │ Icons: Blue or Gray            ││
│ └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

---

## 📱 Responsive Breakpoints

```
Mobile (< 600px)
┌─────────────────────────┐
│ 16px padding/margins    │
│ Single column layouts   │
│ Full-width cards        │
│ Smaller text            │
│ Compact spacing         │
└─────────────────────────┘

         │
         │ width > 600px
         ▼

Tablet (≥ 600px)
┌─────────────────────────┐
│ 24px padding/margins    │
│ Multiple columns where  │
│ Max-width constraints   │
│ Larger text             │
│ More spacing            │
└─────────────────────────┘
```

---

## 🔗 Navigation Graph

```
BuyerDashboardScreen
│
├─ Back → Home
├─ Analytics → Analytics Dialog
├─ Notifications → (Future)
│
├─ Bottom Nav:
│  ├─ Home → Pop
│  ├─ Marketplace → Push BuyerMarketplaceScreen
│  └─ Dashboard → Current
│
├─ Order Card:
│  ├─ Track → Track Dialog
│  └─ Review → Review Dialog
│
└─ Search:
   ├─ Sort → Sort Menu
   ├─ Status → Filter Menu
   └─ Select → Bulk Actions Menu
```

---

## 📊 Data Transformation Pipeline

```
Raw Firebase Data
        │
        ▼
┌──────────────────────────────┐
│ Convert to Map<String, dynamic>
│ {                            │
│   'id': docId,              │
│   'crop': ...,              │
│   'quantity': ...,          │
│   'price': ...,             │
│   'farmer': ...,            │
│   'status': ...,            │
│   'createdAt': ...          │
│ }                            │
└──────────────────────────────┘
        │
        ▼
Apply Search Filter
(crop.contains() || farmer.contains())
        │
        ▼
Apply Status Filter
(status == filterStatus)
        │
        ▼
Apply Sort
(recent/oldest/price_low/price_high)
        │
        ▼
Return List<Map<String, dynamic>>
        │
        ▼
ListView.builder renders cards
        │
        ▼
Display to user
```

---

## 🧩 State Variable Dependencies

```
_searchQuery
    └─ Affects: _filterAndSortOrders()
       └─ Affects: List display

_sortBy
    └─ Affects: _filterAndSortOrders()
       └─ Affects: List order

_filterStatus
    └─ Affects: _filterAndSortOrders()
       └─ Affects: Query + List

_isSelectMode
    └─ Affects: Card appearance
       └─ Affects: FAB visibility

_selectedOrders
    └─ Requires: _isSelectMode = true
       └─ Affects: Bulk actions available

_tabController.index
    └─ Affects: _buildOrdersTab() filter
       └─ Affects: Orders displayed
```

---

## 🎯 Key Metrics Calculation

```
Analytics Dialog Metrics:

Total Orders
└─ snapshot.docs.length

Delivered Orders
└─ Count where status == 'delivered'

Pending Orders
└─ Count where status == 'pending'

Total Spent
└─ Sum of all totalAmount

Top Farmers
└─ Group by farmer name
   └─ Count frequency
   └─ Sort descending
   └─ Take top 3
```

---

## ✅ Quality Assurance Checklist

```
FUNCTIONALITY
  ☑ Search filters correctly
  ☑ Sort options apply
  ☑ Selection mode works
  ☑ Bulk actions complete
  ☑ Analytics calculate right
  ☑ Refresh updates data
  ☑ Tabs switch smoothly
  ☑ Navigation works

PERFORMANCE
  ☑ No unnecessary rebuilds
  ☑ Efficient list rendering
  ☑ Smooth animations
  ☑ No memory leaks
  ☑ Fast filtering

UI/UX
  ☑ Colors consistent
  ☑ Text readable
  ☑ Buttons clickable
  ☑ Icons clear
  ☑ Responsive layout
  ☑ Empty states shown
  ☑ Loading states clear

INTEGRATION
  ☑ Firebase queries work
  ☑ Real-time updates work
  ☑ User auth respected
  ☑ Error handling good
  ☑ Navigation correct
```
