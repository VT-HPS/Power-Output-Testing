# Power-Output-Testing
Code for pilot power output testing and thrust determination

To set up do the following:
- clone the repo
- connect arduino on COM3, reading Digital Pin 9
- configure `duration` and `timeStep` in `PowerOutputTesting.m` (add about 5 seconds extra to duration for safety)
- ensure trainer, magnets and reed switch are setup correctly

Find the moment of interia of the test rig:
  1. start the trainer
  2. start recording data in MATLAB (i.e. hit start)
  3. start pedaling
  4. monitor live plot for any erroneous indications
  5. test will conclude automatically
  6. **save the workspace variables** from `PowerOutputTesting.m` to `PowerOutputTesting.mat` in the same directory
  7. run `MomentOFInertiaCalc.m` and plug output value back into `PowerOutpuTesting.m` for `MOI`
 
Then run the underwater test by starting the code *before* starting to pedal. 
