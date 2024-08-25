This still needs a appropriated readme.
A overview can be viewed at https://www.youtube.com/watch?v=ua8J6P4wYl0

This is a spin-off and total rewrite of **Yaapu Telemetry Script and Widget** aimed to low capacity (processor/ram) radios and color ones as well using Ardupilot's CRSF pass-through. Target system is EdgeTX. Target vehicle is copter. Aimed to ardupilot but can be used generically.

Color radios works in EdgeTX emulation and I hope it will work in real radios. (I appreciate feedback on this!)
  

## Installation
Click 'Code' button then 'Download ZIP'. Extract to some folder. Enter (cd into) downloaded SD directory. Copy folders (SCRIPTS and SOUNDS) to the root of radio's SD card (copy also WIDGETS if you have a color screen radio). Activate script in the radio.  
**Attention**: radio will generate the compiled .luac files upon first activation. You may need to power cycle radio and activate script (TELE key) some times until all luac files are generated sucefully specially in low memory radios. There are a 'compiledluacs' directories with compiled luac's for TX12.
**Attention**: I had many memory issues using older EDgeTX versions that was surpased after updating EdgeTX to 2.9.4

![Download](https://raw.githubusercontent.com/Rodrigo-NH/SmallTelemetryScript/master/readmeassets/download.JPG)  


## Use

- Tele key to enter script.
- RTN key to enter/exit menu options
- Go to 'Telemetry settings -> CRSF Telemetry: ON' to use Yaapu Telemetry (this setting needs the script or radio to be restarted)
- For color screens: Widget needs to run in fullscreen mode
- Rotary switch to change screens. When you reach the Yaapu messages screen, behaviour changes to: rotary switch scrolls messages up/down; ENTER clear messages; RTN key first press reset scroll and 2nd press to return 1st screen (it just returns to 1st screen if you're not scrolling)
- You can save ardupilot missions to 'SCRIPTS -> TELEMETRY -> stelem -> missions' to load and use in the map
- Long press TELE key anytime to ENTER map (except when in messages screen). Use RTN key in map to enter map options etc
- Includes a 'Velocity' mode for heading (Does not depend on the compass to work). Check 'Hdg vel.min distance' (threshold) and 'Hdg vel. time' and 'Hdg vel. debug sound' to fine tune this as you like.
- Map options, including Goto/autoGoto options, works just like manual navigation in handheld GPSes. So, you can load ardupilot missions and use navigation even if not using ardupilot.


## Contribution

If you test it and able to report: Open an issue reporting which radio (and system EdgeTX or OpenTX and version) you tested it and results so it can be added to the list. If you don't have a github account you can send me a direct message -> https://discuss.ardupilot.org/u/rodrigonh76/summary  


## Tested radios/EdgeTX/ardupilot versions
Radiomaster TX12 - EdgeTX 2.9.4 - Ardupilot 4.4.4

