%% MATLAB Script (e.g., ArduinoDataAnalysis.m)
% PowerOutputTesting.m
system('arduino-cli compile --fqbn arduino:avr:uno Arduino_Power_Code.ino');
system('arduino-cli upload -p COM3 --fqbn arduino:avr:uno Arduino_Power_Code.ino');

s = serialport("COM3", 9600);

revTimes = [];
RPMValues = [];

% Create a figure for real-time plotting
figure('KeyPressFcn', @stopRecording);
h = animatedline;
title("Revolution Times");
xlabel("Data Point");
ylabel("Revolution Time (s)");

dataIndex = 1;
while true
    % Read one line from the serial port
    data = readline(s);
    
    % Break the loop if the received data is empty
    if isempty(data)
        break;
    end
    
    % Convert the string to a number and add it to the array
    revTime = str2double(data);
    if ~isnan(revTime)
        revTimes = [revTimes, revTime];
        
        % Add data point to the animated plot
        addpoints(h, revTime, 1);
        drawnow limitrate;
        xlim([1, dataIndex + 10]); % Adjust the x-axis limits
        
        % Calculate and display RPM
        if dataIndex > 1
            RPM = 60 / (revTime - revTimes(end - 1));
            RPMValues = [RPMValues, RPM];
            disp(['Current RPM: ', num2str(RPM)]);
        end
        
        % Increment data index
        dataIndex = dataIndex + 1;
    end
end

% Close the serial port
delete(s);
clear s;

%% Calculations
MOI = 84.645e-01;
revTimes = revTimes - revTimes(1);
% Calculate Quantities
revTimes = timeValues(gradient(Activations) > 0);
revTimes = timeValues(logical([0 (diff(Activations) == 1)]));
RPM = 60 ./ diff(revTimes);
omega = (pi/30) .* RPM;  % radians per second
alpha = gradient(omega, revTimes(2:end));  % radians per second squared​​
torque = MOI .* alpha;
power = torque .* ((pi/30) .* RPM);

%% Plots
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

%% Functions

% Callback function to stop recording when spacebar is pressed
function stopRecording(~, event)
    if strcmp(event.Key, 'space')
        disp('Recording stopped.');
        % Close the serial port
        delete(s);
        clear s;
        % break; % This will break out of the loop
    end
end