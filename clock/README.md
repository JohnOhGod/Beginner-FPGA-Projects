# A Basic 24 Hour Clock using a Nexys A7
## 1. Goal
The goal of this project is to build a basic 24 hour clock in the HH:MM:SS format. A basic alarm has been added, which will flash one of the RGB LEDs between different colors every second while the minutes digit is 1. (This is trivial to modify - making it "ring" only during a specific hour or changing which minute should be used simply requires editing an IF statement slightly). This project demos clock dividers, basic FSMs, and behavioral Verilog logic.

This project can easily be adapted for another FPGA with the required 7-Segment displays; a Basys will be able to do the minutes/seconds columns with almost no changes (though it doesn't have enough SSDs for hours - only 4 displays). However, some FPGAs may use Common Cathode SSDs and have a different clock speed, which will require adjustments below.

## 2. Hardware Description
### A. Clock
The input clock is a 100 MHz clock input from pin E3 on the Nexys A7-100T. This is used to generate a pulse per second via a clock divider.
### B. 7-Segment Displays
The Nexys A7-100T includes 8 onboard common-anode 7-segment displays. Due to the internal circuitry, each 7-segment display is enabled when its anode is LOW, not high. The segments are enabled when their values are LOW as well.
### C. LED Alarm
The Nexys contains 2 RGB LEDs. Each color is mapped to a seperate output pin. While the alarm "goes off", the LED cycles through the 3 colors changing every second.
## 3. Code Sections


## 4. Implementation Details
