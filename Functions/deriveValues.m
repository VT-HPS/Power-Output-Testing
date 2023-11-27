function [times, rpm, torque, power] = deriveValues(revTimes, moi, torqueFriction)
    % DERIVEVALUES - Calculate derived parameters (rpm, torque, power) from revolution times.
    %
    %   [times, rpm, torque, power] = DERIVEVALUES(revTimes, moi, torqueFriction)
    %
    %   This function processes revolution times data to derive rotational parameters such as
    %   rotations per minute (rpm), torque, and power. It incorporates a developed model from a
    %   previous analysis to enhance the accuracy of the derived values.
    %
    %   Inputs:
    %       revTimes - Vector of revolution times (in seconds) or a matrix with time data in columns.
    %       moi - Moment of inertia.
    %       torqueFriction - Friction torque.
    %
    %   Outputs:
    %       times - Time vector corresponding to the calculated values.
    %       rpm - Rotations per minute.
    %       torque - Torque (calculated based on a developed model).
    %       power - Power (calculated as the product of torque and angular velocity).
    %
    %   Example:
    %       revTimes = [0, 1, 2, 3, 4];
    %       moi = 2.5;
    %       torqueFriction = 0.1;
    %       [times, rpm, torque, power] = DERIVEVALUES(revTimes, moi, torqueFriction);
    %
    %   Notes:
    %       - The function incorporates a developed model for torque calculation.
    %       - Revolution times data can be provided as a vector or a matrix with time data in columns.
    %       - Ensure that the moment of inertia (moi) and friction torque (torqueFriction) are accurately
    %         specified for meaningful results (using output from MODELTRAINERDATA)
    %
    %   See also:
    %       RPMGEN, SGOLAYFILT, DERIVATIVE, MODELTRAINERDATA
    %
    %   Requires:
    %       Signal Processing Toolbox.


narginchk(3, 3);

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