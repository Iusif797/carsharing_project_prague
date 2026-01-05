import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      icon: FontAwesomeIcons.car,
      title: 'Booking Confirmed',
      message: 'Your Škoda Fabia has been reserved for tomorrow at 10:00 AM',
      time: '2 min ago',
      isRead: false,
      color: const Color(0xFF2196F3),
    ),
    NotificationItem(
      icon: FontAwesomeIcons.boltLightning,
      title: 'Special Offer',
      message: 'Get 20% off on electric vehicles this weekend!',
      time: '1 hour ago',
      isRead: false,
      color: const Color(0xFF4CAF50),
    ),
    NotificationItem(
      icon: FontAwesomeIcons.clockRotateLeft,
      title: 'Trip Completed',
      message: 'Your trip to Prague Castle has ended. Total: 245 Kč',
      time: '3 hours ago',
      isRead: true,
      color: const Color(0xFF9E9E9E),
    ),
    NotificationItem(
      icon: FontAwesomeIcons.percent,
      title: 'Loyalty Reward',
      message: 'You earned 50 points! Redeem for free minutes.',
      time: 'Yesterday',
      isRead: true,
      color: const Color(0xFFFF9800),
    ),
    NotificationItem(
      icon: FontAwesomeIcons.triangleExclamation,
      title: 'Maintenance Notice',
      message: 'Some vehicles may be unavailable on Dec 10 for maintenance',
      time: '2 days ago',
      isRead: true,
      color: const Color(0xFFF44336),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in _notifications) {
                    notification.isRead = true;
                  }
                });
              },
              child: const Text(
                'Mark All Read',
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.bell,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(notification, isDark);
              },
            ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, bool isDark) {
    return Dismissible(
      key: Key(notification.title + notification.time),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          setState(() {
            notification.isRead = true;
          });
        },
        child: Container(
          color: notification.isRead
              ? Colors.transparent
              : (isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF5F5F5)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2196F3),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.time,
                      style: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                        fontSize: 12,
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
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  bool isRead;
  final Color color;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.color,
  });
}
