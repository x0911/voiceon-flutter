import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/models/call_record.dart';
import '../../core/repositories/calls_repository.dart';

// Filter params state
class CallFilterState {
  final String searchText;
  final String calleeName;
  final String calleeNumber;
  final DateTime? startDate;
  final DateTime? endDate;

  const CallFilterState({
    this.searchText = '',
    this.calleeName = '',
    this.calleeNumber = '',
    this.startDate,
    this.endDate,
  });

  bool get hasFilters =>
      searchText.isNotEmpty ||
      calleeName.isNotEmpty ||
      calleeNumber.isNotEmpty ||
      startDate != null ||
      endDate != null;

  CallFilterState copyWith({
    String? searchText,
    String? calleeName,
    String? calleeNumber,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return CallFilterState(
      searchText: searchText ?? this.searchText,
      calleeName: calleeName ?? this.calleeName,
      calleeNumber: calleeNumber ?? this.calleeNumber,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  CallFilterParams toParams() {
    return CallFilterParams(
      searchText: searchText.isNotEmpty ? searchText : null,
      calleeName: calleeName.isNotEmpty ? calleeName : null,
      calleeNumber: calleeNumber.isNotEmpty ? calleeNumber : null,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

// Notifier for filter state
class CallFilterNotifier extends StateNotifier<CallFilterState> {
  CallFilterNotifier() : super(const CallFilterState());

  void updateSearchText(String text) {
    state = state.copyWith(searchText: text);
  }

  void updateCalleeName(String name) {
    state = state.copyWith(calleeName: name);
  }

  void updateCalleeNumber(String number) {
    state = state.copyWith(calleeNumber: number);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date, clearStartDate: date == null);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date, clearEndDate: date == null);
  }

  void clearFilters() {
    state = const CallFilterState();
  }
}

final callFilterProvider = StateNotifierProvider<CallFilterNotifier, CallFilterState>((ref) {
  return CallFilterNotifier();
});

// Provider for filtered calls stream
final filteredCallsProvider = StreamProvider<List<CallRecord>>((ref) {
  final filters = ref.watch(callFilterProvider);
  final repo = ref.watch(callsRepositoryProvider);
  return repo.watchFilteredCalls(filters.toParams());
});

final callDetailProvider = FutureProvider.family<CallRecord?, String>((ref, id) {
  final repo = ref.watch(callsRepositoryProvider);
  return repo.getCallById(id);
});
