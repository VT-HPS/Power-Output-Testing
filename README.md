# Power-Output-Testing
Code for pilot power output testing and thrust determination

To set up using serial port do the following:
- Clone the repo
- Open MATLAB and Arduino IDE
- Plug in arduino into your machine
- Connect arduino to COM3 (or another but will need to switch code if not COM3)
- Open `Arduino_Power_Code.ino` in the Arduino IDE
- Under `Tools` make sure that `Board` is set to `Arduino Uno` and under `Port` make sure it is set to `COM3`
- Upload `Arduino_Power_Code.ino` to Arduino
- Open `SerialPortCode.m` in MATLAB
- Configure `duration` in `SerialPortCode.m` to be about 2 minutes depending on test (add 5 seconds extra for safety)
- Once `SerialPortCode.m` is started enter the data file name (initals_#.txt) and then once the pilot is read press the space bar to start recording data

Run the test by starting the code *before* starting to pedal. 
  
<!-- 
To set up do the following:
- clone the repo
- open MATLAB
- plugin arduino (uno) into your machine 
- connect arduino on COM3, reading Digital Pin 8
- configure `duration` and `timeStep` in `PowerOutputTesting.m` (add about 5 seconds extra to duration for safety)
- ensure trainer, magnets and reed switch are setup correctly
 -->

Find the moment of interia of the test rig:
- set up using the serial port
- monitor live plot for any erroneous indications
- plug data from trainer ('Record' field) .csv into `modelTrainerData.m` to get MOI and torqueFriction

**Data from Onland Testing is available in the struct in OnlandAnalysisData.mat**