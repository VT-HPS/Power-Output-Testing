function [rpm, torque, power, moi, torqueFriction, times] = modelTrainerData(trainerData, radius, si)
    % MODELTRAINERDATA - Train a torque model from trainer data to find MOI
    %   [rpm, torque, power, moi, torqueFriction, times] = MODELTRAINERDATA(trainerData, radius, si)
    %
    %   This function processes trainer data, computes relevant torque-related parameters, and trains
    %   a torque model based on linear regression. The resulting model parameters can be used for torque
    %   prediction in rotational systems.
    %
    %   Inputs:
    %       trainerData - File path to the trainer data in CSV format, or
    %       table with data 
    %       radius - Radius of the rotating system.
    %       si - (optional) Start index for the linear fit, 
    %   pick to avoid erroneous start data (default = 1).
    %
    %   Outputs:
    %       rpm - Rotations per minute (derived from the enhanced speed
    %       data).
    %       torque - Torque calculated from power and angular velocity.
    %       power - Power data from the trainer.
    %       moi - Moment of inertia (derived from linear fit of torque vs.
    %       angular acceleration).
    %       torqueFriction - Friction torque (derived from linear fit of 
    %       torque vs. angular acceleration).
    %       times - Time vector corresponding to the trainer data.
    %
    %   Example:
    %       trainerData = 'path/to/trainerData.csv';
    %       radius = 0.1; % Example radius value
    %       si = 10; % Example start index
    %       [rpm, torque, power, moi, torqueFriction, times] = MODELTRAINERDATA(trainerData, radius, si);
    %
    %   See also:
    %       READTABLE, GRADIENT, FITLM.
    %
    %   Requires:
    %       Statistics and Machine Learning Toolbox.

    if nargin < 3
        si = 1;
    end
   
    if ~isa(trainerData,'table')
        data = readtable(trainerData);
    else
        data = trainerData;
    end

    % Filter NaN values for power and speed
    data.power(isnan(data.power)) = 0;
    data.enhancedSpeed(isnan(data.enhancedSpeed)) = 0;
    power = data.power;
    
    % Compute omega, rpm, alpha, and torque (filter NaN and Inf for torque)
    omega = data.enhancedSpeed ./ radius;
    rpm = omega .* (30/pi);
    alpha = gradient(omega); % time step is 1
    torque = data.power ./ omega;
    torque(isnan(torque) | isinf(torque)) = 0;
    
    % Compute the vector of times
    pwrtimedata = datetime(extractBefore(convertCharsToStrings(data.timestamp),".000Z"));
    times = (0:1:seconds(pwrtimedata(end) - pwrtimedata(1)))';
    
    % Create a linear fit starting from data peak    
    mdl = fitlm(alpha(si:end), torque(si:end));
    linearFit = mdl.Coefficients.Estimate;
    
    % Map alpha to derivedTorque
    moi = linearFit(2);
    torqueFriction = linearFit(1);

end