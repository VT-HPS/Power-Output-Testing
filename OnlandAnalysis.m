% OnlandAnalysis.m
% The purpose of the following code is to perform aggregate analysis on the
% data collected in Onland Power Testing from the Arduino
% TODO -
% compare smoothed out data
% compare with trainer data
% get means: power, rpm, and torque
load OnlandTestingData.mat
data = OnlandTestingData;
moi = 7.333;
figure('Name', "Onland Testing Analysis: Derived Values");
tiledlayout(3, 1);

% Initialize legend entries
legendEntries = {};
dataTimes = table();
% Loop through each field in the struct
fields = fieldnames(data);
for i = 1:3
% for i = 1:numel(fields)
    currentField = data.(fields{i});

    % Loop through each element in the cell array and plot the data
    % for j = 1:3
    for j = 1:numel(currentField)
        revTimes = currentField{j};
        % k = sprintf('%s_%d', fields{i}, j);
        
        [rpm, torque, power, times] = deriveValues(revTimes, moi);
        % dataTimes.(k) = cell(times);
        % Plot rpm
        nexttile(1);
        plot(times, rpm);
        hold on;

        % Plot Torque
        nexttile(2);
        plot(times, torque);
        hold on;

        % Plot Power
        nexttile(3);
        plot(times, power);
        hold on;

        % Generate legend entries
        legendEntries = [legendEntries, sprintf('%s_%d', fields{i}, j)];        
    end
end

% Set titles, labels, and legends for each subplot
titles = ["$RPM$", "Torque $\tau$", "Power \textit{P}"];
Ylabels= ["RPM", "N-m", "Watts"];
for k = 1:3
    nexttile(k);
    title(titles(k),'Interpreter', 'latex');
    xlabel("Time (s)",'Interpreter', 'latex');
    ylabel(Ylabels(k),'Interpreter', 'latex');
    % legend(legendEntries); % too cluttered
    hold off;
end

nexttile(1)
legend(legendEntries);

%% Inspect input/output

% Here we flatten
q = struct2table(OnlandTestingData);
w = table2array(q);
% Find the maximum number of rows in the cell array
maxRows = max(cellfun(@(x) size(x, 1), w));

% Pad each cell to match the maximum number of rows
w_padded = cellfun(@(x) [x; nan(maxRows - size(x, 1), size(x, 2))], w, 'UniformOutput', false);

% Convert the padded cell array to a matrix
d = cell2mat(w_padded);

[rpm, torque, power, times] = deriveValues(d, moi, false); %interpolation does not work with arrays yet

figure
plot(times,rpm)
