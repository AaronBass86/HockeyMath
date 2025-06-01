import 'package:flutter/material.dart';
import 'package:hockey_math/services/maps_service.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hockey_math/models/reminder_settings.dart';
import 'package:hockey_math/screens/reminder_settings_screen.dart';
import 'dart:developer' as dev;

class ResultsScreen extends StatefulWidget {
  final TimeOfDay gameTime;
  final int bufferMinutes;
  final String destination;
  final ReminderSettings reminderSettings;
  
  const ResultsScreen({
    super.key,
    required this.gameTime,
    required this.bufferMinutes,
    required this.destination,
    required this.reminderSettings,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _distance = 'Loading...';
  String _duration = 'Loading...';
  TimeOfDay? _departureTime;
  Map<String, dynamic> tripDetails = {
    'distance': 'Loading...',
    'duration': 'Loading...',
    'durationValue': 0,
  };
  List<Stop> stops = [];
  late ReminderSettings _reminderSettings;

  @override
  void initState() {
    super.initState();
    _fetchTripDetails();
    _reminderSettings = widget.reminderSettings;
  }

  Future<void> _fetchTripDetails() async {
    dev.log('Fetching trip details for ${widget.destination}');
    
    // Get route details including all stops
    final stopLocations = stops.map((stop) => stop.location).toList();
    final details = await MapsService.getDirections(
      widget.destination,
      stops: stopLocations,
    );
    dev.log('Got trip details: $details');

    // Calculate total stop duration
    final totalStopDuration = stops.fold<int>(
      0,
      (sum, stop) => sum + stop.duration,
    );
    dev.log('Total stop duration: $totalStopDuration minutes');

    // Get current date for DateTime calculations
    final now = DateTime.now();
    
    // Convert game time to DateTime
    final gameDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.gameTime.hour,
      widget.gameTime.minute,
    );

    // Work backwards from game time:
    // 1. Calculate required arrival time at rink (game time - buffer)
    final gameMinutes = gameDateTime.hour * 60 + gameDateTime.minute;
    final requiredArrivalMinutes = gameMinutes - widget.bufferMinutes;
    
    // 2. Calculate total journey time (travel + stops)
    final travelMinutes = (details['durationValue'] / 60).ceil();
    final totalJourneyTime = travelMinutes + totalStopDuration;
    
    // 3. Calculate departure time (required arrival - total journey)
    final departureMinutes = requiredArrivalMinutes - totalJourneyTime;
    
    // Convert times to TimeOfDay
    final departureTime = TimeOfDay(
      hour: (departureMinutes ~/ 60) % 24,
      minute: (departureMinutes % 60).toInt(),
    );

    final arrivalTime = TimeOfDay(
      hour: (requiredArrivalMinutes ~/ 60) % 24,
      minute: (requiredArrivalMinutes % 60).toInt(),
    );

    dev.log('Game time: ${widget.gameTime.format(context)}');
    dev.log('Buffer time: ${widget.bufferMinutes} minutes');
    dev.log('Required arrival: ${arrivalTime.format(context)}');
    dev.log('Travel time: $travelMinutes minutes');
    dev.log('Stop duration: $totalStopDuration minutes');
    dev.log('Total journey time: $totalJourneyTime minutes');
    dev.log('Departure time: ${departureTime.format(context)}');

    setState(() {
      _distance = details['distance'];
      _duration = details['duration'];
      _departureTime = departureTime;
      tripDetails = details;
    });
  }

  Future<void> _addStop() async {
    final result = await showDialog<Stop>(
      context: context,
      builder: (context) => AddStopDialog(),
    );

    if (result != null) {
      setState(() {
        stops.add(result);
      });
      // Explicitly recalculate after adding a stop
      await _fetchTripDetails();
    }
  }

  DateTime _timeOfDayToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _addToCalendar() async {
    if (_departureTime == null) return;

    final gameDateTime = _timeOfDayToDateTime(widget.gameTime);
    final departureDateTime = _timeOfDayToDateTime(_departureTime!);
    
    // Create reminders for each enabled reminder setting
    final reminders = <Event>[];
    
    if (_reminderSettings.packGearReminder) {
      reminders.add(Event(
        title: 'Pack Hockey Gear',
        description: 'Time to check your equipment and pack your bag for the game at ${widget.gameTime.format(context)}',
        location: widget.destination,
        startDate: departureDateTime.subtract(Duration(minutes: _reminderSettings.packGearMinutes)),
        endDate: departureDateTime.subtract(Duration(minutes: _reminderSettings.packGearMinutes - 15)),
      ));
    }

    if (_reminderSettings.eatMealReminder) {
      reminders.add(Event(
        title: 'Pre-Game Meal',
        description: 'Time to eat and fuel up for your game at ${widget.gameTime.format(context)}',
        startDate: departureDateTime.subtract(Duration(minutes: _reminderSettings.eatMealMinutes)),
        endDate: departureDateTime.subtract(Duration(minutes: _reminderSettings.eatMealMinutes - 30)),
      ));
    }

    if (_reminderSettings.fillWaterReminder) {
      reminders.add(Event(
        title: 'Fill Water Bottles',
        description: 'Prepare your hydration for the game at ${widget.gameTime.format(context)}',
        startDate: departureDateTime.subtract(Duration(minutes: _reminderSettings.fillWaterMinutes)),
        endDate: departureDateTime.subtract(Duration(minutes: _reminderSettings.fillWaterMinutes - 15)),
      ));
    }

    if (_reminderSettings.stretchReminder) {
      reminders.add(Event(
        title: 'Pre-Game Stretch',
        description: 'Time to warm up for your game at ${widget.gameTime.format(context)}',
        startDate: departureDateTime.subtract(Duration(minutes: _reminderSettings.stretchMinutes)),
        endDate: departureDateTime.subtract(Duration(minutes: _reminderSettings.stretchMinutes - 20)),
      ));
    }

    // Add the main game event
    final gameEvent = Event(
      title: 'Hockey Game at ${widget.destination}',
      description: 'Leave at ${_departureTime!.format(context)} to arrive ${widget.bufferMinutes} minutes before the game.\nDistance: $_distance\nTravel time: $_duration',
      location: widget.destination,
      startDate: departureDateTime,
      endDate: gameDateTime.add(const Duration(hours: 2)), // Assuming 2-hour game
      iosParams: const IOSParams(
        reminder: Duration(minutes: 15), // Reminder 15 minutes before departure
      ),
      androidParams: const AndroidParams(),
    );

    // Add all events to calendar
    for (final reminder in reminders) {
      await Add2Calendar.addEvent2Cal(reminder);
    }
    await Add2Calendar.addEvent2Cal(gameEvent);
  }

  Future<void> _launchNavigation() async {
    final encodedDestination = Uri.encodeComponent(widget.destination);
    
    // Build waypoints string for stops
    String waypointsParam = '';
    if (stops.isNotEmpty) {
      // For web URL, waypoints need to be separated by pipe character
      final encodedWaypoints = stops
          .map((stop) => Uri.encodeComponent(stop.location))
          .join('|');
      waypointsParam = encodedWaypoints;
    }

    // For web URL
    final fallbackUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=Your+location'  // Let Google Maps use current location
      '&destination=$encodedDestination'
      '${stops.isNotEmpty ? "&waypoints=$waypointsParam" : ""}'
      '${stops.isNotEmpty ? "&optimize=false" : ""}'  // Separate parameter for optimize
      '&travelmode=driving'
    );

    // For native Google Maps app
    final nativeWaypoints = stops.isNotEmpty 
        ? stops.map((stop) => Uri.encodeComponent(stop.location)).join('|')
        : '';
    final nativeUrl = Uri.parse(
      'google.navigation:q=$encodedDestination'
      '${stops.isNotEmpty ? "&waypoints=$nativeWaypoints" : ""}'
      '&mode=d'
    );

    try {
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl);
      } else {
        throw 'Could not launch navigation';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open navigation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to game setup',
        ),
        title: const Text('Trip Details'),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDepartureWarning(context),
              _buildHeader(context),
              _buildTimeCard(context),
              _buildReminderSummary(context),
              _buildTripDetails(context),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartureWarning(BuildContext context) {
    if (_departureTime == null) return const SizedBox.shrink();

    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final departureMinutes = _departureTime!.hour * 60 + _departureTime!.minute;

    if (currentMinutes > departureMinutes) {
      final minutesLate = currentMinutes - departureMinutes;
      return Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You are ${minutesLate} minutes past the recommended departure time. '
                'Consider adjusting your schedule or route.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Text(
            'Game Time ${widget.gameTime.format(context)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF4A90E2),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            toTitleCase(widget.destination),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  // Helper function to convert text to title case
  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildTimeCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Leave at time
            Row(
              children: [
                Icon(
                  Icons.departure_board,
                  size: 35,
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave at',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF4A90E2),
                        ),
                      ),
                      Text(
                        _departureTime?.format(context) ?? 'Calculating...',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: const Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (stops.isNotEmpty) ...[
              const Divider(height: 32),
              ...stops.map((stop) => _buildStopTimeRow(context, stop)),
            ],
            const Divider(height: 32),
            // Rink arrival time
            Row(
              children: [
                Icon(
                  Icons.access_time_filled,
                  size: 31,
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rink arrival time',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF4A90E2),
                        ),
                      ),
                      Text(
                        _getArrivalTime()?.format(context) ?? 'Calculating...',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF4A90E2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Game time
            Row(
              children: [
                Icon(
                  Icons.sports_hockey,
                  size: 31,
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Game time',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF4A90E2),
                        ),
                      ),
                      Text(
                        widget.gameTime.format(context),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF4A90E2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Buffer time info
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 31,
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Buffer time: ${widget.bufferMinutes} minutes',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopTimeRow(BuildContext context, Stop stop) {
    if (_departureTime == null) return const SizedBox.shrink();

    final travelMinutes = (tripDetails['durationValue'] / 60).ceil();
    final departureMinutes = _departureTime!.hour * 60 + _departureTime!.minute;
    
    final firstSegmentMinutes = (travelMinutes * 0.4).ceil();
    final stopArrivalMinutes = departureMinutes + firstSegmentMinutes;
    
    final stopArrivalTime = TimeOfDay(
      hour: (stopArrivalMinutes ~/ 60) % 24,
      minute: (stopArrivalMinutes % 60).toInt(),
    );

    final stopDepartureMinutes = stopArrivalMinutes + stop.duration;
    final stopDepartureTime = TimeOfDay(
      hour: (stopDepartureMinutes ~/ 60) % 24,
      minute: (stopDepartureMinutes % 60).toInt(),
    );

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
      child: Row(
        children: [
          Icon(
            Icons.place,
            size: 31,
            color: const Color(0xFF4A90E2).withOpacity(0.7),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stop: ${toTitleCase(stop.location)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Arrive at ${stopArrivalTime.format(context)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${stop.duration} min stop)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• Leave here by: ${stopDepartureTime.format(context)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay? _getArrivalTime() {
    if (_departureTime == null) return null;
    
    final travelMinutes = (tripDetails['durationValue'] / 60).ceil();
    final departureMinutes = _departureTime!.hour * 60 + _departureTime!.minute;
    
    // Calculate total journey time including stops
    final totalStopDuration = stops.fold<int>(
      0,
      (sum, stop) => sum + stop.duration,
    );
    
    // For the final segment to the rink, we assume it's about 60% of total travel
    // since Chicago to Willowbrook is further than origin to Chicago
    final finalSegmentMinutes = (travelMinutes * 0.6).ceil();
    
    // Calculate arrival time including all stops and the longer final segment
    final arrivalMinutes = departureMinutes + totalStopDuration + travelMinutes;
    
    return TimeOfDay(
      hour: (arrivalMinutes ~/ 60) % 24,
      minute: (arrivalMinutes % 60).toInt(),
    );
  }

  Widget _buildReminderSummary(BuildContext context) {
    // Only show if at least one reminder is enabled
    if (!_reminderSettings.packGearReminder &&
        !_reminderSettings.eatMealReminder &&
        !_reminderSettings.fillWaterReminder &&
        !_reminderSettings.stretchReminder) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 24,
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Active Reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF4A90E2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_reminderSettings.packGearReminder)
              _buildReminderItem(
                context,
                'Pack Your Gear',
                _reminderSettings.packGearMinutes,
                Icons.sports_hockey,
              ),
            if (_reminderSettings.eatMealReminder)
              _buildReminderItem(
                context,
                'Pre-Game Meal',
                _reminderSettings.eatMealMinutes,
                Icons.restaurant,
              ),
            if (_reminderSettings.fillWaterReminder)
              _buildReminderItem(
                context,
                'Fill Water Bottles',
                _reminderSettings.fillWaterMinutes,
                Icons.water_drop,
              ),
            if (_reminderSettings.stretchReminder)
              _buildReminderItem(
                context,
                'Stretch and Warm Up',
                _reminderSettings.stretchMinutes,
                Icons.fitness_center,
              ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  final settings = await Navigator.push<ReminderSettings>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReminderSettingsScreen(
                        settings: _reminderSettings,
                        onSettingsChanged: (newSettings) {
                          setState(() {
                            _reminderSettings = newSettings;
                          });
                        },
                      ),
                    ),
                  );
                  if (settings != null) {
                    setState(() {
                      _reminderSettings = settings;
                    });
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Reminders'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    String title,
    int minutes,
    IconData icon,
  ) {
    if (_departureTime == null) return const SizedBox.shrink();

    final reminderTime = TimeOfDay(
      hour: (_departureTime!.hour * 60 + _departureTime!.minute - minutes) ~/ 60 % 24,
      minute: (_departureTime!.hour * 60 + _departureTime!.minute - minutes) % 60,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF4A90E2).withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Reminder at ${reminderTime.format(context)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trip Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF4A90E2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (stops.isNotEmpty)
                  TextButton.icon(
                    onPressed: _fetchTripDetails,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recalculate'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4A90E2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.route,
              label: 'Distance',
              value: _distance,
            ),
            _buildDetailRow(
              context,
              icon: Icons.access_time,
              label: 'Estimated travel time',
              value: _duration,
            ),
            if (stops.isNotEmpty) ...[
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stops',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                  Text(
                    'Total added time: ${stops.fold<int>(0, (sum, stop) => sum + stop.duration)} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...stops.map((stop) => _buildStopItem(context, stop)),
            ],
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: _addStop,
                icon: const Icon(Icons.add_location),
                label: const Text('Add a Stop'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF4A90E2)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _departureTime != null ? _addToCalendar : null,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Add to Calendar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF4A90E2)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _launchNavigation,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final settings = await Navigator.push<ReminderSettings>(
              context,
              MaterialPageRoute(
                builder: (context) => ReminderSettingsScreen(
                  settings: _reminderSettings,
                  onSettingsChanged: (newSettings) {
                    setState(() {
                      _reminderSettings = newSettings;
                    });
                  },
                ),
              ),
            );
            if (settings != null) {
              setState(() {
                _reminderSettings = settings;
              });
            }
          },
          icon: const Icon(Icons.notifications_active),
          label: const Text('Smart Reminders'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4A90E2),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF4A90E2)),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem(BuildContext context, Stop stop) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.place,
              size: 20,
              color: const Color(0xFF4A90E2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toTitleCase(stop.location),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${stop.duration} minutes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                setState(() {
                  stops.remove(stop);
                });
                await _fetchTripDetails();
              },
              iconSize: 20,
              color: const Color(0xFF4A90E2),
            ),
          ],
        ),
      ),
    );
  }
}

class Stop {
  final String location;
  final int duration;

  Stop({
    required this.location,
    required this.duration,
  });
}

class AddStopDialog extends StatefulWidget {
  @override
  _AddStopDialogState createState() => _AddStopDialogState();
}

class _AddStopDialogState extends State<AddStopDialog> {
  final _locationController = TextEditingController();
  int _duration = 15; // Default 15 minutes

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a Stop'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Enter stop location',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Duration: '),
              Expanded(
                child: Slider(
                  value: _duration.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '$_duration minutes',
                  onChanged: (value) {
                    setState(() {
                      _duration = value.round();
                    });
                  },
                ),
              ),
              Text('$_duration min'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_locationController.text.isNotEmpty) {
              Navigator.of(context).pop(
                Stop(
                  location: _locationController.text,
                  duration: _duration,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
} 