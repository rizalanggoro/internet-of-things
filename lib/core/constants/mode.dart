import 'package:internet_of_things/core/models/mode.dart';

class ConstantMode {
  static final values = <ModelMode>[
    ModelMode(
      id: 0,
      title: 'Static',
      subtitle: 'No blinking. Just plain old static light.',
    ),
    ModelMode(
      id: 1,
      title: 'Blink',
      subtitle: 'Normal blinking. 50% on/off time.',
    ),
    ModelMode(
      id: 2,
      title: 'Breath',
      subtitle:
          'Does the "standby-breathing" of well known i-Devices. Fixed Speed.',
    ),
    ModelMode(
      id: 3,
      title: 'Color Wipe',
      subtitle:
          'Lights all LEDs after each other up. Then turns them in that order off. Repeat.',
    ),
    // ModelMode(
    //   id: 4,
    //   title: 'Color Wipe Inverse',
    //   subtitle: 'Same as Color Wipe, except swaps on/off colors.',
    // ),
    ModelMode(
      id: 5,
      title: 'Color Wipe Reverse',
      subtitle:
          'Lights all LEDs after each other up. Then turns them in reverse order off. Repeat.',
    ),
    // ModelMode(
    //   id: 6,
    //   title: 'Color Wipe Reverse Inverse',
    //   subtitle: 'Same as Color Wipe Reverse, except swaps on/off colors.',
    // ),
    ModelMode(
      id: 7,
      title: 'Color Wipe Random',
      subtitle:
          'Turns all LEDs after each other to a random color. Then starts over with another color.',
    ),
    ModelMode(
      id: 8,
      title: 'Random Color',
      subtitle:
          'Lights all LEDs in one random color up. Then switches them to the next random color.',
    ),
    // ModelMode(
    //   id: 9,
    //   title: 'Single Dynamic',
    //   subtitle:
    //       'Lights every LED in a random color. Changes one random LED after the other to a random color.',
    // ),
    // ModelMode(
    //   id: 10,
    //   title: 'Multi Dynamic',
    //   subtitle:
    //       'Lights every LED in a random color. Changes all LED at the same time to new random colors.',
    // ),
    ModelMode(
      id: 11,
      title: 'Rainbow',
      subtitle: 'Cycles all LEDs at once through a rainbow.',
    ),
    ModelMode(
      id: 12,
      title: 'Rainbow Cycle',
      subtitle: 'Cycles a rainbow over the entire string of LEDs.',
    ),
    ModelMode(
      id: 13,
      title: 'Scan',
      subtitle: 'Runs a single pixel back and forth.',
    ),
    ModelMode(
      id: 14,
      title: 'Dual Scan',
      subtitle: 'Runs two pixel back and forth in opposite directions.',
    ),
    ModelMode(
      id: 15,
      title: 'Fade',
      subtitle: 'Fades the LEDs on and (almost) off again.',
    ),
    ModelMode(
      id: 16,
      title: 'Theater Chase',
      subtitle:
          'Theatre-style crawling lights. Inspired by the Adafruit examples.',
    ),
    ModelMode(
      id: 17,
      title: 'Theater Chase Rainbow',
      subtitle:
          'Theatre-style crawling lights with rainbow effect. Inspired by the Adafruit examples.',
    ),
    ModelMode(
      id: 18,
      title: 'Running Lights',
      subtitle: 'Running lights effect with smooth sine transition.',
    ),
    ModelMode(
      id: 19,
      title: 'Twinkle',
      subtitle: 'Blink several LEDs on, reset, repeat.',
    ),
    ModelMode(
      id: 20,
      title: 'Twinkle Random',
      subtitle: 'Blink several LEDs in random colors on, reset, repeat.',
    ),
    ModelMode(
      id: 21,
      title: 'Twinkle Fade',
      subtitle: 'Blink several LEDs on, fading out.',
    ),
    ModelMode(
      id: 22,
      title: 'Twinkle Fade Random',
      subtitle: 'Blink several LEDs in random colors on, fading out.',
    ),
    ModelMode(
      id: 23,
      title: 'Sparkle',
      subtitle: 'Blinks one LED at a time.',
    ),
    // ModelMode(
    //   id: 24,
    //   title: 'Flash Sparkle',
    //   subtitle:
    //       'Lights all LEDs in the selected color. Flashes single white pixels randomly.',
    // ),
    // ModelMode(
    //   id: 25,
    //   title: 'Hyper Sparkle',
    //   subtitle: 'Like flash sparkle. With more flash.',
    // ),
    // ModelMode(
    //   id: 26,
    //   title: 'Strobe',
    //   subtitle: 'Classic Strobe effect.',
    // ),
    // ModelMode(
    //   id: 27,
    //   title: 'Strobe Rainbow',
    //   subtitle: 'Classic Strobe effect. Cycling through the rainbow.',
    // ),
    // ModelMode(
    //   id: 28,
    //   title: 'Multi Strobe',
    //   subtitle:
    //       'Strobe effect with different strobe count and pause, controlled by speed setting.',
    // ),
    ModelMode(
      id: 29,
      title: 'Blink Rainbow',
      subtitle: 'Classic Blink effect. Cycling through the rainbow.',
    ),
    // ModelMode(
    //   id: 30,
    //   title: 'Chase White',
    //   subtitle: 'Color running on white.',
    // ),
    // ModelMode(
    //   id: 31,
    //   title: 'Chase Color',
    //   subtitle: 'White running on color.',
    // ),
    // ModelMode(
    //   id: 32,
    //   title: 'Chase Random',
    //   subtitle: 'White running followed by random color.',
    // ),
    // ModelMode(
    //   id: 33,
    //   title: 'Chase Rainbow',
    //   subtitle: 'White running on rainbow.',
    // ),
    // ModelMode(
    //   id: 34,
    //   title: 'Chase Flash',
    //   subtitle: 'White flashes running on color.',
    // ),
    // ModelMode(
    //   id: 35,
    //   title: 'Chase Flash Random',
    //   subtitle: 'White flashes running, followed by random color.',
    // ),
    // ModelMode(
    //   id: 36,
    //   title: 'Chase Rainbow White',
    //   subtitle: 'Rainbow running on white.',
    // ),
    // ModelMode(
    //   id: 37,
    //   title: 'Chase Blackout',
    //   subtitle: 'Black running on color.',
    // ),
    // ModelMode(
    //   id: 38,
    //   title: 'Chase Blackout Rainbow',
    //   subtitle: 'Black running on rainbow.',
    // ),
    ModelMode(
      id: 39,
      title: 'Color Sweep Random',
      subtitle:
          'Random color introduced alternating from start and end of strip.',
    ),
    ModelMode(
      id: 40,
      title: 'Running Color',
      subtitle: 'Alternating color/white pixels running.',
    ),
    // ModelMode(
    //   id: 41,
    //   title: 'Running Red Blue',
    //   subtitle: 'Alternating red/blue pixels running.',
    // ),
    ModelMode(
      id: 42,
      title: 'Running Random',
      subtitle: 'Random colored pixels running.',
    ),
    ModelMode(
      id: 43,
      title: 'Larson Scanner',
      subtitle: 'K.I.T.T.',
    ),
    // ModelMode(
    //   id: 44,
    //   title: 'Comet',
    //   subtitle: 'Firing comets from one end.',
    // ),
    // ModelMode(
    //   id: 45,
    //   title: 'Fireworks',
    //   subtitle: 'Firework sparks.',
    // ),
    // ModelMode(
    //   id: 46,
    //   title: 'Fireworks Random',
    //   subtitle: 'Random colored firework sparks.',
    // ),
    // ModelMode(
    //   id: 47,
    //   title: 'Merry Christmas',
    //   subtitle: 'Alternating green/red pixels running.',
    // ),
    // ModelMode(
    //   id: 48,
    //   title: 'Fire Flicker',
    //   subtitle: 'Fire flickering effect. Like in harsh wind.',
    // ),
    ModelMode(
      id: 49,
      title: 'Fire Flicker (soft)',
      subtitle: 'Fire flickering effect. Runs slower/softer.',
    ),
    // ModelMode(
    //   id: 50,
    //   title: 'Fire Flicker (intense)',
    //   subtitle: 'Fire flickering effect. More range of color.',
    // ),
    // ModelMode(
    //   id: 51,
    //   title: 'Circus Combustus',
    //   subtitle: 'Alternating white/red/black pixels running.',
    // ),
    // ModelMode(
    //   id: 52,
    //   title: 'Halloween',
    //   subtitle: 'Alternating orange/purple pixels running.',
    // ),
    // ModelMode(
    //   id: 53,
    //   title: 'Bicolor Chase',
    //   subtitle: 'Two LEDs running on a background color.',
    // ),
    // ModelMode(
    //   id: 54,
    //   title: 'Tricolor Chase',
    //   subtitle: 'Alternating three color pixels running.',
    // ),
    ModelMode(
      id: 55,
      title: 'TwinkleFOX',
      subtitle: 'Lights fading in and out randomly.',
    ),
  ];

  static final matrixValues = <ModelMode>[
    ...values,
    ModelMode(id: 57, title: 'Clock'),
  ];
}
