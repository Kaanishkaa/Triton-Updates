clear;

% Setting the GCP Directory
cloudDir = 'gs://noaa-passive-bioacoustic/onms/products/sound_level_metrics';  % GCP bucket directory
command = '/Users/kanishka/google-cloud-sdk/bin/gsutil';
outputDir = 'local_directory_path';  % Specify your local directory to save the netCDF files

% Listing sub-directories and files in the GCP bucket
[status, subdirs] = system([command ' ls ' cloudDir]);
if status ~= 0
    error('Error listing directories');
end
subdirs = strsplit(subdirs, '\n');  % Split by newline to get the list of directories
subdirs = subdirs(~cellfun('isempty', subdirs));  % Remove empty entries

% Initialize an empty cell array to store netCDF file paths
netcdf_files = {}; 

% Looping through the sub-directories to list netCDF files
for s = 1:length(subdirs)
    [status, sFiles] = system([command ' ls -r ' subdirs{s}]);
    if status ~= 0
        error('Error listing files');
    end
    sFiles = strsplit(sFiles, '\n');  % Split by newline to get individual files
    sFiles = sFiles(~cellfun('isempty', sFiles));  % Remove empty entries
    
    % Keep only netCDF files (with .nc extension)
    valid_netcdf_files = sFiles(contains(sFiles, '.nc'));
    
    % Concatenate valid netCDF file paths
    if ~isempty(valid_netcdf_files)
        netcdf_files = [netcdf_files; valid_netcdf_files'];  % Append as cell array
    end
end

% Loop to download each netCDF file
for i = 1:length(netcdf_files)
    netcdf_file = netcdf_files{i};
    
    % Create a local path for the file
    [~, filename, ext] = fileparts(netcdf_file);
    local_file = fullfile(outputDir, [filename ext]);  % Save file locally
    
    % Download the netCDF file from GCP bucket
    command_download = [command ' cp ' netcdf_file ' ' local_file];
    disp(['Downloading: ' netcdf_file]);
    [status, ~] = system(command_download);
    if status ~= 0
        error('Error downloading file: %s', netcdf_file);
    end
    
    disp(['Successfully downloaded: ', local_file]);
end


