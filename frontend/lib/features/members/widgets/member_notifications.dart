import 'package:flutter/material.dart';

class MemberNotificationItem {
  const MemberNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.type = MemberNotificationType.info,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final MemberNotificationType type;
  final bool isRead;
}

enum MemberNotificationType { info, success, warning, payment }

class MemberNotifications extends StatelessWidget {
  const MemberNotifications({
    super.key,
    required this.notifications,
    this.onNotificationTap,
    this.onMarkAllAsRead,
  });

  final List<MemberNotificationItem> notifications;
  final ValueChanged<MemberNotificationItem>? onNotificationTap;
  final VoidCallback? onMarkAllAsRead;

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications
        .where((notification) => !notification.isRead)
        .length;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationsHeader(
              unreadCount: unreadCount,
              onMarkAllAsRead: onMarkAllAsRead,
            ),
            const SizedBox(height: 18),
            if (notifications.isEmpty)
              const _EmptyNotifications()
            else
              Column(
                children: notifications
                    .map(
                      (notification) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _NotificationTile(
                          notification: notification,
                          onTap: onNotificationTap == null
                              ? null
                              : () => onNotificationTap!(notification),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.unreadCount, this.onMarkAllAsRead});

  final int unreadCount;
  final VoidCallback? onMarkAllAsRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.notifications_none_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                unreadCount == 0
                    ? 'Aucune notification non lue'
                    : '$unreadCount notification'
                          '${unreadCount > 1 ? 's' : ''} non lue'
                          '${unreadCount > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (unreadCount > 0 && onMarkAllAsRead != null)
          TextButton(
            onPressed: onMarkAllAsRead,
            child: const Text('Tout lire'),
          ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, this.onTap});

  final MemberNotificationItem notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _notificationColor(context);
    final icon = _notificationIcon();

    return Material(
      color: notification.isRead
          ? Colors.transparent
          : theme.colorScheme.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(notification.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _notificationColor(BuildContext context) {
    final theme = Theme.of(context);

    switch (notification.type) {
      case MemberNotificationType.info:
        return theme.colorScheme.primary;
      case MemberNotificationType.success:
        return Colors.green.shade700;
      case MemberNotificationType.warning:
        return Colors.orange.shade700;
      case MemberNotificationType.payment:
        return theme.colorScheme.secondary;
    }
  }

  IconData _notificationIcon() {
    switch (notification.type) {
      case MemberNotificationType.info:
        return Icons.info_outline;
      case MemberNotificationType.success:
        return Icons.check_circle_outline;
      case MemberNotificationType.warning:
        return Icons.warning_amber_outlined;
      case MemberNotificationType.payment:
        return Icons.payments_outlined;
    }
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 38,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'Aucune notification',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Les informations importantes apparaîtront ici.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime date) {
  final localDate = date.toLocal();

  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  final year = localDate.year.toString();

  final hour = localDate.hour.toString().padLeft(2, '0');
  final minute = localDate.minute.toString().padLeft(2, '0');

  return '$day/$month/$year à $hour:$minute';
}
