PowerOutputTesting.m
arduinoObj = arduino("COM3", "Uno");
configurePin(arduinoObj, "D9", "DigitalInput");

% Duration to record data(in seconds).
duration = 20; %temp
% Time interval between consecutive data reads.
stepTime = 0.01; %temp
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

    % % update plot
    addpoints(h,currentTime, D9);
    xlim([0, currentTime]);
    drawnow;

    % next
    dataIndex = dataIndex + 1;
    %pause(stepTime);
end
clear arduinoObj D9 dataIndex currentTime

%% 
MOI = 84.645e-01;
revTimes = (readmatrix("./Onland_Testing_Data/path/to/data"))';
revTimes = revTimes - revTimes(1);
% Calculate Quantities
revTimes = timeValues(gradient(Activations) > 0);
revTimes = timeValues(logical([0 (diff(Activations) == 1)]));
RPM = 60 ./ diff(revTimes);
omega = (pi/30) .* RPM;  % radians per second
alpha = gradient(omega, revTimes(2:end));  % radians per second squared​​
torque = MOI .* alpha;
power = torque .* ((pi/30) .* RPM);

%% 
%plots
figure;
% tiledlayout(4,1)
tiledlayout(3,1)

% Plot Activations
% nexttile
% plot(timeValues, Activations);
% title("Activations");
% xlabel("Time (s)");
% ylabel("Amplititude");

% Plot RPM
nexttile
plot(revTimes(2:end), RPM);
title("RPM");
xlabel("Time (s)");
ylabel("RPM");

% Plot Torque
nexttile
plot(revTimes(2:end), torque);
title("Torque");
xlabel("Time (s)");
ylabel("Torque");

% Plot Power
nexttile
plot(revTimes(2:end), power);
title("Power");
xlabel("Time (s)");
ylabel("Power");