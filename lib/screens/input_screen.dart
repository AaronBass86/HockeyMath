import 'package:flutter/material.dart';
import 'package:hockey_math/screens/results_screen.dart';
import 'package:hockey_math/models/reminder_settings.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  TimeOfDay? _gameTime;
  int _bufferMinutes = 45;
  late ReminderSettings _reminderSettings;

  @override
  void initState() {
    super.initState();
    _reminderSettings = const ReminderSettings();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Widget _buildReminderSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: const Color(0xFF4A90E2),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Smart Reminders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF4A90E2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildReminderItem(
            'Pack Your Gear',
            'Check your equipment and pack your bag',
            _reminderSettings.packGearReminder,
            _reminderSettings.packGearMinutes,
            (enabled) => setState(() {
              _reminderSettings = _reminderSettings.copyWith(packGearReminder: enabled);
            }),
            (minutes) => setState(() {
              _reminderSettings = _reminderSettings.copyWith(packGearMinutes: minutes);
            }),
          ),
          _buildReminderItem(
            'Pre-Game Meal',
            'Time to eat and fuel up for the game',
            _reminderSettings.eatMealReminder,
            _reminderSettings.eatMealMinutes,
            (enabled) => setState(() {
              _reminderSettings = _reminderSettings.copyWith(eatMealReminder: enabled);
            }),
            (minutes) => setState(() {
              _reminderSettings = _reminderSettings.copyWith(eatMealMinutes: minutes);
            }),
          ),
          _buildReminderItem(
            'Fill Water Bottles',
            'Prepare your hydration for the game',
            _reminderSettings.fillWaterReminder,
            _reminderSettings.fillWaterMinutes,
            (enabled) => setState(() {
              _reminderSettings = _reminderSettings.copyWith(fillWaterReminder: enabled);
            }),
            (minutes) => setState(() {
              _reminderSettings = _reminderSettings.copyWith(fillWaterMinutes: minutes);
            }),
          ),
          _buildReminderItem(
            'Stretch and Warm Up',
            'Get your body ready for the game',
            _reminderSettings.stretchReminder,
            _reminderSettings.stretchMinutes,
            (enabled) => setState(() {
              _reminderSettings = _reminderSettings.copyWith(stretchReminder: enabled);
            }),
            (minutes) => setState(() {
              _reminderSettings = _reminderSettings.copyWith(stretchMinutes: minutes);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
    String title,
    String description,
    bool enabled,
    int minutes,
    Function(bool) onEnabledChanged,
    Function(int) onMinutesChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
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
        title: const Text('Plan Your Trip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text(
                'Game Details',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF4A90E2),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destination Rink',
                    hintText: 'Enter rink name or address',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: const Color(0xFF4A90E2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a destination';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Buffer Time',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF4A90E2),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 30,
                      label: Text('30 min'),
                    ),
                    ButtonSegment(
                      value: 45,
                      label: Text('45 min'),
                    ),
                    ButtonSegment(
                      value: 60,
                      label: Text('60 min'),
                    ),
                  ],
                  selected: {_bufferMinutes},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _bufferMinutes = newSelection.first;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(MaterialState.selected)) {
                          return const Color(0xFF4A90E2);
                        }
                        return Colors.white;
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.white;
                        }
                        return const Color(0xFF4A90E2);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    'Game Time',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                  subtitle: Text(
                    _gameTime != null
                        ? _gameTime!.format(context)
                        : 'Select game time',
                  ),
                  trailing: Icon(
                    Icons.access_time,
                    color: const Color(0xFF4A90E2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _gameTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _gameTime = time;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
              _buildReminderSection(),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _gameTime != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ResultsScreen(
                          gameTime: _gameTime!,
                          bufferMinutes: _bufferMinutes,
                          destination: _destinationController.text,
                          reminderSettings: _reminderSettings,
                        ),
                      ),
                    );
                  } else if (_gameTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a game time'),
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Calculate Departure Time'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 