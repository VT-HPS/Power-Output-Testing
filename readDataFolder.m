function dataStruct = readDataFolder(folderPath, fileExtension)
% READDATAFOLDER Read data from files in subfolders of a specified directory.
%   dataStruct = READDATAFOLDER(folderPath, fileExtension) reads data from files
%   with the specified file extension in subfolders of the given directory.
%
%   Inputs:
%       folderPath - The path to the main folder containing subfolders with data files.
%       fileExtension - The file extension of the data files to be read (e.g., '.csv', '.txt').
%
%   Outputs:
%       dataStruct - A struct containing the read data. Each field corresponds to a
%                    subfolder, and the data is stored as a cell array.
%
%   Example:
%       % Read data from CSV files in subfolders of the 'DataFolder' directory
%       dataStruct = readDataFolder('DataFolder', '.csv');
%
%   See also:
%       READTABLE, READMATRIX.

    % Get a list of subfolders in the main folder
    subfolders = dir(folderPath);
    subfolders = subfolders([subfolders.isdir] & ~ismember({subfolders.name}, {'.', '..'}));

    % Initialize a struct to store data
    dataStruct = struct();

    % Loop through each subfolder
    for folderIndex = 1:length(subfolders)
        currentFolder = subfolders(folderIndex).name;

        % Get a list of files with the specified extension in the current subfolder
        filePattern = fullfile(folderPath, currentFolder, ['*' fileExtension]);
        files = dir(filePattern);

        % Initialize a cell array to store data from each file
        fileDataCell = cell(length(files), 1);

        % Loop through each file
        for fileIndex = 1:length(files)
            currentFile = files(fileIndex).name;
            filePath = fullfile(folderPath, currentFolder, currentFile);

            % Read the data from the file based on file extension
            if strcmpi(fileExtension, '.csv')
                fileData = readtable(filePath);
            else
                % Add more conditions for other file types if needed
                fileData = readmatrix(filePath);
            end

            % Store data in the cell array
            fileDataCell{fileIndex} = fileData;
        end

        % Store the cell array in the struct
        dataStruct.(currentFolder) = fileDataCell;
    end
end
