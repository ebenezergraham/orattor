import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Result {
  final String test;
  final Map<String, num> scores;
  final String headline;
  final DateTime at;
  Result(this.test, this.scores, this.headline, [DateTime? at]) : at = at ?? DateTime.now();
  Map<String, dynamic> toJson() =>
      {'t': test, 's': scores, 'h': headline, 'a': at.toIso8601String()};
  factory Result.fromJson(Map<String, dynamic> j) => Result(
      j['t'], Map<String, num>.from(j['s']), j['h'], DateTime.parse(j['a']));
}

/// Persistent app state (streak, plan, results, arena entries).
class AppState extends ChangeNotifier {
  static final AppState I = AppState._();
  AppState._();
  SharedPreferences? _p;
  String name = 'Guest';
  String focus = 'Confidence';
  String goal = '';
  bool onboarded = false;
  Set<String> doneToday = {};
  String _doneDay = '';
  int streak = 0;
  String _lastActive = '';
  int xp = 0;
  List<Result> results = [];
  Set<String> programLessons = {};

  static String _day([DateTime? d]) {
    d ??= DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final p = _p!;
    name = p.getString('name') ?? name;
    focus = p.getString('focus') ?? focus;
    goal = p.getString('goal') ?? goal;
    onboarded = p.getBool('onboarded') ?? false;
    streak = p.getInt('streak') ?? 0;
    xp = p.getInt('xp') ?? 0;
    _lastActive = p.getString('lastActive') ?? '';
    _doneDay = p.getString('doneDay') ?? '';
    doneToday = _doneDay == _day() ? (p.getStringList('done') ?? []).toSet() : {};
    programLessons = (p.getStringList('programLessons') ?? []).toSet();
    results = (p.getStringList('results') ?? [])
        .map((s) => Result.fromJson(jsonDecode(s)))
        .toList();
    if (_lastActive.isNotEmpty &&
        _lastActive != _day() &&
        _lastActive != _day(DateTime.now().subtract(const Duration(days: 1)))) {
      streak = 0;
    }
    notifyListeners();
  }

  void _save() {
    final p = _p;
    if (p == null) return;
    p.setString('name', name);
    p.setString('focus', focus);
    p.setString('goal', goal);
    p.setBool('onboarded', onboarded);
    p.setInt('streak', streak);
    p.setInt('xp', xp);
    p.setString('lastActive', _lastActive);
    p.setString('doneDay', _day());
    p.setStringList('done', doneToday.toList());
    p.setStringList('programLessons', programLessons.toList());
    p.setStringList('results', results.map((r) => jsonEncode(r.toJson())).toList());
  }

  void _touch() {
    final today = _day();
    if (_lastActive != today) {
      final y = _day(DateTime.now().subtract(const Duration(days: 1)));
      streak = _lastActive == y ? streak + 1 : 1;
      _lastActive = today;
    }
  }

  void completeOnboarding(String n, String f, String g) {
    name = n.isEmpty ? 'Guest' : n;
    focus = f;
    goal = g;
    onboarded = true;
    _save();
    notifyListeners();
  }

  void completeTask(String id, {int points = 10}) {
    _touch();
    if (doneToday.add(id)) xp += points;
    _save();
    notifyListeners();
  }

  void completeProgramLesson(String id) {
    _touch();
    if (programLessons.add(id)) xp += 20;
    _save();
    notifyListeners();
  }

  void addResult(Result r) {
    _touch();
    results.insert(0, r);
    xp += 15;
    _save();
    notifyListeners();
  }

  void reset() {
    results = [];
    doneToday = {};
    programLessons = {};
    streak = 0;
    xp = 0;
    onboarded = false;
    _lastActive = '';
    _save();
    notifyListeners();
  }
}
