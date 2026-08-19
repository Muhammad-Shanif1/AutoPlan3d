import 'package:flutter/material.dart';

class ZoomButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool enabled;

  const ZoomButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.blueGrey[800], size: 24),
          ),
        ),
      ),
    );
  }
}

class CircularActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;

  const CircularActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                  : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class RoomLegend extends StatelessWidget {
  const RoomLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: [
        _buildLegendItem('Living Room', const Color(0xFFE6194B)),
        _buildLegendItem('Master Room', const Color(0xFF3CB44B)),
        _buildLegendItem('Kitchen', const Color(0xFFAAFFC3)),
        _buildLegendItem('Bathroom', const Color(0xFF0082C8)),
        _buildLegendItem('Dining Room', const Color(0xFFF58230)),
        _buildLegendItem('Child Room', const Color(0xFF911EB4)),
        _buildLegendItem('Study Room', const Color(0xFF46F0F0)),
        _buildLegendItem('Second Room', const Color(0xFFF032E6)),
        _buildLegendItem('Guest Room', const Color(0xFFD2F53C)),
        _buildLegendItem('Balcony', const Color(0xFFFABEBE)),
        _buildLegendItem('Entrance', const Color(0xFF008080)),
        _buildLegendItem('Storage', const Color(0xFFE6BEFF)),
        _buildLegendItem('Walk-in Closet', const Color(0xFFAA6E28)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.grey.withOpacity(0.4),
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class MainActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color? color;

  const MainActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                buttonColor,
                buttonColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
