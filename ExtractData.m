% ExtractData.m 
folderPath = 'Onland_Testing_Data';
dataStruct = readDataFolder(folderPath);
disp(dataStruct);

%% Functions
function dataStruct = readDataFolder(folderPath)
    % Get a list of subfolders in the main folder
    subfolders = dir(folderPath);
    subfolders = subfolders([subfolders.isdir] & ~ismember({subfolders.name}, {'.', '..'}));

    % Initialize a struct to store data
    dataStruct = struct();

    % Loop through each subfolder
    for folderIndex = 1:length(subfolders)
        currentFolder = subfolders(folderIndex).name;

        % Get a list of text files in the current subfolder
        filePattern = fullfile(folderPath, currentFolder, '*.txt');
        txtFiles = dir(filePattern);

        % Initialize a cell array to store data from each text file
        fileDataCell = cell(1, length(txtFiles));

        % Loop through each text file
        for fileIndex = 1:length(txtFiles)
            currentFile = txtFiles(fileIndex).name;
            filePath = fullfile(folderPath, currentFolder, currentFile);

            % Read the data from the text file
            fileData = readmatrix(filePath);

            % Store data in the cell array
            fileDataCell{fileIndex} = fileData;
        end

        % Store the cell array in the struct
        dataStruct.(currentFolder) = fileDataCell;
    end
end

