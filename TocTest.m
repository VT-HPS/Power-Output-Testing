% TocTest.m
arduinoObj = arduino("COM3", "Uno","BaudRate", 115200);
configurePin(arduinoObj, "D8", "DigitalInput");

% Duration to record data(in seconds).
duration = 60; %temp
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
tic;     
while toc <= duration 
    D9 = readDigitalPin(arduinoObj, "D8");

    currentTime = toc;

    % Store the read data in the corresponding data arrays.
    timeValues(dataIndex) = currentTime;
    Activations(dataIndex) = D9;

    % % update plot
    addpoints(h,currentTime, D9);
    xlim([0, currentTime]);
    drawnow;

    % next
    dataIndex = dataIndex + 1;
end
toc
clear arduinoObj D9 dataIndex currentTime tObj

% Calculate Quantities
revTimes = timeValues(logical([0 (diff(Activations) == 1)]));
RPM = 60 ./ diff(revTimes);

%plots
figure;
tiledlayout(2,1)

% Plot Activations
nexttile
plot(timeValues, Activations);
title("Activations");
xlabel("Time (s)");
ylabel("Amplititude");

% Plot RPM
nexttile
plot(revTimes(2:end), RPM);
title("RPM");
xlabel("Time (s)");
ylabel("RPM");