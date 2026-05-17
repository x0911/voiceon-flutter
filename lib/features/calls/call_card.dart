import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/call_record.dart';
import '../../core/utils/duration_utils.dart';

class CallCard extends StatelessWidget {
  final CallRecord callRecord;
  final VoidCallback onTap;

  const CallCard({
    super.key,
    required this.callRecord,
    required this.onTap,
  });

  Widget _buildStatusBadge(BuildContext context) {
    final status = callRecord.transcriptionStatus;
    Color color;
    String label;
    Widget? icon;

    if (status == 'processing') {
      color = Colors.amber.shade700;
      label = 'Processing...';
      icon = const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
      );
    } else if (status == 'done') {
      color = Colors.green;
      label = 'Transcribed';
      icon = const Icon(Icons.check_circle, size: 12, color: Colors.green);
    } else {
      color = Colors.grey.shade600;
      label = 'No transcript';
      icon = Icon(Icons.cancel, size: 12, color: Colors.grey.shade600);
    }

    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncoming = callRecord.direction == 'incoming';
    final hasName = callRecord.contactName.isNotEmpty;
    
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
                  color: (isIncoming ? Colors.teal : Colors.red).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncoming ? Icons.call_received : Icons.call_made,
                  color: isIncoming ? Colors.teal : Colors.red,
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
                    _buildStatusBadge(context),
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
