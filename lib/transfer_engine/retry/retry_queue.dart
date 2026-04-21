import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// Matches product retry classification (orchestration priority only).
enum RetryInitiator {
  /// Lower priority when ordering competing retries.
  auto,

  /// Higher priority — user explicitly asked to retry.
  user,
}

/// Computes wait time after failure `attemptIndex` (0 = first retry wait).
final class ExponentialBackoff extends Equatable {
  const ExponentialBackoff({
    this.base = const Duration(seconds: 1),
    this.multiplier = 2,
    this.maxDelay = const Duration(minutes: 1),
  }) : assert(multiplier > 1, 'multiplier must be > 1 for exponential growth');

  final Duration base;
  final double multiplier;
  final Duration maxDelay;

  Duration delayAfterAttempt(int attemptIndex) {
    if (attemptIndex < 0) {
      return Duration.zero;
    }
    final double factor = math.pow(multiplier, attemptIndex).toDouble();
    final int ms = (base.inMilliseconds * factor).round();
    final Duration raw = Duration(milliseconds: ms);
    return raw > maxDelay ? maxDelay : raw;
  }

  @override
  List<Object?> get props => <Object?>[base, multiplier, maxDelay];
}

/// Work waiting for its next eligible time (no side effects until consumed).
final class RetryQueueEntry extends Equatable
    implements Comparable<RetryQueueEntry> {
  const RetryQueueEntry({
    required this.id,
    required this.initiator,
    required this.attempt,
    required this.nextEligibleAt,
  });

  final String id;
  final RetryInitiator initiator;
  final int attempt;
  final DateTime nextEligibleAt;

  @override
  int compareTo(RetryQueueEntry other) {
    final int time = nextEligibleAt.compareTo(other.nextEligibleAt);
    if (time != 0) {
      return time;
    }
    if (initiator != other.initiator) {
      return other.initiator.index.compareTo(initiator.index);
    }
    return id.compareTo(other.id);
  }

  @override
  List<Object?> get props => <Object?>[id, initiator, attempt, nextEligibleAt];
}

/// Priority-aware retry scheduling with exponential backoff (no network).
final class RetryQueue {
  RetryQueue({
    this.maxRetries = AppConstants.defaultMaxRetryCount,
    ExponentialBackoff? backoff,
    DateTime Function()? clock,
  }) : _backoff = backoff ?? const ExponentialBackoff(),
       _clock = clock ?? DateTime.now;

  final int maxRetries;
  final ExponentialBackoff _backoff;
  final DateTime Function() _clock;

  final List<RetryQueueEntry> _entries = <RetryQueueEntry>[];

  /// Whether another automatic retry should be scheduled for this [attempt].
  bool canRetryAgain(int attempt) => attempt < maxRetries;

  Duration backoffAfterAttempt(int attemptIndex) =>
      _backoff.delayAfterAttempt(attemptIndex);

  /// Schedules a retry after [from] + backoff([attempt]).
  void schedule({
    required String id,
    required RetryInitiator initiator,
    required int attempt,
    DateTime? from,
  }) {
    if (!canRetryAgain(attempt)) {
      return;
    }
    final DateTime baseTime = from ?? _clock();
    final DateTime when = baseTime.add(_backoff.delayAfterAttempt(attempt));
    _entries.add(
      RetryQueueEntry(
        id: id,
        initiator: initiator,
        attempt: attempt + 1,
        nextEligibleAt: when,
      ),
    );
    _entries.sort();
  }

  /// Removes and returns the next entry that is due, preferring user-initiated
  /// when times tie (via [RetryQueueEntry.compareTo]).
  RetryQueueEntry? popNextDue({DateTime? now}) {
    final DateTime t = now ?? _clock();
    final int index = _entries.indexWhere(
      (RetryQueueEntry e) => !e.nextEligibleAt.isAfter(t),
    );
    if (index < 0) {
      return null;
    }
    return _entries.removeAt(index);
  }

  void clearId(String id) {
    _entries.removeWhere((RetryQueueEntry e) => e.id == id);
  }

  int get pendingCount => _entries.length;
}
