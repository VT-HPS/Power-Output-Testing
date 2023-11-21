function [rpm, torque, power, times] = deriveValues(revTimes, moi, useInterp)
    % DERIVEVALUES Calculate angular velocity, torque, and power from revolution times and moment of inertia.
    %   [rpm, torque, power, times] = DERIVEVALUES(revTimes, moi) calculates the angular velocity,
    %   torque, and power based on the provided vector of revolution times and moment of inertia.
    %
    %   [rpm, torque, power, times] = DERIVEVALUES(revTimes, moi, useInterp) allows for spline interpolation
    %   if the optional flag useInterp is set to true. By default, useInterp is set to false.
    %
    %   Inputs:
    %       revTimes - Vector of revolution times (in seconds) or a matrix with time data in columns.
    %       moi - Moment of inertia.
    %       useInterp - Optional flag for spline interpolation (default: false).
    %
    %   Outputs:
    %       rpm - Angular velocity (in rotations per minute).
    %       torque - Torque (in Nm).
    %       power - Power (in Watts).
    %       times - Time vector corresponding to the calculated values.
    %
    %   Example:
    %       % Calculate derived values without interpolation
    %       revTimes = [0, 1, 2, 3, 4];
    %       moi = 2.5;
    %       [rpm, torque, power, times] = deriveValues(revTimes, moi);
    %
    %       % Calculate derived values with interpolation
    %       useInterp = true;
    %       [rpm, torque_interp, power_interp, times_interp] = deriveValues(revTimes, moi, useInterp);
    %
    %   See also:
    %       SPLINE, GRADIENT.

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
            [rpm(:, col), torque(:, col), power(:, col), times(:, col)] = deriveValues(revTimes(:, col), moi, useInterp);
        end
    else
        % Vector input, perform calculations
        % Exclude NaN values
        validIndices = ~isnan(revTimes);
        revTimes = revTimes(validIndices);

        times = revTimes - revTimes(1);

        rpm = 60 ./ [0; diff(times)];
        rpm(isinf(rpm)) = 0;
        if useInterp
            times = linspace(0, max(revTimes), numel(revTimes));
            r = fit(revTimes, rpm, 'smoothingspline');
            rpm = feval(r, times);
        end

        omega = (pi/30) .* rpm;
        torque = moi .* gradient(omega, times);
        if useInterp
            t = fit(revTimes, torque, 'smoothingspline');
            torque = feval(t, times);
        end

        power = torque .* omega;
        if useInterp
            p = fit(revTimes, power, 'smoothingspline');
            power = feval(p, times);
        end
    end
end
