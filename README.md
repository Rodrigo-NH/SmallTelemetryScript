This is a spin-off of **Yaapu Telemetry Script and Widget** aimed to low capacity (processor/ram) radios using Ardupilot's CRSF passthrough. Target screen is 128x64 but can be explanded. Target radio is TX12 but may work with other radios. Target system is EdgeTX but may work in OpenTX. Target vehicle is copter. Script is functional but this is a WIP.   
  


## Rationale
I had some important (blocking) issues trying to use Yaapu Telemetry on TX12. Tried to work around the issues (https://github.com/yaapu/FrskyTelemetryScript/issues/208) without success. Moreover, graphical elements seemed too 'laggy' with freezes the times it (somewhat) worked. It's probably that actual screens (and code as whole) are too heavy for a small radio like TX12.

## Installation
Click 'Code' button then 'Download ZIP'. Enter (cd into) downloaded SD directory. Copy folders (SCRIPTS and SOUNDS) to the root of radio's SD card. Activate script in the radio. Radio will generate the .luac files upon first activation, power cycle the radio if it throws any error at this stage.

![Download](https://raw.githubusercontent.com/Rodrigo-NH/SmallTelemetryScript/master/readmeassets/download.JPG)  


## Use

Rottary switch to change normal screens. ENTER to enter main menu.

Screen containing basic info and basic graphical elements (Attitude indicator; variometer; telemetry heartbeat and home arrow) 'h:' and 'y:' near home arrow are home distance and yaw respectively. Emergency to Error messages will be replicated at bottom of screen.  
The graphical elements are coded in a way making easy to customize position and size. Can be used to develop new screens or for bigger screens.    
 

![Main screen](https://raw.githubusercontent.com/Rodrigo-NH/SmallTelemetryScript/master/readmeassets/menu1.JPG)  

Screen containing only messages in sequence. Pressing RTN from this screen will clear screen.  

![Messages](https://raw.githubusercontent.com/Rodrigo-NH/SmallTelemetryScript/master/readmeassets/menu2.JPG)  

Some configuration options  
Cell voltage: Display total battery voltage or cell voltage  
Number of cells: To be able to calculate the above option correctly  
Variometer clip val: The (V. speed) value that will make variometer cursor to clip top or bottom  
Att. indicator scale: from 90 to 180. Larger values will smooth real angle. e.g. 180 will make the horizon line near the top/limit if drone is nose down.  
Msg log: Will log messages to SD card in ../logs directory  
Sounds: Enable/Disable script sounds. Actully just two sound files (relative to error messages) 



 ## Current
 Testing a map screen (WIP). You can enter map pressing TELE button. ENTER will load map specific options (testing).  
 Sample "/SCRIPTS/TELEMETRY/stelem/mission.txt" included  
 You can load your own Mission Planner TXT file to "/SCRIPTS/TELEMETRY/stelem/mission.txt" (override the current file)  
 
![Map test](https://raw.githubusercontent.com/Rodrigo-NH/SmallTelemetryScript/master/readmeassets/mapwip.jpg)


## Contribution

If you test it and able to report: Open an issue reporting which radio (and system EdgeTX or OpenTX and version) you tested it and results so it can be added to the list. If you don't have a github account you can send me a direct message -> https://discuss.ardupilot.org/u/rodrigonh76/summary  

![Screenshots](https://raw.githubusercontent.com/Rodrigo-NH/SmallTelemetryScript/master/readmeassets/sshots.JPG)  
## Tested radios
Radiomaster TX12 - EdgeTX 2.8