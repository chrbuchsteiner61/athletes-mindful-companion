import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'user_settings.g.dart';

/// User settings and preferences
@collection
class UserSettings {
  UserSettings({
    String? id,
    this.userName = 'Athlet',
    this.preferredSport = SportType.golf,
    this.notificationEnabled = true,
    this.preSessionReminderMinutes = 60,
    this.postSessionReminderMinutes = 30,
    this.llmProvider = LLMProvider.mock,
    this.apiKey = '',
    this.themeMode = ThemeMode.system,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String userName;

  @enumerated
  final SportType preferredSport;

  final bool notificationEnabled;
  final int preSessionReminderMinutes;
  final int postSessionReminderMinutes;

  @enumerated
  final LLMProvider llmProvider;

  final String apiKey;

  @enumerated
  final ThemeMode themeMode;

  UserSettings copyWith({
    String? id,
    String? userName,
    SportType? preferredSport,
    bool? notificationEnabled,
    int? preSessionReminderMinutes,
    int? postSessionReminderMinutes,
    LLMProvider? llmProvider,
    String? apiKey,
    ThemeMode? themeMode,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      preferredSport: preferredSport ?? this.preferredSport,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      preSessionReminderMinutes: preSessionReminderMinutes ?? this.preSessionReminderMinutes,
      postSessionReminderMinutes: postSessionReminderMinutes ?? this.postSessionReminderMinutes,
      llmProvider: llmProvider ?? this.llmProvider,
      apiKey: apiKey ?? this.apiKey,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// Supported LLM providers
enum LLMProvider {
  mock,
  mistral,
  gemini,
  openai,
}

/// Theme modes
enum ThemeMode {
  system,
  light,
  dark,
}

/// Sport types (same as in session.dart for consistency)
enum SportType {
  golf,
  tennis,
  running,
  general,
}