import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/call_record.dart';
import '../../core/services/call_vault_sync_service.dart';
import '../../core/utils/duration_utils.dart';

class CallCard extends ConsumerWidget {
  final CallRecord callRecord;
  final VoidCallback onTap;

  const CallCard({
    super.key,
    required this.callRecord,
    required this.onTap,
  });

  Widget _buildStatusBadge(BuildContext context, WidgetRef ref) {
    final status = callRecord.transcriptionStatus;
    Color color;
    String label;
    Widget? icon;

    if (status == 'processing') {
      color = Colors.amber.shade700;
      label = 'Transcribing...';
      icon = _ProcessingBadge(color: color);
    } else if (status == 'done') {
      color = Colors.green;
      label = 'Transcribed';
      icon = const Icon(Icons.check_circle, size: 12, color: Colors.green);
    } else if (status == 'failed') {
      color = Colors.red;
      label = 'Failed';
      icon = const Icon(Icons.error_outline, size: 12, color: Colors.red);
    } else if (status == 'no_provider') {
      color = Colors.grey.shade600;
      label = 'No AI set up';
      icon = Icon(Icons.info_outline, size: 12, color: Colors.grey.shade600);
    } else {
      color = Colors.grey.shade600;
      label = 'Pending';
      icon = Icon(Icons.schedule, size: 12, color: Colors.grey.shade600);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(76)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        if (status == 'failed') ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            color: Colors.red,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              ref.read(callVaultSyncServiceProvider).retranscribe(callRecord.id, callRecord.audioPath);
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncoming = callRecord.direction == 'incoming';
    final isOutgoing = callRecord.direction == 'outgoing';
    final hasName = callRecord.contactName.isNotEmpty;
    
    Color directionColor = Colors.grey;
    IconData directionIcon = Icons.phone_android;
    if (isIncoming) {
      directionColor = Colors.teal;
      directionIcon = Icons.call_received;
    } else if (isOutgoing) {
      directionColor = Colors.blueGrey;
      directionIcon = Icons.call_made;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: directionColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  directionIcon,
                  color: directionColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? callRecord.contactName : callRecord.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasName) ...[
                      const SizedBox(height: 2),
                      Text(
                        callRecord.phoneNumber,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy · HH:mm').format(callRecord.startedAt),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatCallDuration(callRecord.durationSeconds),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            callRecord.formattedFileSize,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(context, ref),
                      ],
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

class _ProcessingBadge extends StatefulWidget {
  final Color color;
  const _ProcessingBadge({required this.color});

  @override
  State<_ProcessingBadge> createState() => _ProcessingBadgeState();
}

class _ProcessingBadgeState extends State<_ProcessingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
      child: Icon(Icons.graphic_eq, size: 12, color: widget.color),
    );
  }
}
