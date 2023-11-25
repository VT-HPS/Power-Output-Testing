function [rpm, times] = rpmGen(revTimes)
    % RPMGEN Converts revolution times to rpm and time stamps
    %   [rpm, times] = RPMGEN(revTimes)
    %
    %   Inputs:
    %       revTimes - Vector of revolution times (in seconds)
    %
    %   Outputs:
    %       rpm - Angular velocity (in rotations per minute)
    %       times - Time vector corresponding to the calculated values
    
    % Filter indices
    validIndices = ~(isnan(revTimes) | isinf(revTimes));
    revTimes = revTimes(validIndices);

    % Compute time and rpm vectors
    times = revTimes - revTimes(1);
    rpm = 60 ./ [0; diff(times)];
end