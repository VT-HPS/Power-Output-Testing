%% makeBinaryFiles
oldpath = path;
path(oldpath,'.\Functions')

arduinoData = readDataFolder('Onland_Testing_Data', '.txt');
trainerData = readDataFolder('Trainer_Onland_Testing_Data', '.csv');

%% Calculate MOI and TORQFRICT

MOI = [];
TORQFRICT = [];
dataNames = cell(0, 1);
radius = 0.3175; % radius of wheel

fields = fieldnames(trainerData);
for i = 1:numel(fields)
    currentField = trainerData.(fields{i});
    for j = 1:numel(currentField)
        dataName = sprintf('%s_%d', fields{i}, j);
        data = trainerData.(fields{i});
        
        % Calculate MOI and TORQFRIC
        [~, ~, ~, moi, torqueFriction, ~] = modelTrainerData(data{j}, radius);
        
        MOI = [MOI; moi];
        TORQFRICT = [TORQFRICT; torqueFriction];
        dataNames = [dataNames; {dataName}];
    end
end

% Create a table
trainerConsts = table(MOI, TORQFRICT, 'RowNames', dataNames, 'VariableNames', {'MOI', 'TORQFRIC'});

%% Save Binary
OnlandTesting = struct();
OnlandTesting.arduinoData = arduinoData;
OnlandTesting.trainerData = trainerData;
OnlandTesting.trainerConsts = trainerConsts;
save('OnlandTestingData.mat',"OnlandTesting");

path(oldpath);