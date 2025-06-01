import 'package:flutter/material.dart';
import 'package:hockey_math/models/reminder_settings.dart';

class ReminderSettingsScreen extends StatefulWidget {
  final ReminderSettings settings;
  final Function(ReminderSettings) onSettingsChanged;

  const ReminderSettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  late ReminderSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  Widget _buildReminderItem({
    required String title,
    required String description,
    required bool enabled,
    required int minutes,
    required Function(bool) onEnabledChanged,
    required Function(int) onMinutesChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4A90E2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onEnabledChanged,
                activeColor: const Color(0xFF4A90E2),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Remind me',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: minutes,
                  items: [30, 45, 60, 90, 120, 180]
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text('$m minutes'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onMinutesChanged(value);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'before departure',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_settings),
          tooltip: 'Back to trip details',
        ),
        title: const Text('Smart Reminders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(_settings),
            icon: const Icon(Icons.check),
            label: const Text('Save'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4A90E2),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F3FF),
              Color(0xFFE8F3FF),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Pre-Game Routine',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF4A90E2),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up reminders to help you prepare for your game',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            _buildReminderItem(
              title: 'Pack Your Gear',
              description: 'Check your equipment and pack your bag',
              enabled: _settings.packGearReminder,
              minutes: _settings.packGearMinutes,
              onEnabledChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(packGearReminder: value);
                });
                widget.onSettingsChanged(_settings);
              },
              onMinutesChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(packGearMinutes: value);
                });
                widget.onSettingsChanged(_settings);
              },
            ),
            _buildReminderItem(
              title: 'Pre-Game Meal',
              description: 'Time to eat and fuel up for the game',
              enabled: _settings.eatMealReminder,
              minutes: _settings.eatMealMinutes,
              onEnabledChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(eatMealReminder: value);
                });
                widget.onSettingsChanged(_settings);
              },
              onMinutesChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(eatMealMinutes: value);
                });
                widget.onSettingsChanged(_settings);
              },
            ),
            _buildReminderItem(
              title: 'Fill Water Bottles',
              description: 'Prepare your hydration for the game',
              enabled: _settings.fillWaterReminder,
              minutes: _settings.fillWaterMinutes,
              onEnabledChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(fillWaterReminder: value);
                });
                widget.onSettingsChanged(_settings);
              },
              onMinutesChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(fillWaterMinutes: value);
                });
                widget.onSettingsChanged(_settings);
              },
            ),
            _buildReminderItem(
              title: 'Stretch and Warm Up',
              description: 'Get your body ready for the game',
              enabled: _settings.stretchReminder,
              minutes: _settings.stretchMinutes,
              onEnabledChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(stretchReminder: value);
                });
                widget.onSettingsChanged(_settings);
              },
              onMinutesChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(stretchMinutes: value);
                });
                widget.onSettingsChanged(_settings);
              },
            ),
          ],
        ),
      ),
    );
  }
} 