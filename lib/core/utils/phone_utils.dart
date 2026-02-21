class PhoneUtils {
  static String normalize(String phone) {
    // Remove everything except digits
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // If already 91XXXXXXXXXX
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return cleaned;
    }

    // If 10 digit number → convert to 91XXXXXXXXXX
    if (cleaned.length == 10) {
      return '91$cleaned';
    }

    // Otherwise return cleaned version
    return cleaned;
  }
}
