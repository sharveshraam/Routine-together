import 'dart:math' as math;

import 'package:duobloom_mobile/core/utils/app_formatters.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';

class AmbientPage extends StatelessWidget {
  const AmbientPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 120),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          left: -40,
          child: _GlowBlob(
            size: 220,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
          ),
        ),
        Positioned(
          right: -60,
          top: 90,
          child: _GlowBlob(
            size: 180,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.18),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -50,
          child: _GlowBlob(
            size: 190,
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.16),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: padding,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.92),
            Colors.white.withOpacity(0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.trailing,
  });

  final String label;
  final double value;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            if (trailing != null)
              Text(
                trailing!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: clampPercent(value),
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class PerspectiveToggle extends StatelessWidget {
  const PerspectiveToggle({
    super.key,
    required this.isPartnerView,
    required this.onToggle,
  });

  final bool isPartnerView;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _ToggleSegment(
                active: !isPartnerView,
                color: scheme.primary,
                icon: Icons.person_rounded,
                label: 'Your View',
              ),
            ),
            Expanded(
              child: _ToggleSegment(
                active: isPartnerView,
                color: scheme.secondary,
                icon: Icons.favorite_rounded,
                label: 'Partner View',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.active,
    required this.color,
    required this.icon,
    required this.label,
  });

  final bool active;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: active ? color.withOpacity(0.16) : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: active ? color : color.withOpacity(0.45)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: active ? color : color.withOpacity(0.55),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class DuoAvatarHeader extends StatelessWidget {
  const DuoAvatarHeader({
    super.key,
    required this.currentProfile,
    required this.partnerProfile,
    required this.daysTogether,
    required this.perspective,
  });

  final AppProfile currentProfile;
  final AppProfile? partnerProfile;
  final int daysTogether;
  final ViewPerspective perspective;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _AvatarModelCard(
                  profile: currentProfile,
                  active: perspective == ViewPerspective.user,
                  accent: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _AvatarModelCard(
                  profile: partnerProfile,
                  active: perspective == ViewPerspective.partner,
                  accent: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$daysTogether shared days, one evolving routine, and a live partner pulse.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarModelCard extends StatelessWidget {
  const _AvatarModelCard({
    required this.profile,
    required this.active,
    required this.accent,
  });

  final AppProfile? profile;
  final bool active;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return Container(
        height: 188,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black.withOpacity(0.03),
        ),
        alignment: Alignment.center,
        child: Text(
          'Awaiting partner',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final rotation = (profile!.avatarSeed % 18) / 180;

    return AnimatedScale(
      duration: const Duration(milliseconds: 260),
      scale: active ? 1 : 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        height: 188,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              accent.withOpacity(0.95),
              accent.withOpacity(0.38),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -12,
              top: -4,
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 28,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF0F0F0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.65),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    profile!.name.substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile!.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile!.relationshipLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.86),
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profile!.pairingCode,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: colors),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.88),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoodChip extends StatelessWidget {
  const MoodChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class MindMapView extends StatelessWidget {
  const MindMapView({
    super.key,
    required this.entries,
    this.compact = false,
    this.onNodeTap,
  });

  final List<JournalEntry> entries;
  final bool compact;
  final ValueChanged<JournalEntry>? onNodeTap;

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]..sort((a, b) => a.entryDate.compareTo(b.entryDate));
    final visible = compact && sorted.length > 4 ? sorted.take(4).toList() : sorted;

    if (visible.isEmpty) {
      return Container(
        height: compact ? 150 : 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black.withOpacity(0.03),
        ),
        child: Text(
          'Write the first memory to draw your relationship map.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    final width = math.max(360.0, visible.length * (compact ? 90.0 : 170.0));
    final height = compact ? 180.0 : 320.0;
    final points = List<Offset>.generate(
      visible.length,
      (index) {
        final x = 72.0 + (index * (compact ? 88.0 : 148.0));
        final y = index.isEven ? height * 0.34 : height * 0.7;
        return Offset(x, y);
      },
    );

    final canvas = SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MindMapPainter(
                points: points,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          for (var index = 0; index < visible.length; index++)
            Positioned(
              left: points[index].dx - 48,
              top: points[index].dy - 48,
              child: GestureDetector(
                onTap: () => onNodeTap?.call(visible[index]),
                child: _MindMapNode(
                  entry: visible[index],
                  accent: index.isEven
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );

    final child = compact
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: canvas,
          )
        : InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(48),
            minScale: 0.8,
            maxScale: 2.4,
            child: canvas,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: Colors.white.withOpacity(0.72),
        child: child,
      ),
    );
  }
}

class _MindMapNode extends StatelessWidget {
  const _MindMapNode({
    required this.entry,
    required this.accent,
  });

  final JournalEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(
          color: accent.withOpacity(0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.16),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatDayMonth(entry.entryDate),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
          ),
        ],
      ),
    );
  }
}

class _MindMapPainter extends CustomPainter {
  _MindMapPainter({
    required this.points,
    required this.color,
  });

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final halo = Paint()
      ..color = color.withOpacity(0.12)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < points.length - 1; index++) {
      final path = Path()
        ..moveTo(points[index].dx, points[index].dy)
        ..cubicTo(
          (points[index].dx + points[index + 1].dx) / 2,
          points[index].dy - 36,
          (points[index].dx + points[index + 1].dx) / 2,
          points[index + 1].dy + 36,
          points[index + 1].dx,
          points[index + 1].dy,
        );
      canvas.drawPath(path, paint);
    }

    for (final point in points) {
      canvas.drawCircle(point, 8, halo);
    }
  }

  @override
  bool shouldRepaint(covariant _MindMapPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
