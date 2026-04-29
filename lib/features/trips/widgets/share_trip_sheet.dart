import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookstrip/core/providers/collaboration_provider.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';

/// Bottom sheet to manage trip collaborators.
class ShareTripSheet extends ConsumerStatefulWidget {
  final String tripId;
  final String tripTitle;

  const ShareTripSheet({
    super.key,
    required this.tripId,
    required this.tripTitle,
  });

  @override
  ConsumerState<ShareTripSheet> createState() => _ShareTripSheetState();
}

class _ShareTripSheetState extends ConsumerState<ShareTripSheet> {
  final _phoneController = TextEditingController();
  String _role = 'editor';
  bool _adding = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addCollaborator() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || _adding) return;

    setState(() => _adding = true);
    final success = await ref
        .read(collabProvider(widget.tripId).notifier)
        .shareByPhone(phone, role: _role);
    if (!mounted) return;
    setState(() => _adding = false);

    if (success) {
      _phoneController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Collaborator added')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find or add that user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collabState = ref.watch(collabProvider(widget.tripId));

    return Container(
      padding: EdgeInsets.only(
        left: AppShapes.screenPadding,
        right: AppShapes.screenPadding,
        top: AppShapes.spaceMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppShapes.spaceLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.radius2xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppShapes.spaceMd),
          Text('Share Trip', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppShapes.spaceXs),
          Text(
            widget.tripTitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: AppShapes.spaceLg),
          Text(
            'Add Collaborator',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppShapes.spaceSm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    filled: true,
                    fillColor: AppColors.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _addCollaborator(),
                ),
              ),
              const SizedBox(width: AppShapes.spaceSm),
              SizedBox(
                height: AppShapes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _adding ? null : _addCollaborator,
                  child: _adding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppShapes.spaceSm),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: InputDecoration(
              labelText: 'Permission',
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'editor',
                child: Text('Editor - can update trip details'),
              ),
              DropdownMenuItem(
                value: 'viewer',
                child: Text('Viewer - can only view trip details'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _role = value);
            },
          ),
          const SizedBox(height: AppShapes.spaceLg),
          if (collabState.collaborators.isNotEmpty) ...[
            Text(
              'Collaborators',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppShapes.spaceSm),
            ...collabState.collaborators.map(
              (collab) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    collab.role == 'owner'
                        ? Icons.workspace_premium_rounded
                        : collab.role == 'viewer'
                        ? Icons.visibility_rounded
                        : Icons.edit_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  collab.phone?.isNotEmpty == true
                      ? collab.phone!
                      : collab.userId.substring(0, 8),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  collab.role.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                trailing: collab.role != 'owner'
                    ? IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => ref
                            .read(collabProvider(widget.tripId).notifier)
                            .remove(collab.id),
                      )
                    : null,
              ),
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppShapes.spaceLg,
                ),
                child: Text(
                  'No collaborators yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
