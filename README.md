# Vocal Image (Flutter)

Unofficial Flutter recreation of the vocalimage.app landing page and app experience, for web, Android and iOS.

## Features
- Landing page (nav, goal picker, press, stats, features, tests, reviews, footer) and onboarding quiz
- Real on-device mic analysis (pitch via autocorrelation, loudness, pace, pauses): Voice Test, Voice Rating, Speech Test, Age Test, Celebrity Test, Tongue Twister Test
- Archetype quiz, Accent Test (demo estimate only: the real model is proprietary)
- Pitch (intonation) trainer, breathing exercise, scripted AI roleplay, Shorts, Voice Arena (sample leaderboard)
- Programs (speech recovery, masculinization, feminization, public speaking), Learn/articles
- Daily plan, streak, XP and result history (shared_preferences)

## Run
    flutter pub get
    flutter run -d chrome     # web
    flutter run               # device/emulator
    flutter build web --release

Android needs the RECORD_AUDIO permission and iOS needs NSMicrophoneUsageDescription (see below). Not affiliated with Vocal Image.
