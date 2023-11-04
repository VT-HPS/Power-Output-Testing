% PowerOutputTesting.m
arduinoObj = arduino("COM3", "Uno");
configurePin(arduinoObj, "D9", "DigitalInput");

% Duration to record data(in seconds).
duration = 10; %temp
% Time interval between consecutive data reads.
stepTime = 0.1; %temp
% Total number of data samples to be recorded.
samples = duration/stepTime;

MOI = 2; % sample moment of inertia

% Initialize arrays for storing data and timestamps.
Activations = zeros(1,samples);
timeValues = zeros(1, samples);

% Create a figure for real-time plotting
figure;
h = animatedline;
title("Activations");
xlabel("Time (s)");
ylabel("Amplitude");

dataIndex = 1;
tObj = tic;     
while toc(tObj) <= duration 
    D9 = readDigitalPin(arduinoObj, "D9");
    currentTime = toc(tObj);

    % Store the read data in the corresponding data arrays.
    timeValues(dataIndex) = currentTime;
    Activations(dataIndex) = D9;

    % update plot
    addpoints(h,currentTime, D9);
    xlim([0, currentTime]);
    drawnow;

    % next
    dataIndex = dataIndex + 1;
    pause(stepTime);
end
clear arduinoObj D9 dataIndex currentTime

% Calculate Quantities
revTimes = timeValues(gradient(Activations) == 1);​​
RPM = 60 ./ gradient(revTimes);
omega = (pi/30) .* RPM;  % radians per second
alpha = gradient(omega, revTimes);  % radians per second squared​​
torque = MOI .* alpha;​
power = torque .* ((pi/30) .* RPM);

%plots
figure;
tiledlayout(4,1)

% Plot Activations
nexttile
plot(timeValues, Activations);
title("Activations");
xlabel("Time (s)");
ylabel("Amplititude");

% Plot RPM
nexttile
plot(revTimes, RPM);
title("RPM");
xlabel("Time (s)");
ylabel("RPM");

% Plot Torque
nexttile
plot(revTimes, torque);
title("Torque");
xlabel("Time (s)");
ylabel("Torque");

% Plot Power
nexttile
plot(revTimes, power);
title("Power");
xlabel("Time (s)");
ylabel("Power");
