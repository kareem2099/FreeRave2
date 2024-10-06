abstract class PasswordManagementState {}

class PasswordManagementInitial extends PasswordManagementState {}

class PasswordManagementLoading extends PasswordManagementState {}

class PasswordManagementSuccess extends PasswordManagementState {
  final String message;

  PasswordManagementSuccess(this.message);
}

class PasswordManagementError extends PasswordManagementState {
  final String message;
  final String? errorCode;

  PasswordManagementError(this.message, {this.errorCode});
}

class PasswordExpiryWarning extends PasswordManagementState {
  final String message;
  final DateTime? expiryDate;

  PasswordExpiryWarning(this.message, {this.expiryDate});
}
class PasswordExpiryChecked extends PasswordManagementState {
  final String message;
  final DateTime expiryDate;

  PasswordExpiryChecked(this.message, this.expiryDate);
}


// Add the PasswordHistoryEntry class here
class PasswordHistoryEntry {
  final String password;
  final DateTime changeDate;
  final double strength;

  PasswordHistoryEntry({
    required this.password,
    required this.changeDate,
    required this.strength,
  });
}

// Update the PasswordHistoryLoaded class to use PasswordHistoryEntry
class PasswordHistoryLoaded extends PasswordManagementState {
  final List<PasswordHistoryEntry> history;

  PasswordHistoryLoaded(this.history);
}
