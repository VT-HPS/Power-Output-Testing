# Power-Output-Testing

Code repository for pilot power output testing and thrust determination.

## Serial Port Setup

Follow these steps to set up the system using the serial port:

1. Clone the repository.
2. Open MATLAB and Arduino IDE.
3. Plug in the Arduino into your machine.
4. Connect the Arduino to COM3 (or another port, adjusting the code accordingly).
5. Open `Arduino_Power_Code.ino` in the Arduino IDE.
6. Under `Tools`, ensure that `Board` is set to `Arduino Uno`, and under `Port`, make sure it is set to `COM3`.
7. Upload `Arduino_Power_Code.ino` to the Arduino.
8. Open `SerialPortCode.m` in MATLAB.
9. Configure the `duration` in `SerialPortCode.m` to be approximately 2 minutes, depending on the test (add 5 seconds for safety).
10. Once `SerialPortCode.m` is started, enter the data file name (format: initials_#.txt), and when ready, press the space bar to start recording data.

Run the test by starting the code *before* starting to pedal.

## Moment of Inertia Calculation

To find the moment of inertia (MOI) of the test rig:

1. Set up using the serial port as described above.
2. Monitor the live plot for any erroneous indications.
3. Plug data from the trainer ('Record' field) .csv into `modelTrainerData.m` to get MOI and torqueFriction.

## Data Structure

Data from Onland Testing is available in `OnlandTesting` in `OnlandTestingData.mat`

```matlab
load OnlandTestingData
OnlandTesting = 

  struct with fields:

     arduinoData: [1×1 struct]
     trainerData: [1×1 struct]
    trainerConsts: [17×2 table]
```

- `arduinoData`: A struct with data from the Arduino, organized by initials and trial number. `OnlandTesting.arduinoData.Initials{trial#}` returns a vector of revTimes.
  
- `trainerData`: A struct with data from the trainer, organized in the same way as `arduinoData`.
  
- `trainerConsts`: A table with the MOI and torqueFriction values for each run as calculated by `Functions\modelTrainerData.m`.

_A binary for water testing will be added once complete_

## Scripts and Functions

-  `Arduino_Power_Code.ino`
Arduino code to read button presses and send activation states to MATLAB through serial communication.

-  `SerialPortCode.m`
MATLAB code to read serial data from Arduino using the `serialport` object, collect and visualize data, and save it to a file.

-  `derivative.m`
MATLAB function to compute the derivative of discrete x and y data using various methods.

-  `deriveValues.m`
MATLAB function to calculate derived parameters (rpm, torque, power) from revolution times data.

-  `modelTrainerData.m`
MATLAB function to process trainer data, compute relevant torque-related parameters, and train a torque model based on linear regression.

-  `readDataFolder.m`
MATLAB function to read data from files in subfolders of a specified directory.

-  `rpmGen.m`
MATLAB function to convert revolution times to rpm and time stamps.

-  `PowerAnalysis.m`
MATLAB script for loading, processing, and analyzing data from Onland Testing, including visualizing raw data and derived values.

-  `makeBinaryFiles.m`
MATLAB script to read data from folders, calculate MOI and torqueFriction, and save the processed data as a binary file.

## Notes 
- `modelTrainerData.m` requires the [Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html).
- `deriveValues.m` requires the [Signal Processing Toolbox](https://www.mathworks.com/products/signal.html)
- to reference functions in another folder you can use the following snippet:
```matlab
oldpath = path;
% assuming your script is in another folder
path(oldpath,'..\Functions')
% your code
path(oldpath)
```