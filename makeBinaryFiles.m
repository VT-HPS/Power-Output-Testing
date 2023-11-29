%% makeBinaryFiles
oldpath = path;
path(oldpath,'.\Functions')

arduinoData = readDataFolder('Onland_Testing_Data', '.txt');
trainerData = readDataFolder('Trainer_Onland_Testing_Data', '.csv');
radius = 0.3175; % radius of wheel

%% Create OnlandTesting Data Struct

dataNames = cell(0, 1);
OnlandTesting = struct();
fields = fieldnames(trainerData);
for i = 1:numel(fields)
    personInitials = fields{i};
    OnlandTesting.(personInitials) = struct();

    currentField = trainerData.(fields{i});
    for j = 1:numel(currentField)
        dataName = sprintf('%s_%d', fields{i}, j);
        OnlandTesting.(personInitials)(j).trainerData = trainerData.(fields{i}){j};
        OnlandTesting.(personInitials)(j).arduinoData = arduinoData.(fields{i}){j};

        [ttimes, trpm, ttorque, tpower, moi, torqueFriction] = modelTrainerData(trainerData.(fields{i}){j}, radius);
        tResults = table(ttimes, trpm, ttorque, tpower,'VariableNames',{'times','rpm','torque','power'});
        OnlandTesting.(personInitials)(j).trainerResults = tResults;

        [atimes, arpm, atorque, apower] = deriveValues(arduinoData.(fields{i}){j},moi,torqueFriction);
        aResults = table(atimes, arpm, atorque, apower,'VariableNames',{'times','rpm','torque','power'});
        OnlandTesting.(personInitials)(j).arduinoResults = aResults;

        OnlandTesting.(personInitials)(j).MOI = moi;
        OnlandTesting.(personInitials)(j).TORQFRICT = torqueFriction;

        
    end
end

%% Save Binaries
save('OnlandTestingData.mat',"test");

path(oldpath);
