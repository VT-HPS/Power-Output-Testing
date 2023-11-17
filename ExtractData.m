% ExtractData.m 

% Specify the relative folder path
relativeFolderPath = 'Onland_Testing_Data';

% Get a list of subfolders in the main folder
subfolders = dir(relativeFolderPath);
subfolders = subfolders([subfolders.isdir] & ~ismember({subfolders.name}, {'.', '..'}));

% Initialize a struct to store data
OnlandTestingData = struct();

% Loop through each subfolder
for folderIndex = 1:length(subfolders)
    currentFolder = subfolders(folderIndex).name;
    
    % Get a list of text files in the current subfolder
    filePattern = fullfile(relativeFolderPath, currentFolder, '*.txt');
    txtFiles = dir(filePattern);
    
    % Initialize a cell array to store data from each text file
    fileDataCell = cell(1, length(txtFiles));
    
    % Loop through each text file
    for fileIndex = 1:length(txtFiles)
        currentFile = txtFiles(fileIndex).name;
        filePath = fullfile(relativeFolderPath, currentFolder, currentFile);
        
        % Read the data from the text file
        fileData = readmatrix(filePath);
        
        % Store data in the cell array
        fileDataCell{fileIndex} = fileData;
    end
    
    % Store the cell array in the struct
    OnlandTestingData.(currentFolder) = fileDataCell;
end
% Clear all other variables
clearvars -except OnlandTestingData

% Save the dataStruct variable
save('OnlandTestingData.mat', 'OnlandTestingData');

% Display the struct
OnlandTestingData

