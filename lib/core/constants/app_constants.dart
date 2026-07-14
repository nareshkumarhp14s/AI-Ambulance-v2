class AppConstants {
  AppConstants._();

  // Firestore Collections

  static const String usersCollection = 'users';

  static const String emergencyCollection = 'emergency_requests';

  static const String hospitalCollection = 'hospitals';

  static const String ambulanceCollection = 'ambulance_tracking';

  static const String assignmentCollection = 'ambulance_assignments';

  static const String bookingCollection = 'booking_history';

  static const String driverCollection = 'drivers';

  // Roles

  static const String patientRole = 'patient';

  static const String driverRole = 'driver';

  static const String adminRole = 'admin';

  // Emergency Status

  static const String pending = 'pending';

  static const String accepted = 'accepted';

  static const String dispatched = 'dispatched';

  static const String arrived = 'arrived';

  static const String completed = 'completed';

  static const String cancelled = 'cancelled';
}
