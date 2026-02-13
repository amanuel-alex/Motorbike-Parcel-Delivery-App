import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (isPrimary ? AppColors.primary : Colors.transparent);
    final txtColor = textColor ?? (isPrimary ? Colors.white : AppColors.primary);
    final borderSide = isPrimary || backgroundColor != null 
        ? BorderSide.none 
        : const BorderSide(color: AppColors.border, width: 1.5);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderSide,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showLogoutDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (dialContext) => AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialContext), child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            Navigator.pop(dialContext);
            Provider.of<AuthProvider>(context, listen: false).signOut();
          },
          child: const Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

Future<bool> showConfirmationDialog(BuildContext context, String title, String content) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Confirm"),
        ),
      ],
    ),
  ) ?? false;
}
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF8FAFC),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textTertiary.withOpacity(0.5),
                    size: height != null && height! < 100 ? 24 : 40,
                  ),
                  if (height == null || height! >= 100) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Preview Unavailable',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppColors.primary.withOpacity(0.3),
              ),
            );
          },
        ),
      ),
    );
  }
}
