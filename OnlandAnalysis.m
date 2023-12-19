% OnlandAnalysis.m
% The purpose of the following code is to perform aggregate analysis on the
% data collected in Onland Power Testing from the Arduino
% TODO -
% compare smoothed out data
% compare with trainer data
% get means: power, rpm, and torque
oldpath = path;
path(oldpath,'./Functions')
load OnlandTestingData.mat

%% Derived Values
figure('Name', "Onland Testing Results: (Arduino) Derived Values");
fig = tiledlayout(3, 1);
title(fig,"Onland Testing Results: (Arduino) Derived Values",'Interpreter', 'latex')

% Initialize legend entries
legendEntries = {};
% Loop through each field in the struct
fields = fieldnames(OnlandTesting);
% for i = 1:3
for i = 1:numel(fields)
    currentField = fields{i};

    % Loop through each element in the cell array and plot the data
    % for j = 1:3
    for j = 1:numel(OnlandTesting.(currentField))
        % k = sprintf('%s_%d', fields{i}, j);

        arduinoDataTable = OnlandTesting.(currentField)(j).arduinoResults;
        
        % dataTimes.(k) = cell(times);
        % Plot rpm
        nexttile(1);
        plot(arduinoDataTable.times, arduinoDataTable.rpm);
        hold on;

        % Plot Torque
        nexttile(2);
        plot(arduinoDataTable.times, arduinoDataTable.torque);
        hold on;

        % Plot Power
        nexttile(3);
        plot(arduinoDataTable.times, arduinoDataTable.power);
        hold on;

        % Generate legend entries
        legendEntries = [legendEntries, sprintf('%s_%d', fields{i}, j)];        
    end
end

% Set titles, labels, and legends for each subplot
titles = ["$RPM$", "Torque $\tau$", "Power \textit{P}"];
Ylabels= ["RPM", "N-m", "Watts"];
xlabel(fig,"Time (s)",'Interpreter', 'latex');
YLIMS = [[0 400]; [0 40]; [0 800]];
for k = 1:3
    g = nexttile(k);
    title(titles(k),'Interpreter', 'latex');
    ylabel(Ylabels(k),'Interpreter', 'latex');
    ylim(g,YLIMS(k,:));
    xlim(g,[0 130]);
    % legend(legendEntries); % too cluttered
    hold off;
end

nexttile(1)
legend(legendEntries);
% saveas(fig,"./Figures/Onland Testing Results- (Arduino) Derived Values.png")

%% Trainer Values

figure('Name', "Onland Testing Results: Trainer Values");
fig = tiledlayout(3, 1);
title(fig,"Onland Testing Results: Trainer Values",'Interpreter', 'latex')

% Initialize legend entries
legendEntries = {};
% Loop through each field in the struct
fields = fieldnames(OnlandTesting);
% for i = 1:3
for i = 1:numel(fields)
    currentField = fields{i};

    % Loop through each element in the cell array and plot the data
    % for j = 1:3
    for j = 1:numel(OnlandTesting.(currentField))
        trainerDataTable = OnlandTesting.(currentField)(j).trainerResults;
        
        % dataTimes.(k) = cell(times);
        % Plot rpm
        nexttile(1);
        plot(trainerDataTable.times, trainerDataTable.rpm);
        hold on;

        % Plot Torque
        nexttile(2);
        plot(trainerDataTable.times, trainerDataTable.torque);
        hold on;

        % Plot Power
        nexttile(3);
        plot(trainerDataTable.times, trainerDataTable.power);
        hold on;

        % Generate legend entries
        legendEntries = [legendEntries, sprintf('%s_%d', fields{i}, j)];        
    end
end

% Set titles, labels, and legends for each subplot
titles = ["$RPM$", "Torque $\tau$", "Power \textit{P}"];
Ylabels= ["RPM", "N-m", "Watts"];
xlabel(fig,"Time (s)",'Interpreter', 'latex');
YLIMS = [[0 400]; [0 40]; [0 800]];
for k = 1:3
    g = nexttile(k);
    title(titles(k),'Interpreter', 'latex');
    ylabel(Ylabels(k),'Interpreter', 'latex');
    ylim(g,YLIMS(k,:));
    xlim(g,[0 130]);
    % legend(legendEntries); % too cluttered
    hold off;
end

nexttile(1)
legend(legendEntries);
% saveas(fig,"./Figures/Onland Testing Results- Trainer Values.png")

%% Peak Power

% Access the struct with precomputed data
dataStruct = OnlandTesting;

fields = fieldnames(dataStruct);
peakPowerArray = zeros(6,3);
avgPowerArray = zeros(6,3);

for m = 1:numel(fields)
    personInitials = fields{m};
    
    for n = 1:numel(dataStruct.(personInitials))
        % Access power data for the current trial
        powerData = dataStruct.(personInitials)(n).arduinoResults.power;

        peakPowerArray(m,n) = max(powerData);
        avgPowerArray(m,n) = mean(powerData);
    end
end

peakPowerTable = array2table(peakPowerArray,"RowNames",fields,"VariableNames",["Trial1","Trial2","Trial3"]);
avgPowerTable = array2table(avgPowerArray,"RowNames",fields,"VariableNames",["Trial1","Trial2","Trial3"]);

%% Average Linear Params
dataStruct = OnlandTesting;

fields = fieldnames(dataStruct);
MOIS =[];
muT = [];

for m = 1:numel(fields)
    personInitials = fields{m};
    for n = 1:numel(dataStruct.(personInitials))
        % Access power data for the current trial
        data = dataStruct.(personInitials)(n);

        MOIS = [MOIS; data.MOI];
        muT = [muT; data.TORQFRICT];
    end
end

MMOI = mean(MOIS)
mmuT = mean(muT)

%% Restore Path
path(oldpath)
