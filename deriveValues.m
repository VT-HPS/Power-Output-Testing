function [rpm, torque, power, times] = deriveValues(revTimes, moi, torqueFriction)
narginchk(2, 3);
if nargin < 3
    useInterp = false;
end

if size(revTimes, 2) > 1
    % Matrix input, process each column
    rpm = zeros(size(revTimes));
    torque = zeros(size(revTimes));
    power = zeros(size(revTimes));
    times = zeros(size(revTimes));

    for col = 1:size(revTimes, 2)
        [rpm(:, col), torque(:, col), power(:, col), times(:, col)] ...
            = deriveValues(revTimes(:, col), moi, useInterp);
    end
else
    % Vector input, perform calculations
    [rpm, times] = rpmGen(revTimes);
    rpm(isnan(rpm) | isinf(rpm)) = 0;

    omega = rpm .* (pi/30);


    rpm = 60 ./ [0; diff(times)];
    rpm(isinf(rpm)) = 0;

    % Use the Model developed in SingleRunAnalysis.m
    % Stage 1 Processing
    processedOmega = sgolayfilt(omega, 3, 11);
    % Differentiation
    alpha = derivative(processedOmega, times, "linReg", 5);
    % Stage 2 Processing
    processedAlpha = sgolayfilt(alpha, 3, 11);
    % Model - Using a simple linear fit
    torque = moi.*processedAlpha + torqueFriction;
    % Stage 3 Processing
    processedTorque = sgolayfilt(torque, 3, 11);

    % Power Computation (can use raw OR processed omega)
    power = processedTorque .* processedOmega;

end
end