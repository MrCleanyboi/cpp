typedef ServiceResetCallback = void Function();

final List<ServiceResetCallback> _resets = [];

/// Register a callback to be run when the user session resets (login/logout/signup).
void registerServiceReset(ServiceResetCallback callback) {
  _resets.add(callback);
}

/// Run all registered service reset callbacks.
void globalServiceReset() {
  for (final callback in _resets) {
    try {
      callback();
    } catch (e) {
      // Use a simple print to avoid further dependencies
      print('Error during service reset: $e');
    }
  }
}
