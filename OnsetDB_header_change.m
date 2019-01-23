clear
clc

header_start_line = 16;

% prompt for directory
prompt = 'Enter or copy a path to a directory with .csv \nfiles exported from OnsetDB. \nNote that path should end with "\\":\n';
folder = input(prompt,'s');
% folder = 'D:\GoogleDrive\!GIPL\Data\APP\datasets\2018-Copy\';


% prompt for sensor type
prompt = 'Enter or copy a sensor type (TMC, THB, or TMB):\n';
not_accepted_value = 1;
while(not_accepted_value)
    sensor_type = input(prompt,'s');
    if strcmp(sensor_type,'TMC') || strcmp(sensor_type,'THB') || strcmp(sensor_type,'TMB') 
        not_accepted_value = 0;
    else
        disp('#Error. Unacceptable sensor type value. Acceptable values are: TMC, THB, or TMB');
    end
end

files = dir(fullfile(folder, '*.csv'));

% Save files in a new folder (modified)
folder_modified = strcat(folder,'modified\');
if ~exist(folder_modified,'dir')
    mkdir(folder,'modified')
end


for j = 1:length(files)
    
    if ~exist(fullfile(folder_modified,files(j).name),'file')
%         opts = detectImportOptions(fullfile(folder,files(j).name));

        fid=fopen(fullfile(folder,files(j).name));

        % From Matlab documentation:
        % C = textscan(fileID,formatSpec,N) reads file data using the formatSpec N times,
        % where N is a positive integer. To read additional data from the file after N cycles,
        % call textscan again using the original fileID. If you resume a text scan of a file
        % by calling textscan with the same file identifier (fileID), then textscan automatically
        % resumes reading at the point where it terminated the last read.

        heights = textscan(fid,'%s %32f %32f %32f %32f %32f %32f %32f %32f',1,...
        'Delimiter',',','HeaderLines',header_start_line);

        table_data = textscan(fid,'%s %s %s %s %s %s %s %s %s',...
            'Delimiter',',');

        fclose(fid);

        heights{1}='Date';

        for i = 2:length(heights)
            heights{i} = generate_depth_string(heights{i});
            heights{i}={strcat('Temp_',sensor_type,'_',heights{i})};
        end

        table_data_temp=[];
        for i=1:length(table_data)
            table_next = table_data{1,i};
            table_data_temp=[table_data_temp, table_next];
        end

        table_data = [heights;table_data_temp];
        writetable(cell2table(table_data),fullfile(folder_modified,files(j).name),...
            'WriteVariableNames',false);
    end
end


%% FYI: converting height string into number 
% string = char(heights{x}), where x is an index
% number = str2double(str(10:16)), where 10:16 positions of the
% number's digits
