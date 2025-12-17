// lib/screens/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({Key? key}) : super(key: key);

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and device info
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Determine device type
    final isMobile = screenWidth < _mobileBreakpoint;
    final isTablet =
        screenWidth >= _mobileBreakpoint && screenWidth < _tabletBreakpoint;
    final isDesktop = screenWidth >= _tabletBreakpoint;
    final isLandscape = orientation == Orientation.landscape;

    // Responsive values
    final horizontalPadding = _getHorizontalPadding(screenWidth);
    final verticalSpacing = _getVerticalSpacing(screenWidth);
    final headerHeight = _getHeaderHeight(screenWidth, isLandscape);
    final panelMinHeight = _getPanelMinHeight(
      screenWidth,
      screenHeight,
      isLandscape,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Responsive Layout',
          style: TextStyle(fontSize: _getAppBarFontSize(screenWidth)),
        ),
        centerTitle: true,
        elevation: isMobile ? 2 : 4,
        toolbarHeight: isDesktop ? 64 : 56,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (horizontalPadding * 2),
                  // Max width for desktop to prevent excessive stretching
                  maxWidth: isDesktop ? 1400 : double.infinity,
                ),
                child: Center(
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Responsive Header
                        _buildHeader(
                          context,
                          screenWidth: screenWidth,
                          height: headerHeight,
                          isMobile: isMobile,
                          isTablet: isTablet,
                          isDesktop: isDesktop,
                        ),

                        SizedBox(height: verticalSpacing),

                        // Adaptive Body Layout
                        _buildBodyContent(
                          context,
                          screenWidth: screenWidth,
                          isMobile: isMobile,
                          isTablet: isTablet,
                          isDesktop: isDesktop,
                          panelMinHeight: panelMinHeight,
                          spacing: verticalSpacing * 0.75,
                        ),

                        SizedBox(height: verticalSpacing),

                        // Info Footer
                        _buildInfoFooter(
                          context,
                          screenWidth: screenWidth,
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper: Calculate horizontal padding based on screen width
  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) return 16.0;
    if (screenWidth < _tabletBreakpoint) return 24.0;
    if (screenWidth < _desktopBreakpoint) return 32.0;
    return 48.0;
  }

  // Helper: Calculate vertical spacing
  double _getVerticalSpacing(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) return 16.0;
    if (screenWidth < _tabletBreakpoint) return 20.0;
    return 24.0;
  }

  // Helper: Calculate header height
  double _getHeaderHeight(double screenWidth, bool isLandscape) {
    if (isLandscape && screenWidth < _mobileBreakpoint) return 100.0;
    if (screenWidth < _mobileBreakpoint) return 120.0;
    if (screenWidth < _tabletBreakpoint) return 160.0;
    return 200.0;
  }

  // Helper: Calculate panel minimum height
  double _getPanelMinHeight(
    double screenWidth,
    double screenHeight,
    bool isLandscape,
  ) {
    if (isLandscape) return screenHeight * 0.4;
    if (screenWidth < _mobileBreakpoint) return 280.0;
    if (screenWidth < _tabletBreakpoint) return 320.0;
    return 360.0;
  }

  // Helper: AppBar font size
  double _getAppBarFontSize(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) return 18.0;
    if (screenWidth < _tabletBreakpoint) return 20.0;
    return 22.0;
  }

  // Build responsive header
  Widget _buildHeader(
    BuildContext context, {
    required double screenWidth,
    required double height,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final titleFontSize = isMobile ? 20.0 : (isTablet ? 26.0 : 32.0);
    final subtitleFontSize = isMobile ? 13.0 : (isTablet ? 15.0 : 18.0);
    final borderRadius = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: isDesktop ? 20 : 12,
            offset: Offset(0, isDesktop ? 8 : 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Responsive Header',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Flexible(
            child: Text(
              'This header adapts its height, padding, and text size based on screen width. '
              'Current breakpoint: ${isMobile ? "Mobile" : (isTablet ? "Tablet" : "Desktop")}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: subtitleFontSize,
                color: Colors.white.withOpacity(0.95),
              ),
              maxLines: isDesktop ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChip('Width: ${screenWidth.toInt()}px'),
                const SizedBox(width: 8),
                _buildChip('Desktop Mode'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Build body content with adaptive layout
  Widget _buildBodyContent(
    BuildContext context, {
    required double screenWidth,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required double panelMinHeight,
    required double spacing,
  }) {
    // Mobile: Single column
    if (isMobile) {
      return Column(
        children: [
          _buildPanel(
            context,
            title: 'Main Content',
            subtitle: 'Single column layout optimized for mobile devices.',
            minHeight: panelMinHeight,
            screenWidth: screenWidth,
            isMobile: isMobile,
          ),
          SizedBox(height: spacing),
          _buildPanel(
            context,
            title: 'Secondary Content',
            subtitle: 'Additional information stacked below main content.',
            minHeight: panelMinHeight * 0.6,
            screenWidth: screenWidth,
            isMobile: isMobile,
          ),
        ],
      );
    }

    // Tablet: Two columns equal width
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildPanel(
              context,
              title: 'Left Panel',
              subtitle: 'Primary content panel with equal width distribution.',
              minHeight: panelMinHeight,
              screenWidth: screenWidth,
              isMobile: false,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: _buildPanel(
              context,
              title: 'Right Panel',
              subtitle: 'Secondary panel for complementary information.',
              minHeight: panelMinHeight,
              screenWidth: screenWidth,
              isMobile: false,
            ),
          ),
        ],
      );
    }

    // Desktop: Three columns (2:1:1 ratio)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildPanel(
            context,
            title: 'Main Panel',
            subtitle: 'Primary content takes up 50% of space on desktop.',
            minHeight: panelMinHeight,
            screenWidth: screenWidth,
            isMobile: false,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          flex: 1,
          child: _buildPanel(
            context,
            title: 'Side Panel 1',
            subtitle: 'Supporting content in 25% width column.',
            minHeight: panelMinHeight,
            screenWidth: screenWidth,
            isMobile: false,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          flex: 1,
          child: _buildPanel(
            context,
            title: 'Side Panel 2',
            subtitle: 'Additional actions or details.',
            minHeight: panelMinHeight,
            screenWidth: screenWidth,
            isMobile: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double minHeight,
    required double screenWidth,
    required bool isMobile,
  }) {
    final borderRadius = isMobile ? 10.0 : 14.0;
    final padding = isMobile ? 14.0 : 18.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: isMobile ? 8 : 12,
            offset: Offset(0, isMobile ? 3 : 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          // Responsive grid inside panel
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gridColumns = constraints.maxWidth > 400 ? 2 : 1;
                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: gridColumns,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  shrinkWrap: true,
                  childAspectRatio: 3.5,
                  children: List.generate(
                    4,
                    (index) => _smallItemCard(context, index, isMobile),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallItemCard(BuildContext context, int index, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 16 : 18,
            backgroundColor: Colors.blue.shade300,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Item ${index + 1}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: isMobile ? 13 : 14),
            ),
          ),
          Icon(Icons.chevron_right, size: isMobile ? 18 : 20),
        ],
      ),
    );
  }

  Widget _buildInfoFooter(
    BuildContext context, {
    required double screenWidth,
    required bool isMobile,
  }) {
    final fontSize = isMobile ? 13.0 : 14.0;
    final padding = isMobile ? 12.0 : 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: isMobile ? 20 : 24,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'How it Adapts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Mobile (< 600px): Single column, optimized spacing\n'
            '• Tablet (600-900px): Two equal columns side-by-side\n'
            '• Desktop (≥ 900px): Three columns with 2:1:1 ratio\n'
            '• All breakpoints use responsive fonts, padding, and shadows\n'
            '• LayoutBuilder enables nested responsive grids',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: fontSize, height: 1.6),
          ),
        ],
      ),
    );
  }
}
