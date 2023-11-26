%% makeBinaryFiles

arduinoData = readDataFolder('Onland_Testing_Data', '.txt');

trainerData = readDataFolder('Trainer_Onland_Testing_Data', '.csv');

%% Calculate MOI and TORQFRICT

data = trainerData;

MOI = [];
TORQFRICT = [];
dataNames = cell(0, 1);
radius = 0.3175; % radius of wheel

fields = fieldnames(trainerData);
for i = 1:numel(fields)
    currentField = data.(fields{i});
    for j = 1:numel(currentField)
        dataName = sprintf('%s_%d', fields{i}, j);
        trainerData = data.(fields{i});
        
        % Calculate MOI and TORQFRIC
        [~, ~, ~, moi, torqueFriction, ~] = modelTrainerData(trainerData{j}, radius);
        
        MOI = [MOI; moi];
        TORQFRICT = [TORQFRICT; torqueFriction];
        dataNames = [dataNames; {dataName}];
    end
end

% Create a table
trainerConsts = table(MOI, TORQFRICT, 'RowNames', dataNames, 'VariableNames', {'MOI', 'TORQFRIC'});

%% Save Binary
OnlandTesting = struct('arduinoData',arduinoData,'trainerData',trainerData,'trainerConsts',trainerConsts);
save('OnlandTestingData.mat',"OnlandTesting");
