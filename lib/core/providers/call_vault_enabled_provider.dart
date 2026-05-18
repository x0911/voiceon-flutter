import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _callsChannel = MethodChannel('voiceon/calls');

/// Reactive provider for whether Call Vault is enabled.
/// Used by the bottom navigation to show/hide the Calls tab.
/// Call [ref.invalidate(callVaultEnabledProvider)] after toggling in settings.
final callVaultEnabledProvider = FutureProvider<bool>((ref) async {
  try {
    return await _callsChannel.invokeMethod<bool>('isCallVaultEnabled') ??
        false;
  } catch (_) {
    return false;
  }
});
