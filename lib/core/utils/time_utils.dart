class TimeUtils {
  static String formatRelativeTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Recently";
    
    try {
      final DateTime date = DateTime.parse(dateStr).toLocal();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);
      
      if (difference.inSeconds < 60) {
        return "Just now";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes}m ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours}h ago";
      } else if (difference.inDays < 7) {
        if (difference.inDays == 1) return "Yesterday";
        return "${difference.inDays} days ago";
      } else {
        return "${date.day} ${_getMonth(date.month)} ${date.year}";
      }
    } catch (e) {
      return dateStr.split('T').first;
    }
  }

  static String _getMonth(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}
