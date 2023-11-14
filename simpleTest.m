arduinoObj = arduino("COM3", "Uno","BaudRate", 115200);
configurePin(arduinoObj, "D8", "DigitalInput");
duration = 30;
i = 1;

disp("go!")
tic;     
% while toc <= duration 
%      Activations(i) = readDigitalPin(arduinoObj, "D8");
%      timeValues(i) = toc;
%     i = i + 1;
% end

device = serialport("COM3",9600);

configureCallback(device,"byte",count,@TimerFunc)

% write a call back function to read data from current line in arduino to a
% array and iterate data index

toc

%% 
revTimes = timeValues(logical([0 (diff(Activations) == 1)]));
RPM = 60 ./ diff(revTimes);

figure;
tiledlayout(2,1)

% Plot Activations
nexttile
plot(timeValues,Activations);
title("Activations");
xlabel("Time (s)");
ylabel("Amplititude");

% Plot RPM
nexttile
plot(revTimes(2:end), RPM);
title("RPM");
xlabel("Time (s)");
ylabel("RPM");