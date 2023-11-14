% TestTimer.m

% Duration to simulate data (in seconds).
duration = 5;
% Time interval between consecutive data reads.
stepTime = 0.01;
% Total number of data samples to be recorded.
samples = duration / stepTime;

% Initialize arrays for storing data and timestamps.
Activations = zeros(1, samples);
timeValues = linspace(0, duration, samples);

% Create a figure for real-time plotting
figure;
h = animatedline;
title("Activations");
xlabel("Time (s)");
ylabel("Amplitude");

% Set up the timer
timerObj = timer('TimerFcn', @(~,~) acquireData(h, Activations), ...
    'Period', stepTime, 'ExecutionMode', 'fixedDelay', 'TasksToExecute', samples, 'BusyMode', 'drop');

% Run the timer

start(timerObj);
tic
wait(timerObj);
toc
stop(timerObj);
delete(timerObj);
clear timerObj

% Calculate Quantities
revTimes = timeValues(diff(Activations) == 1);
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
plot(revTimes, RPM);
title("RPM");
xlabel("Time (s)");
ylabel("RPM");

% Timer callback function
function acquireData(h, Activations)
    persistent dataIndex;
    
    if isempty(dataIndex)
        dataIndex = 1;
    end
    
    % Simulate reading digital data (0 or 1)
    D9 = randi([0, 1]);

    % Store the read data in the corresponding data arrays.
    Activations(dataIndex) = D9;

    % Update the plot with the new data
    addpoints(h, dataIndex, D9);
    drawnow;

    % Increment index
    dataIndex = dataIndex + 1;
end
