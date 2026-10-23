import 'package:flutter/material.dart';

/// One action inside a lesson. [seconds] > 0 gives the step a countdown timer.
class LessonStep {
  final String text;
  final int seconds;
  const LessonStep(this.text, [this.seconds = 0]);
}

/// What the optional "try it and measure" card reports for a lesson.
enum Measure { none, pitch, loudness, pace }

class Lesson {
  final String title;
  final int minutes;
  final String why;
  final List<LessonStep> steps;
  final String success;
  final List<String> mistakes;
  final Measure measure;
  const Lesson(this.title, this.minutes, this.why, this.steps, this.success,
      {this.mistakes = const [], this.measure = Measure.none});
}

class Track {
  final String name, blurb;
  final String? note;
  final IconData icon;
  final List<Lesson> lessons;
  const Track(this.name, this.blurb, this.icon, this.lessons, {this.note});
  String key(Lesson l) => '$name/${l.title}';
}

/// Things people say about their voice, used to suggest where to start.
enum Concern { nasal, muffled, quiet, fuller, presenting }

const concernLabels = {
  Concern.nasal: 'My voice sounds nasal or stuffed up',
  Concern.muffled: 'I mumble or people say I sound muffled',
  Concern.quiet: "People ask me to repeat myself or speak up",
  Concern.fuller: 'I want a fuller, deeper, more natural-sounding voice',
  Concern.presenting: 'I want to present or speak to groups with confidence',
};

/// Foundations first, then the tracks matching the user's concerns, in curriculum order.
List<Track> recommendedTracks(Set<Concern> concerns) {
  const order = {
    Concern.nasal: 1,
    Concern.muffled: 2,
    Concern.quiet: 3,
    Concern.fuller: 4,
    Concern.presenting: 5,
  };
  return [
    tracks[0],
    for (final c in Concern.values)
      if (concerns.contains(c)) tracks[order[c]!],
  ];
}

const tracks = [
  Track(
    'Foundations',
    'Breath, posture and a relaxed throat. Every other track builds on this.',
    Icons.air_rounded,
    [
      Lesson(
        'Posture and alignment',
        2,
        'A slumped chest and a jutting chin squeeze your airway and breath. Good alignment gives the voice room.',
        [
          LessonStep('Stand with feet hip-width apart and knees soft, not locked.'),
          LessonStep('Let your arms hang. Roll your shoulders up, back and down once.'),
          LessonStep('Imagine a string lifting the crown of your head. Keep your chin level, not tucked or lifted.'),
          LessonStep('Stay like this and say "Good morning, everyone" three times.', 30),
        ],
        'Your neck feels long, your shoulders are loose, and the sentence feels easier than usual.',
        mistakes: ['Pulling the shoulders back hard like a soldier. Aim for relaxed, not stiff.', 'Pushing the chin forward when you speak.'],
      ),
      Lesson(
        'Low belly breathing',
        3,
        'Speaking on a high, shallow chest breath sounds thin and runs out fast. Low breath gives steadiness and power.',
        [
          LessonStep('Put one hand on your belly just above the belt and one on your chest.'),
          LessonStep('Breathe in through the nose for 4 counts. Only the belly hand should move out.'),
          LessonStep('Breathe out slowly on a soft "sss" for 8 counts. Feel the belly draw back in gently.'),
          LessonStep('Repeat 6 times, resting for a normal breath in between.', 60),
          LessonStep('Now exhale on "ahh" for as long as is comfortable. Aim to build to 12 seconds.', 30),
        ],
        'The chest hand barely moves and your "ahh" stays steady, not wobbly or fading.',
        mistakes: ['Lifting the shoulders on the in-breath.', 'Forcing the exhale. It should be smooth, never squeezed.'],
      ),
      Lesson(
        'Release the jaw, tongue and neck',
        3,
        'Most muffled, tight or strained voices carry hidden tension in the jaw, tongue root and neck.',
        [
          LessonStep('Gently massage the hinge of your jaw with your fingertips for 20 seconds.', 20),
          LessonStep('Let the jaw hang loose, mouth slightly open. Sway it side to side like it is on a hinge.'),
          LessonStep('Stick your tongue out and down toward your chin, relaxed, and say "ahh" five times. Then rest the tongue.'),
          LessonStep('Slowly drop your ear toward each shoulder. Hold 10 seconds each side.', 20),
          LessonStep('Yawn twice, fully. Notice how open the back of your throat feels.'),
        ],
        'Your jaw drops easily with no clicking or clamping and your throat feels open after the yawns.',
        mistakes: ['Stretching until it hurts. It should feel like a gentle release.'],
      ),
      Lesson(
        'Easy onset: start sounds gently',
        3,
        'Hard attacks (a throat "click" at the start of a word) and breathy starts both strain the voice. Easy onset is the smooth middle.',
        [
          LessonStep('Breathe in, then start "hmm" so quietly it just begins, with no click and no air leak.'),
          LessonStep('Say "ahh" with the same gentle start. Do 5 repeats.'),
          LessonStep('Say "ocean, over, always, eagle" starting each softly. Do 3 rounds.', 45),
          LessonStep('Add a short sentence: "All of us are on it." Keep the first word smooth.'),
        ],
        'There is no click in your throat on vowels and no puff of air before them.',
        mistakes: ['Whispering. You want a real voice with a soft start.'],
      ),
      Lesson(
        'Voice care and habits',
        2,
        'Dry, irritated vocal folds cost you clarity and range no matter how well you train.',
        [
          LessonStep('Sip water through the day. Aim for pale yellow urine, not constant gulping.'),
          LessonStep('Replace throat-clearing with a silent swallow or a gentle cough-free hum.'),
          LessonStep('Avoid whispering and shouting for long stretches. Both strain the voice.'),
          LessonStep('Warm up before important speaking. Rest after long talks.'),
        ],
        'You can name two habits you will change this week.',
        mistakes: ['Training through pain or hoarseness. Stop, rest, and see a doctor if it lasts more than two weeks.'],
      ),
      Lesson(
        'The 5-minute daily warm-up',
        5,
        'A short, consistent routine does more than an occasional long session.',
        [
          LessonStep('Posture check and 3 low belly breaths.', 30),
          LessonStep('Lip trills (like a motorboat) gliding low to high and back.', 45),
          LessonStep('Hum "mmm" for 5 breaths, feeling a buzz on the lips.', 45),
          LessonStep('Jaw release and 5 big yawn-sighs.', 40),
          LessonStep('Say "red leather, yellow leather" slowly 3 times, then at normal speed.', 40),
          LessonStep('Read one sentence of anything out loud with a smooth start.'),
        ],
        'Your voice feels loose and warm, and you can do it from memory.',
      ),
    ],
  ),
  Track(
    'Nasal voice',
    'Balance the air between nose and mouth so speech sounds clear and open, whether it is too nasal or too stuffed.',
    Icons.record_voice_over_rounded,
    note:
        'Two different things get called "nasal". Hypernasal: too much air escapes through the nose, so speech sounds like talking through a pinched nose or honking. Hyponasal (denasal): too little air, so you sound blocked, as with a cold. Exercises help with habits. If it has come on suddenly, is constant with a cold-like block, or you have trouble with food or liquids going up the nose, see an ENT doctor or speech-language pathologist.',
    [
      Lesson(
        'Which kind is it? The pinch test',
        3,
        'The fix depends on whether you are leaking too much or too little through the nose.',
        [
          LessonStep('Say "Go get the big cake" in a normal voice. Then pinch your nose and say it again. If it sounds the same, your oral sounds are fine.'),
          LessonStep('If it changes a lot when you pinch (or you feel buzzing in your fingers), you are sending too much air through the nose on oral sounds.'),
          LessonStep('Now say "Mommy made a mean menu" normally, then pinch. A big change is expected here: those words are meant to be nasal.'),
          LessonStep('Record yourself saying both sentences. Notice if the "Go get the big cake" one sounds nasal, or if the "mommy" one sounds blocked.'),
          LessonStep('Write down which you noticed: too much, too little, or both. Use that for the next lessons.'),
        ],
        'You can say whether you lean hypernasal, hyponasal, or mixed.',
        mistakes: ['Judging by feel only. Always listen back to a recording.'],
      ),
      Lesson(
        'Find your soft palate',
        3,
        'The soft palate (velum) is the flap at the back of the roof of your mouth. It closes off the nose on non-nasal sounds. You need to feel it to control it.',
        [
          LessonStep('Yawn and notice the roof of the back of your mouth lift. That is the soft palate rising.'),
          LessonStep('Say "ng" as in "sing" and hold it. The back of the tongue meets the soft palate and air goes out the nose.'),
          LessonStep('Slide straight from "ng" to "ah" and back: "ng-ah, ng-ah". Feel the palate lift on "ah".', 40),
          LessonStep('Look in a mirror, say "ahh" loudly and watch the small flap at the back lift.'),
          LessonStep('Repeat "ng-ah" 10 times, making the "ah" tall and open.', 30),
        ],
        'You can feel a difference between the nose-open "ng" and the mouth-open "ah".',
        mistakes: ['Pushing the tongue down hard. Let it rest.'],
      ),
      Lesson(
        'Oral vs. nasal sounds',
        4,
        'English has only three nasal sounds (m, n, ng). Everything else should stay in the mouth.',
        [
          LessonStep('Hold a mirror under your nose. Say "ma na nga" and see it fog. These should fog.'),
          LessonStep('Now say "ba da ga" and "pa ta ka". The mirror should stay clear.', 30),
          LessonStep('Say "baby", "daddy", "gaga" in a row. Mirror stays clear.'),
          LessonStep('Mix them: "bad man", "dad no", "cake mix". Fog only on the m and n.', 40),
          LessonStep('Repeat without the mirror and aim to feel the same difference.'),
        ],
        'The mirror clears on oral sounds and fogs only on m, n and ng.',
        mistakes: ['Over-pinching the nose to stop the leak. Closing at the soft palate is the goal.'],
      ),
      Lesson(
        'Oral sentences (no nasals)',
        4,
        'Sentences with no nasal consonants train the palate to stay closed for longer stretches.',
        [
          LessonStep('Read slowly: "Go get the big cake." Keep it clear at the end of the sentence.'),
          LessonStep('"Take the baby to the park." Pinch your nose, so there should be no change.'),
          LessonStep('"She sees the big yellow bird by the tree."'),
          LessonStep('"Bob picks up the red cup at the back."'),
          LessonStep('Repeat each sentence twice, once slowly and once at normal speed.', 60),
          LessonStep('Make up two of your own with no m, n or ng.'),
        ],
        'Pinching your nose changes nothing on these sentences.',
        mistakes: ['Saving effort at the ends of words, where nasal leak creeps back in.'],
      ),
      Lesson(
        'Tall open vowels',
        4,
        'Narrow, tight vowels with a closed jaw push sound up into the nose. Taller shapes direct it forward through the mouth.',
        [
          LessonStep('Open your mouth about two fingers tall. Say "ahh" with a relaxed tongue.'),
          LessonStep('Say "ah, eh, ee, oh, oo", keeping the jaw loose and dropping, not pinching, on each.', 40),
          LessonStep('Say "father, calm, blossom, hollow" with a tall "ah" and a relaxed jaw.'),
          LessonStep('Read: "Father called from the large garden." Keep every vowel open.'),
        ],
        'Your jaw moves on every vowel and the sound feels like it leaves through the mouth.',
        mistakes: ['Smiling widely, which spreads the sound. Aim for tall, not wide.'],
      ),
      Lesson(
        'Forward focus without the pinch (if you sound stuffed)',
        4,
        'If your voice is blocked (hyponasal), you need to let the nasal sounds m, n and ng actually ring.',
        [
          LessonStep('Hum "mmm" gently and feel a buzz on your lips and the bridge of your nose. Hold 8 seconds.', 20),
          LessonStep('Hum "nnn" then "ng" and feel the buzz. If you cannot, use the mirror: it should fog.'),
          LessonStep('Say "mine, nine, moon, sing, morning, ringing" with a clear buzz on each nasal sound.', 40),
          LessonStep('Then read "My name is Nina Moon" and let the m and n ring.'),
        ],
        'Your hums buzz at the lips and nose and "mine/nine" sounds natural, not blocked.',
        mistakes: ['Forcing the buzz into every vowel. Only the nasal letters should ring.'],
      ),
      Lesson(
        'Hum-to-vowel carryover',
        4,
        'A bridge from the placement you can feel to normal speech.',
        [
          LessonStep('Hum "mmm" with a buzz at the lips, then open to "ahh" keeping the same forward energy: "mmm-ah".'),
          LessonStep('Do "mmm-ah, mmm-eh, mmm-oh" five times each.', 45),
          LessonStep('Say words starting with m, then vowels: "may, me, my, mow, moo".'),
          LessonStep('Speak a sentence: "Many people make mistakes." Keep m crisp and vowels open.'),
        ],
        'The vowels after m do not turn nasal and the m still rings.',
      ),
      Lesson(
        'Carryover: read it out',
        5,
        'Real change shows in connected speech.',
        [
          LessonStep('Pick a page of anything. Read the first paragraph slowly with tall vowels.', 60),
          LessonStep('Record, then listen: mark any words that sounded nasal or blocked.'),
          LessonStep('Re-read those words alone, then back in the sentence.'),
          LessonStep('Repeat the paragraph. Compare the two recordings.'),
        ],
        'The second read sounds clearer than the first, and you can hear which words improved.',
      ),
    ],
  ),
  Track(
    'Clear speech',
    'Sharper consonants, open vowels and an active mouth, for anyone who mumbles or sounds muffled.',
    Icons.hearing_rounded,
    [
      Lesson(
        'Open the jaw',
        3,
        'A barely moving jaw is the single biggest cause of muffled speech. The mouth is the amplifier.',
        [
          LessonStep('Place two fingers vertically between your teeth. That is the openness for "ah".'),
          LessonStep('Say "ah-ee-oh-oo" with big, slow jaw movement.', 30),
          LessonStep('Read "How now brown cow" three times with an obviously big jaw.'),
          LessonStep('Read a sentence of your own, still exaggerating. Then dial back to about 70%.'),
        ],
        'Someone watching your mouth can see your words clearly, even on mute.',
        mistakes: ['Opening only the lips while the jaw stays shut.'],
      ),
      Lesson(
        'Lip shapes: round and spread',
        3,
        'Lip movement shapes vowels. Lazy lips blur "oo", "oh", "ee".',
        [
          LessonStep('Alternate "oo" (lips pushed forward and rounded) and "ee" (lips spread). 10 times.', 30),
          LessonStep('Say "we, you, who, wee, woo" with clearly different shapes.'),
          LessonStep('Read: "You will be wowed by who we are."'),
          LessonStep('Do it in a mirror and check that the lips actually change shape.'),
        ],
        'Each vowel has a visibly different mouth shape.',
      ),
      Lesson(
        'Tongue tip: t, d, n, l',
        3,
        'These sounds need the tongue tip to touch just behind the upper teeth. A sloppy tongue turns them into mush.',
        [
          LessonStep('Say "la la la la la", flicking the tongue tip up to the ridge behind your top teeth.', 20),
          LessonStep('Say "ta da ta da ta da" crisp and light.'),
          LessonStep('Read: "Little Ted told Dana the truth."'),
          LessonStep('Read: "Tonight, don\'t let the tall lad linger."'),
        ],
        'Each t, d and l is a quick, clean tap with the tongue tip, not a thick smear.',
        mistakes: ['Using the middle of the tongue instead of the tip.'],
      ),
      Lesson(
        'Back of the tongue: k and g',
        3,
        'K and G are made at the back of the mouth. When they are weak, words like "back" and "big" fade.',
        [
          LessonStep('Say "ka ga ka ga" slowly, feeling the back of the tongue touch the roof.', 20),
          LessonStep('Say "key, cake, kick, go, big, bag".'),
          LessonStep('Read: "Keep going until the garden gate is closed."'),
        ],
        'K and G sound as crisp as T and D.',
      ),
      Lesson(
        'Finish your words',
        4,
        'Dropped word endings are what makes speech sound mumbled: "firs thing" for "first thing".',
        [
          LessonStep('Say each word and release the last sound clearly: "cat, bed, back, fast, helped, asked".', 30),
          LessonStep('Read: "He asked and they helped. It was best, and just in time."'),
          LessonStep('Practice linking: say "Pick it up" so the ending t blends into the next word cleanly.'),
          LessonStep('Record 30 seconds of speech and count how many word endings you hear. Aim to hear every one.', 30),
        ],
        'You can hear every t, d, k and s at the end of words on the recording.',
        mistakes: ['Over-doing it into a robotic stop. The end is a small, light release.'],
      ),
      Lesson(
        'S and SH sounds',
        3,
        'Mushy "s" sounds (a lisp-like lean) hurt clarity. S is thin and cool, SH is wide and warm.',
        [
          LessonStep('Smile slightly and say "sss" as a thin hiss, with the tongue tip near but not touching the ridge.', 20),
          LessonStep('Round the lips and say "shh". It should feel wider and warmer.'),
          LessonStep('Alternate "see-she, so-show, sue-shoe".'),
          LessonStep('Read: "She sells seashells by the seashore."'),
        ],
        'S and SH sound clearly different and neither whistles or slushes.',
      ),
      Lesson(
        'Vowel clarity',
        4,
        'Clear vowels give words their shape. Mumbled vowels all collapse to a vague "uh".',
        [
          LessonStep('Say the five clear vowels slowly: "ah, eh, ee, oh, oo".'),
          LessonStep('Say "bat, bet, beat, bit, bite" and hear each vowel stay distinct.', 30),
          LessonStep('Read: "Sit still, he said, but she set the seat flat."'),
          LessonStep('Read a short paragraph, giving every vowel its own shape.', 45),
        ],
        'A listener could tell "bat" from "bet" from "bit" in your recording.',
      ),
      Lesson(
        'Minimal pairs',
        4,
        'Words that differ by one sound show where your mouth gets lazy.',
        [
          LessonStep('Say each pair and make them clearly different: "pat / bat", "tin / din", "cap / gap".', 40),
          LessonStep('"sip / ship", "thin / fin", "light / right".'),
          LessonStep('Record all pairs. Listen: could a stranger tell which is which?'),
          LessonStep('Pick the pair you struggled with most and repeat it 10 times slowly.', 30),
        ],
        'A listener could identify each word of every pair.',
      ),
      Lesson(
        'Tongue-twister ladder',
        5,
        'Controlled difficulty builds speed and accuracy. Slow first, then fast.',
        [
          LessonStep('"Red leather, yellow leather." Say it 5 times slowly, then 5 faster.', 45),
          LessonStep('"Unique New York." 5 slow, 5 fast.'),
          LessonStep('"She sees cheese." 5 slow, 5 fast.'),
          LessonStep('"Toy boat." Say it 10 times in a row without a slip.'),
          LessonStep('Rule: if you slip, slow down. Accuracy first, speed second.'),
        ],
        'You can do each one at a brisk pace with every sound clear.',
        mistakes: ['Racing and blurring. A fast mumble is worse than a slow clear one.'],
      ),
      Lesson(
        'Over-articulate, then dial back',
        5,
        'Over-doing clarity retrains the muscles. Then you set a natural level.',
        [
          LessonStep('Read a paragraph with deliberately big mouth shapes and every ending crisp.', 60),
          LessonStep('Record it. Listen for clarity.'),
          LessonStep('Read it again at about 70% of that effort.', 60),
          LessonStep('Record. It should sound clear and natural, not stagey.'),
        ],
        'The dialed-back version is clearly clearer than your usual speech.',
      ),
    ],
  ),
  Track(
    'Be heard',
    'Volume and projection from breath support, so you can fill a room without shouting or straining.',
    Icons.volume_up_rounded,
    [
      Lesson(
        'Find your breath support',
        3,
        'Volume comes from steady air pressure from the lower body, not from squeezing the throat.',
        [
          LessonStep('Breathe in low. Let out "sss" for as long as you can, steady and even.', 30),
          LessonStep('Do "ha-ha-ha-ha" as short pulses from the belly. Feel it bounce.', 20),
          LessonStep('Say "HEY!" firmly as if calling a friend across the street. Feel the belly engage.'),
          LessonStep('Count 1–5 loudly with each number coming from the belly, not the throat.'),
        ],
        'You feel your belly work, not your throat tighten.',
        mistakes: ['Shouting from the throat. Hoarseness is the sign to stop.'],
      ),
      Lesson(
        'Volume ladder',
        4,
        'Controlled volume steps give you a dial instead of an on/off switch.',
        [
          LessonStep('Say "Hello, I\'m here" at level 1 (a whisper-soft but voiced), then 2, 3, 4, 5 (strong but comfortable).', 60),
          LessonStep('Go back down 5 to 1.'),
          LessonStep('Now speak a sentence at level 3 as your normal baseline in a quiet room.'),
          LessonStep('Record yourself at levels 2, 3 and 4 and compare.'),
        ],
        'Each level is clearly louder than the last and your throat feels fine at level 5.',
        measure: Measure.loudness,
      ),
      Lesson(
        'Speak to the far wall',
        4,
        'People talk at the person in front of them. Presenting means talking to the back of the room.',
        [
          LessonStep('Pick a point on the far wall of the room.'),
          LessonStep('Say "Good evening, everyone. Thank you for coming." as if the wall is a person.', 30),
          LessonStep('Move to a farther spot, or go outside to a distance of about 10 steps, and repeat.'),
          LessonStep('Notice you open the mouth more, slow down, and push more air. That is projection.'),
        ],
        'You reach the far point without raising your pitch or straining your neck.',
        mistakes: ['Raising pitch to be louder. Keep the pitch steady and add breath.'],
      ),
      Lesson(
        "Don't trail off",
        3,
        'Many sentences fade at the end, losing the most important words.',
        [
          LessonStep('Say "I really believe this is the right choice" and let it fade. Notice how the end disappears.'),
          LessonStep('Say it again and keep the energy through the last word.'),
          LessonStep('Read 5 sentences, putting a small push of air on the last word of each.', 40),
          LessonStep('Record. Listen to confirm every last word is clear.'),
        ],
        'The last word of every sentence is as clear as the first.',
      ),
      Lesson(
        'Phrase on one breath',
        4,
        'Running out of air mid-phrase makes you sound unsure and quiet.',
        [
          LessonStep('Breathe in low and say a short phrase to the end of the breath: "I\'d like to start by thanking you all."'),
          LessonStep('Mark natural breaths in a paragraph with a slash at commas and full stops.'),
          LessonStep('Read it, breathing only at the slashes.', 60),
          LessonStep('Aim for a calm breath in, no gasp.'),
        ],
        'You finish each phrase with air to spare and breathe silently.',
      ),
      Lesson(
        'Microphones and rooms',
        2,
        'Good technique, a good mic and a good room make you easier to hear.',
        [
          LessonStep('Hold a handheld mic a fist-width from your mouth, pointed at the chin.'),
          LessonStep('Do not blow into it. Stay steady and speak across it, not into it.'),
          LessonStep('On calls, sit near a soft surface, use a headset or a mic close to your mouth.'),
          LessonStep('Test in the room before an event if you can.'),
        ],
        'You can set up and check your mic in under a minute.',
      ),
    ],
  ),
  Track(
    'Fuller voice',
    'A deeper, steadier, more resonant voice that still sounds like you. Built on relaxation and resonance, not forcing the pitch down.',
    Icons.graphic_eq_rounded,
    note:
        'The goal is a fuller, more resonant voice at a pitch that is healthy for you. Do not push or growl your voice lower, which strains it and sounds artificial. Typical adult male speaking pitch is roughly 85-155 Hz, but your best pitch is where the voice feels easy and rings. Keep sessions short, stop if it hurts or goes hoarse, and see a doctor or speech-language pathologist if hoarseness lasts over two weeks.',
    [
      Lesson(
        'Find your natural pitch',
        4,
        'Many people speak slightly higher than their best pitch because of tension. Find where the voice is easiest first.',
        [
          LessonStep('Say "mm-hmm" the way you do when agreeing. The low note you land on is near your natural pitch.'),
          LessonStep('Count 1 to 10 in a relaxed way, then read a short paragraph. Notice your usual pitch.'),
          LessonStep('Use "Measure" below to read your average pitch while you read.'),
          LessonStep('Do it again after a yawn-sigh. Compare the two.'),
        ],
        'You know your average speaking pitch and have felt what a more relaxed pitch is like.',
        mistakes: ['Choosing a pitch because it sounds deep rather than because it is easy to hold.'],
        measure: Measure.pitch,
      ),
      Lesson(
        'Chest hum',
        3,
        'Resonance, not just low pitch, makes a voice sound full. The chest buzz is a good guide.',
        [
          LessonStep('Put a hand on your upper chest. Hum "mmm" on a comfortable low note. Feel the buzz in your hand.', 20),
          LessonStep('Slide the hum up and down a few notes. Notice where the buzz is strongest.'),
          LessonStep('Hold the strongest note for 8 seconds, 5 times.', 40),
          LessonStep('Open the hum to "mmm-ah" and keep the same buzz.'),
        ],
        'Your hand feels a clear buzz on the "mmm" and some of it stays on the "ah".',
        mistakes: ['Pushing the pitch very low to feel more buzz. Choose the easiest strong note.'],
      ),
      Lesson(
        'Open the throat: yawn-sigh',
        3,
        'A raised larynx and a squeezed throat make the voice thin. A yawn opens and lowers the space.',
        [
          LessonStep('Take a big yawn. At the end of it, let out a relaxed sigh on "haaah" going downward.'),
          LessonStep('Do 5 of these. Notice how big and warm the sigh sounds.', 30),
          LessonStep('Start speaking right out of a yawn-sigh: "Ahh, good morning."'),
          LessonStep('Keep that open feeling for the first sentence. Repeat with 3 different sentences.'),
        ],
        'Your voice sounds warmer and larger right after the yawn-sigh.',
        mistakes: ['Tightening the throat to hold the sound lower. Let the sigh do the work.'],
      ),
      Lesson(
        'Lower, do not push',
        4,
        'You settle onto a lower pitch by relaxing downward, not by squeezing.',
        [
          LessonStep('Glide from a comfortable note down on "ahh" like a sigh. Stop at the lowest note that is still easy and clear.'),
          LessonStep('Hum that note, then say "ma" on it. Say "ma ma ma" five times.'),
          LessonStep('Say "My name is ___" on that note. Keep the throat loose.'),
          LessonStep('If it goes crackly or tight, come up two or three semitones. The easy range is the target.'),
        ],
        'The note feels easy and the sound is clear, not crackly or tight.',
        mistakes: ['Dropping into vocal fry (a creaky sound). That is not the same as a deep voice.'],
        measure: Measure.pitch,
      ),
      Lesson(
        'Pitch anchoring with counting',
        4,
        'Practice holding your new base pitch in simple speech before real sentences.',
        [
          LessonStep('On your easy note, count 1 to 10 evenly in a monotone.', 20),
          LessonStep('Count again, adding natural up and down, but landing back on your base.'),
          LessonStep('Say the days of the week and the months of the year the same way.', 40),
          LessonStep('Read three short sentences keeping the same base.'),
        ],
        'Your base pitch stays steady without forcing it.',
        mistakes: ['Going back up every time you get distracted. Check the pitch after each sentence.'],
      ),
      Lesson(
        'Resonance: ng-ah and mmm-ah',
        4,
        'Moving the buzz forward and into the chest makes the tone fuller without effort.',
        [
          LessonStep('Hum "ng" (as in "sing") and feel the buzz in the nose and the back of the mouth.'),
          LessonStep('Open to "ah": "ng-ah". Keep the sound rich but not nasal.'),
          LessonStep('Do "mmm-ah", "ng-oh", "mmm-oh" five times each.', 45),
          LessonStep('Say "Morning. My name is Mark." Keep the resonance in the m sounds.'),
        ],
        'The sound feels like it fills your chest and mouth, with no pinched nasal quality.',
      ),
      Lesson(
        'Slow down and add weight',
        4,
        'A calm, slightly slower pace and weighting key words sounds grounded and confident.',
        [
          LessonStep('Read a paragraph at your normal pace. Record it.', 30),
          LessonStep('Read it at about 80% of that speed with a small pause at each comma.', 45),
          LessonStep('Pick one key word per sentence and give it a touch more length and weight.'),
          LessonStep('Listen to both. The slower one should sound more settled.'),
        ],
        'The slower read sounds calmer and more confident.',
        measure: Measure.pace,
      ),
      Lesson(
        'Falling inflection, no upspeak',
        4,
        'Ending statements on a rising tone sounds unsure. A gentle fall sounds settled.',
        [
          LessonStep('Say "I will be there at five" with a rise at the end. Hear the doubt.'),
          LessonStep('Say it again and let the last word fall slightly.'),
          LessonStep('Read 8 statements, ending each with a slight fall.', 45),
          LessonStep('Use rises only for real questions.'),
        ],
        'Your statements sound final and your questions still sound like questions.',
        mistakes: ['Falling too far into a grumble. A small fall is enough.'],
      ),
      Lesson(
        'Avoid vocal fry and pressed voice',
        3,
        'Creak at the ends of sentences and a squeezed voice both tire the voice and reduce clarity.',
        [
          LessonStep('Say a sentence and listen for a creaky, rattling sound at the end. That is fry.'),
          LessonStep('Keep a little more air and energy through the last word so it stays a clean tone.'),
          LessonStep('Read 5 sentences, keeping the end of each clean and resonant.', 40),
          LessonStep('If your throat feels tight or tired, stop and take a break.'),
        ],
        'No creak at the ends of sentences and no tightness in the throat.',
      ),
      Lesson(
        'Carry it into conversation',
        6,
        'Transfer in steps: reading, then scripted speaking, then spontaneous speaking.',
        [
          LessonStep('Level 1: read a paragraph aloud with your base pitch and open resonance.', 60),
          LessonStep('Level 2: say a memorized 30-second introduction of yourself.'),
          LessonStep('Level 3: talk about your day for one minute with no script.', 60),
          LessonStep('Record all three and listen. Note where you slip and which level is hardest.'),
          LessonStep('Practice the hardest level again tomorrow.'),
        ],
        'Your voice stays steady and full through all three levels.',
      ),
    ],
  ),
  Track(
    'Presenting',
    'Open strongly, pace yourself, use pauses and emphasis, and stay calm in front of people.',
    Icons.campaign_rounded,
    [
      Lesson(
        'A strong opening',
        4,
        'Audiences decide quickly. Your first 15 seconds set the tone.',
        [
          LessonStep('Write a one-sentence opener: a short story, a surprising fact or a bold question.'),
          LessonStep('Say it out loud 3 times, slowly, with a full stop and a pause after it.', 30),
          LessonStep('Avoid "so", "um" and "today I\'m going to talk about".'),
          LessonStep('Practice standing, with a steady voice and open posture.'),
        ],
        'You can deliver your opener with no filler and a calm voice.',
      ),
      Lesson(
        'Pace: aim for about 150 words a minute',
        4,
        'Nerves speed us up. A steady pace helps people follow and makes you sound in control.',
        [
          LessonStep('Read a paragraph for one minute. Count the words. 130 to 160 is comfortable.', 60),
          LessonStep('If you are over 170, slow down by taking short pauses at commas.'),
          LessonStep('If you are under 110, add energy and trim long gaps.'),
          LessonStep('Use the Measure card to see your pace.'),
        ],
        'You can hit a steady, comfortable pace on demand.',
        measure: Measure.pace,
      ),
      Lesson(
        'Pause power',
        3,
        'Silence is a tool. It lets points land and gives you time to breathe.',
        [
          LessonStep('Say a key sentence, then count "one-one-thousand, two-one-thousand" in your head.'),
          LessonStep('Pause at every full stop for a 2 count, and at commas for a 1 count.', 40),
          LessonStep('Pause before and after the most important point.'),
          LessonStep('Record and listen. Pauses feel longer to you than to the audience.'),
        ],
        'Your pauses sound deliberate, not nervous.',
        mistakes: ['Filling every gap with "um" or "so".'],
      ),
      Lesson(
        'Emphasis: stress the key word',
        4,
        'Changing which word you stress changes the meaning. Use it on purpose.',
        [
          LessonStep('Say "I never said he stole the money" five times, stressing a different word each time. Notice the meaning change.', 45),
          LessonStep('Take a sentence from your talk and mark the 1-2 words that matter.'),
          LessonStep('Say it, making those words a bit louder, longer or higher.'),
          LessonStep('Do not stress every word, or none stand out.'),
        ],
        'Listeners could tell which words matter most.',
      ),
      Lesson(
        'Vocal variety',
        4,
        'A flat voice loses attention. Vary pitch, pace and volume.',
        [
          LessonStep('Read a paragraph in a flat monotone. Hear how dull it sounds.', 30),
          LessonStep('Read it again, varying the pitch up and down on key phrases.'),
          LessonStep('Read it again, speeding up on lists and slowing down on important points.'),
          LessonStep('Read it a final time, dropping the volume slightly for a key line.'),
        ],
        'Your reading sounds like talking to a person, not reciting.',
      ),
      Lesson(
        'Cut the filler words',
        4,
        '"Um", "like" and "you know" tell the audience you are unsure. A silent pause does the same job better.',
        [
          LessonStep('Record 60 seconds on any topic and count your fillers.', 60),
          LessonStep('Practice replacing each filler with a silent pause and a breath.'),
          LessonStep('Do the same topic again. Count again. Aim to cut the count in half.', 60),
          LessonStep('Repeat on a new topic tomorrow.'),
        ],
        'Your filler count drops and the pauses feel natural.',
      ),
      Lesson(
        'Calm your nerves',
        4,
        'Nerves are physical. Breathing and preparation calm the body.',
        [
          LessonStep('Do box breathing: in 4, hold 4, out 4, hold 4. Repeat 5 times.', 80),
          LessonStep('Do a physiological sigh: two quick breaths in through the nose, one long breath out through the mouth. 3 times.', 30),
          LessonStep('Shake out your arms and legs for 10 seconds.', 10),
          LessonStep('Say your opening line twice, slowly. Then begin.'),
        ],
        'Your heart rate drops and your voice feels steadier.',
      ),
      Lesson(
        'Eye contact and body',
        3,
        'Your voice follows your body. Open posture and real eye contact help the voice.',
        [
          LessonStep('Pick 3 or 4 people or spots in the room.'),
          LessonStep('Deliver one full sentence to one person, then move to the next.'),
          LessonStep('Keep your feet planted, hands relaxed, and gestures open.', 45),
          LessonStep('Practice it in front of a mirror or with a friend.'),
        ],
        'You finish each thought looking at someone, not at the floor or your notes.',
      ),
      Lesson(
        'Questions, calls and video',
        4,
        'Not every moment is a stage. Q and A, calls and video need their own habits.',
        [
          LessonStep('For questions: pause, repeat the question briefly, then answer in 20 seconds or less.'),
          LessonStep('For calls: stand up or sit tall, smile slightly, and speak a little slower than usual.'),
          LessonStep('For video: look at the camera lens when making key points.'),
          LessonStep('Practice answering 3 questions out loud, with a pause before each.', 60),
        ],
        'Your answers are short, calm and clear.',
      ),
      Lesson(
        'Full rehearsal and review',
        6,
        'Recording and reviewing is the fastest way to improve.',
        [
          LessonStep('Deliver your talk, or a 2 minute version, standing up.', 120),
          LessonStep('Record it. Watch or listen once with a score for pace, clarity, pauses and filler words.'),
          LessonStep('Pick the one thing to improve. Re-deliver the same section fixing only that.'),
          LessonStep('Repeat tomorrow with the next fix.'),
        ],
        'You can name one clear improvement and one thing you did well.',
      ),
    ],
  ),
];
