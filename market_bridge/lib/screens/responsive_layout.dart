// lib/screens/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({Key? key}) : super(key: key);

  static const double _tabletBreakpoint = 600; // width in logical pixels

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= _tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // Use a scroll view for small heights or many contents.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      height: isTablet ? 180 : 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Responsive Header',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: isTablet ? 28 : 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This header adapts its height and text size based on screen width.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: isTablet ? 16 : 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Body: either stacked (Column) or side-by-side (Row)
                    if (!isTablet) ...[
                      // PHONE / SMALL SCREEN: stacked panels
                      _buildPanel(
                        context,
                        title: 'Main Content',
                        subtitle: 'Single column layout for phones.',
                        minHeight: 280,
                      ),
                      const SizedBox(height: 12),
                      _buildPanel(
                        context,
                        title: 'Secondary Content',
                        subtitle: 'Additional info stacked below.',
                        minHeight: 160,
                      ),
                    ] else ...[
                      // TABLET / WIDE: two-column layout
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildPanel(
                                context,
                                title: 'Left Panel',
                                subtitle: 'Primary content panel (takes equal width).',
                                minHeight: 320,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: _buildPanel(
                                context,
                                title: 'Right Panel',
                                subtitle: 'Secondary panel for details / actions.',
                                minHeight: 320,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Footer / Reflection / CTA
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How it adapts',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '- Uses MediaQuery breakpoints and Expanded/Flexible.\n'
                                '- Stacks vertically when width < $_tabletBreakpoint px.\n'
                                '- Shows two side-by-side panels for larger widths.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPanel(
      BuildContext context, {
        required String title,
        required String subtitle,
        double minHeight = 200,
      }) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            // Example content area (cards/list)
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                // simple responsive grid inside panel: 1 column small, 2 columns if wide
                final bool twoCols = constraints.maxWidth > 320;
                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(), // parent scrolls
                  crossAxisCount: twoCols ? 2 : 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  shrinkWrap: true,
                  childAspectRatio: 3,
                  children: List.generate(
                    4,
                        (index) => _smallItemCard(context, index),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallItemCard(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade200,
            child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Item ${index + 1}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}
