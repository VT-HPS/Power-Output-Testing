function dataStruct = readDataFolder(folderPath)
% READDATAFOLDER - Read data from text files in subfolders of the main folder.
%   dataStruct = READDATAFOLDER(folderPath) reads data from text files in subfolders
%   of the specified main folder and organizes it into a struct. Each field of the struct
%   corresponds to a subfolder, and the value is a cell array containing data from each
%   text file in that subfolder.
%
%   Inputs:
%       folderPath - Path to the main folder containing subfolders with text files.
%
%   Output:
%       dataStruct - Struct containing organized data from text files.
%
%   Example:
%       % Read data from a folder and access data from a specific subfolder
%       folderPath = 'C:\Your\Main\Folder';
%       dataStruct = readDataFolder(folderPath);
%       subfolderData = dataStruct.SubfolderName;
%       % Access data from the first file in the subfolder
%       firstFileData = subfolderData{1};

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
