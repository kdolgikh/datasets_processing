clear
clc

header_start_line = 16;

% prompt for directory
prompt = 'Enter\copy a path to a directory with .csv \nfiles exported from OnsetDB. \nNote that path should end with "\\":\n';
folder = input(prompt,'s');
% folder = 'D:\GoogleDrive\!GIPL\Data\APP\datasets\2018-Copy\';

files = dir(fullfile(folder, '*.csv'));

% Save files in a new folder (modified)
folder_modified = strcat(folder,'modified\');
if ~exist(folder_modified,'dir')
    mkdir(folder,'modified')
end

not_accepted_value = 1;
while (not_accepted_value)
    prompt = '\nEnter a project abbreviation.\nAcceptable abreviations are APP, GIPL, TEON, USArray, and Kskwm\n';
    project_abbrv = input(prompt,'s');
    if strcmp(project_abbrv,'APP')||...
            strcmp(project_abbrv,'GIPL')||...
            strcmp(project_abbrv,'TEON')||...
            strcmp(project_abbrv,'USArray')||...
            strcmp(project_abbrv,'Kskwm')
        switch(project_abbrv)
            case 'APP'
                date_position=14;
            case 'GIPL'
                date_position=5;
            case {'TEON','Kskwm'}
                date_position=6;
            case 'USArray'
                date_position=8;
        end
        not_accepted_value = 0;
    else
        disp('Not acceptable abbreviation. Acceptable abbreviations are APP, GIPL, TEON, USArray, and Kskwm');
    end
end

prompt = '\nEnter the expected number of columns for the files in this directory\n';
num_columns_exp = input(prompt);


disp(' ');
disp('For each data file, the script assumes that sensors measuring one');
disp('physical property are of the same type.');
disp('For example, all temperature sensors are of the TMC type');
disp(' ');

dont_skip_sensor_type=1;

for j = 1:length(files)
    
    if ~exist(fullfile(folder_modified,files(j).name),'file')

    fid=fopen(fullfile(folder,files(j).name));

    % read lines until get to the line with column header
    for i=1:header_start_line
        data_header = fgetl(fid);
    end
    data_header = strsplit(data_header,',');

    % determine number of data columns
    num_columns = length(data_header);
    if num_columns > num_columns_exp
        disp(['In ',files(j).name,', the number of columns is larger than expected']);
    else
        if num_columns < num_columns_exp
            disp(['In ',files(j).name,', the number of columns is smaller than expected']);
        end
    end

    % From Matlab documentation:
    % C = textscan(fileID,formatSpec,N) reads file data using the formatSpec N times,
    % where N is a positive integer. To read additional data from the file after N cycles,
    % call textscan again using the original fileID. If you resume a text scan of a file
    % by calling textscan with the same file identifier (fileID), then textscan automatically
    % resumes reading at the point where it terminated the last read.

    % create a string to be used in textscan to read heights
    heights_string = '%s';
    for i=1:(num_columns-1)
        heights_string = strcat(heights_string,' %32f');
    end

    % create a string to be used in textscan to read data
    data_string = '%s';
    for i=1:(num_columns-1)
        data_string = strcat(data_string,' %s');
    end

    heights = textscan(fid,heights_string,1,'Delimiter',',');

    table_data = textscan(fid,data_string,'Delimiter',',');

    fclose(fid);

    % determine the number of columns and columns index for each
    % physical unit
    snow_column=0; snow_column_pos=[];
    temp_column=0; temp_column_pos=[];
    water_column=0; water_column_pos=[];
    for i=2:num_columns
        if strcmp(data_header{i},' "Snow_depth [N/A]"')
            snow_column=snow_column+1;
            snow_pos_next=i;
            snow_column_pos=[snow_column_pos, snow_pos_next];
        else
            if strcmp(data_header{i},' "Temp [°C]"')
                temp_column=temp_column+1;
                temp_pos_next=i;
                temp_column_pos=[temp_column_pos, temp_pos_next];
            else
                if strcmp(data_header{i},' "Water Content [N/A]"')||...
                        strcmp(data_header{i},' "Water Content [VWC]"')
                    water_column=water_column+1;
                    water_pos_next=i;
                    water_column_pos=[water_column_pos, water_pos_next];
                end
            end
        end
    end
    
    
    
    if dont_skip_sensor_type
        disp(' ');
        disp(['For site ',files(j).name]);
        % prompt for sensor type
        if snow_column
            prompt = 'enter or copy a sensor type for "Snow_depth" columns,\nacceptable value is JDS:\n';
            not_accepted_value = 1;
            while(not_accepted_value)
            sensor_type_snow = input(prompt,'s');
                if strcmp(sensor_type_snow,'JDS')
                    not_accepted_value = 0;
                else
                    disp('Error. Unacceptable sensor type value. Acceptable value is JDS');
                end
            end
        end

        if temp_column
            prompt = 'enter or copy a sensor type for "Temp[C]" columns,\nacceptable values are TMC, THB, or TMB:\n';
            not_accepted_value = 1;
            while(not_accepted_value)
                sensor_type_temp = input(prompt,'s');
                if strcmp(sensor_type_temp,'TMC') || strcmp(sensor_type_temp,'THB') || strcmp(sensor_type_temp,'TMB') 
                    not_accepted_value = 0;
                else
                    disp('Error. Unacceptable sensor type value. Acceptable values are: TMC, THB, or TMB');
                end
            end
        end

        if water_column
            prompt = 'enter or copy a sensor type for "Water Content" columns,\nacceptable values are SMD or SMC:\n';
            not_accepted_value = 1;
            while(not_accepted_value)
                sensor_type_water = input(prompt,'s');
                if strcmp(sensor_type_water,'SMD') || strcmp(sensor_type_water,'SMC') 
                    not_accepted_value = 0;
                else
                    disp('Error. Unacceptable sensor type value. Acceptable values are: SMD or SMC');
                end
            end
        end
        
        prompt = '\nAre other sensors in this directory of the same type? Answer y/n\n';
        not_accepted_value = 1;
        while(not_accepted_value)
            same_sensors = input(prompt,'s');
            if strcmp(same_sensors,'y')
                not_accepted_value=0;
                dont_skip_sensor_type=0;
            else
                if strcmp(same_sensors,'y')
                    not_accepted_value = 0;
                else
                disp('Error. Unacceptable answer. Acceptable answers are: y or n');
                end
            end
         end
        
    end
    
    % generate new data headers
    heights{1}='Date';

    for i = 2:num_columns
        heights{i} = generate_depth_string(heights{i});
        if ismember(i,snow_column_pos)
            heights{i}={strcat('SnowDepth_',sensor_type_snow)};
        else
            if ismember(i,temp_column_pos)
                if str2double(heights{i})>=0 && str2double(heights{i})<=0.05
                    heights{i}={strcat('Temp_',sensor_type_temp,'_surf')};
                else
                    if str2double(heights{i})<=-1.2
                        heights{i}={strcat('Temp_',sensor_type_temp,'_air')};
                    else
                        heights{i}={strcat('Temp_',sensor_type_temp,'_',heights{i})};
                    end
                end
            else
                if ismember(i,water_column_pos)
                    heights{i}={strcat('VWC__',sensor_type_water,'_',heights{i})};
                end
            end
        end
    end

    table_data_temp=[];
    for i=1:length(table_data)
        table_next=table_data{1,i};
        table_data_temp=[table_data_temp, table_next];
    end

    table_data = [heights;table_data_temp];

    [table_data,files(j).name] = modify_file_name(table_data,2,files(j).name,date_position);

    [table_data] = remove_NaN_columns(table_data);
    
    writetable(cell2table(table_data),fullfile(folder_modified,files(j).name),...
    'WriteVariableNames',false);

    end
end


%% FYI: converting height string into number
% number = str2double(string(10:16)), where 10:16 positions of the
% number's digits
