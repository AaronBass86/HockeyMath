class ReminderSettings {
  final bool packGearReminder;
  final int packGearMinutes;
  final bool eatMealReminder;
  final int eatMealMinutes;
  final bool fillWaterReminder;
  final int fillWaterMinutes;
  final bool stretchReminder;
  final int stretchMinutes;

  const ReminderSettings({
    this.packGearReminder = false,
    this.packGearMinutes = 60,
    this.eatMealReminder = false,
    this.eatMealMinutes = 90,
    this.fillWaterReminder = false,
    this.fillWaterMinutes = 45,
    this.stretchReminder = false,
    this.stretchMinutes = 30,
  });

  Map<String, dynamic> toJson() => {
    'packGearReminder': packGearReminder,
    'packGearMinutes': packGearMinutes,
    'eatMealReminder': eatMealReminder,
    'eatMealMinutes': eatMealMinutes,
    'fillWaterReminder': fillWaterReminder,
    'fillWaterMinutes': fillWaterMinutes,
    'stretchReminder': stretchReminder,
    'stretchMinutes': stretchMinutes,
  };

  factory ReminderSettings.fromJson(Map<String, dynamic> json) => ReminderSettings(
    packGearReminder: json['packGearReminder'] ?? false,
    packGearMinutes: json['packGearMinutes'] ?? 60,
    eatMealReminder: json['eatMealReminder'] ?? false,
    eatMealMinutes: json['eatMealMinutes'] ?? 90,
    fillWaterReminder: json['fillWaterReminder'] ?? false,
    fillWaterMinutes: json['fillWaterMinutes'] ?? 45,
    stretchReminder: json['stretchReminder'] ?? false,
    stretchMinutes: json['stretchMinutes'] ?? 30,
  );

  ReminderSettings copyWith({
    bool? packGearReminder,
    int? packGearMinutes,
    bool? eatMealReminder,
    int? eatMealMinutes,
    bool? fillWaterReminder,
    int? fillWaterMinutes,
    bool? stretchReminder,
    int? stretchMinutes,
  }) {
    return ReminderSettings(
      packGearReminder: packGearReminder ?? this.packGearReminder,
      packGearMinutes: packGearMinutes ?? this.packGearMinutes,
      eatMealReminder: eatMealReminder ?? this.eatMealReminder,
      eatMealMinutes: eatMealMinutes ?? this.eatMealMinutes,
      fillWaterReminder: fillWaterReminder ?? this.fillWaterReminder,
      fillWaterMinutes: fillWaterMinutes ?? this.fillWaterMinutes,
      stretchReminder: stretchReminder ?? this.stretchReminder,
      stretchMinutes: stretchMinutes ?? this.stretchMinutes,
    );
  }
} 