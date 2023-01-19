import 'package:meta/meta.dart';
import 'call_participant_state.dart';

import 'coordinator/models/coordinator_models.dart';
import 'model/call_status.dart';

/// TODO - Class that holds any information about the call, including participants
@immutable
class CallStateV2 {
  factory CallStateV2({
    required String currentUserId,
    required String callCid,
    required CallMetadata metadata,
  }) {
    return CallStateV2._(
      currentUserId: currentUserId,
      callCid: callCid,
      sessionId: '',
      status: metadata.toCallStatus(),
      callParticipants: Map.unmodifiable(
        metadata.toCallParticipants(
          currentUserId,
        ),
      ),
    );
  }

  /// TODO
  const CallStateV2._({
    required this.currentUserId,
    required this.callCid,
    required this.sessionId,
    required this.status,
    required this.callParticipants,
  });

  final String currentUserId;
  final String callCid;
  final String sessionId;
  final CallStatus status;
  final Map<String, CallParticipantStateV2> callParticipants;

  /// Returns a copy of this [CallStateV2] with the given fields replaced
  /// with the new values.
  CallStateV2 copyWith({
    String? currentUserId,
    String? callCid,
    String? sessionId,
    CallStatus? status,
    Map<String, CallParticipantStateV2>? callParticipants,
  }) {
    return CallStateV2._(
      currentUserId: currentUserId ?? this.currentUserId,
      callCid: callCid ?? this.callCid,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      callParticipants: callParticipants ?? this.callParticipants,
    );
  }

  @override
  String toString() {
    return 'CallStateV2{callCid: $callCid, sessionId: $sessionId, '
        'status: $status, callParticipants: $callParticipants}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallStateV2 &&
          runtimeType == other.runtimeType &&
          callCid == other.callCid &&
          sessionId == other.sessionId &&
          status == other.status &&
          callParticipants == other.callParticipants;

  @override
  int get hashCode =>
      callCid.hashCode ^
      sessionId.hashCode ^
      status.hashCode ^
      callParticipants.hashCode;
}

extension on CallMetadata {
  CallStatus toCallStatus() {
    if (createdByMe && ringing) {
      return CallStatus.outgoing;
    } else if (!createdByMe && ringing) {
      return CallStatus.incoming;
    } else {
      return CallStatus.idle;
    }
  }

  Map<String, CallParticipantStateV2> toCallParticipants(String currentUserId) {
    final result = <String, CallParticipantStateV2>{};
    for (final userId in details.memberUserIds) {
      final member = details.members[userId];
      final isLocal = currentUserId == userId;
      result[userId] = CallParticipantStateV2(
        userId: userId,
        role: member?.role ?? '',
        name: '',
        profileImageURL: '',
        sessionId: '',
        trackIdPrefix: '',
        isLocal: isLocal,
        isOnline: !isLocal,
      );
    }
    return result;
  }
}
