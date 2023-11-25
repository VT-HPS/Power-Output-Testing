function [rpm, torque, power, moi, torqueFriction, times] = modelTrainerData(trainerData, radius, si)
% **requires Stats & ML toolbox
data = readtable(trainerData);

% Filter NaN values for power and speed
data.power(isnan(data.power)) = 0;
data.enhancedSpeed(isnan(data.enhancedSpeed)) = 0;
power = data.power;

% Compute omega, rpm, alpha, and torque (filter NaN and Inf for torque)
omega = data.enhancedSpeed ./ radius;
rpm = omega .* (30/pi);
alpha = gradient(omega);
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