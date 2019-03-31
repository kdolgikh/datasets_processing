clear
clc

header_start_line = 16;
date_start_line = 2; % the row in which date starts for !processed! data

% prompt for directory
prompt = 'Enter\\copy a path to a directory with .csv \nfiles exported from OnsetDB:\n';
folder = input(prompt,'s');

% the directory should end with "\". Add "\" if it is missing
if ~strcmp(folder(end),'\')
    folder=strcat(folder,'\');
end

files = dir(fullfile(folder, '*.csv'));

% Save files in a new folder (modified)
folder_modified = strcat(folder,'modified\');
if ~exist(folder_modified,'dir')
    mkdir(folder,'modified')
end

% Ask a user to provide a lookup table
prompt = 'Enter the name of the lookup table file:\n';
lookup_table_name = input(prompt,'s');

fid=fopen(lookup_table_name,'r','n','UTF-8');
lookup_t = textscan(fid,'%s %s','Delimiter',',');
fclose(fid);

lookup_table=[];
for i=1:length(lookup_t)
    table_next=lookup_t{1,i};
    lookup_table=[lookup_table, table_next];
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
                name_length = 12;
            case 'GIPL'
                date_position=5;
                name_length = 3;
            case {'TEON','Kskwm'}
                date_position=6;
                name_length = 4;
            case 'USArray'
                date_position=8;
                name_length = 6;
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

dont_skip_sensor_type=1;
sensor_type_temp='';
sensor_type_water='';
sensor_type_snow='';

for j = 1:length(files)

    errmsg='';
    [fid,errmsg]=fopen(fullfile(folder,files(j).name));

    if fid>0

        % read lines until get to the line with column header
        for i=1:header_start_line
            data_header = fgetl(fid);
        end
        data_header = strsplit(data_header,',');

        % determine number of data columns
        num_columns = length(data_header);
        if num_columns > num_columns_exp
            disp(' ');
            disp(['In ',files(j).name,', the number of columns is larger than expected']);
        else
            if num_columns < num_columns_exp
                disp(' ');
                disp(['In ',files(j).name,', the number of columns is smaller than expected']);
            end
        end

        % From Matlab documentation:
        % C = textscan(fileID,formatSpec,N) reads file data using the formatSpec N times,
        % where N is a positive integer. To read additional data from the file after N cycles,
        % call textscan again using the original fileID. If you resume a text scan of a file
        % by calling textscan with the same file identifier (fileID), then textscan automatically
        % resumes reading at the point where it terminated the last read.

        % create a string to be used in textscan to read depths
        depths_string = '%s';
        for i=1:(num_columns-1)
            depths_string = strcat(depths_string,' %32f');
        end

        % create a string to be used in textscan to read data
        data_string = '%s';
        for i=1:(num_columns-1)
            data_string = strcat(data_string,' %s');
        end

        depths = textscan(fid,depths_string,1,'Delimiter',',');

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

        % if skip_sensor_type is set, but incoming data has water/snow sensor
        % for which type is not defined, then go inside "if dont_skip_sensor_type"
        % and define this sensor
        if dont_skip_sensor_type ==0
           if (strcmp(sensor_type_temp,'')&&temp_column)||...
              (strcmp(sensor_type_snow,'')&&snow_column)||...
              (strcmp(sensor_type_water,'')&&water_column)
                dont_skip_sensor_type=1;
           end
        end

        if dont_skip_sensor_type
            disp(' ');
            disp(['For site ',files(j).name]);
            
            % prompt for sensor type
            if snow_column
                prompt = 'enter or copy a sensor type for "Snow_depth" columns,\nacceptable value is JUDS:\n';
                not_accepted_value = 1;
                while(not_accepted_value)
                sensor_type_snow = input(prompt,'s');
                    if strcmp(sensor_type_snow,'JUDS')
                        not_accepted_value = 0;
                    else
                        disp('Error. Unacceptable sensor type value. Acceptable value is JUDS');
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
                prompt = 'enter or copy a sensor type for "Water Content" columns,\nacceptable values are SMA, SMB, SMC, or SMD:\n';
                not_accepted_value = 1;
                while(not_accepted_value)
                    sensor_type_water = input(prompt,'s');
                    if strcmp(sensor_type_water,'SMA') ||...
                       strcmp(sensor_type_water,'SMB') ||...
                       strcmp(sensor_type_water,'SMC') ||...
                       strcmp(sensor_type_water,'SMD') 
                        not_accepted_value = 0;
                    else
                        disp('Error. Unacceptable sensor type value. Acceptable values are: SMA, SMB, SMC, or SMD');
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
                    if strcmp(same_sensors,'n')
                        not_accepted_value = 0;
                    else
                    disp('Error. Unacceptable answer. Acceptable answers are: y or n');
                    end
                end
             end

        end

        % generate new data headers
        depths{1}='Timestamp';

        for i = 2:num_columns
            depths{i} = generate_depth_string(depths{i});
            if ismember(i,snow_column_pos)
                depths{i}={strcat('SnwD_',sensor_type_snow)};
            else
                if ismember(i,temp_column_pos)
                    if str2double(depths{i})>=0 && str2double(depths{i})<=0.01 && strcmp(project_abbrv,'Kskwm')
                        depths{i}={strcat('Temp_',sensor_type_temp,'_surf')};
                    else
                        if str2double(depths{i})>=0 && str2double(depths{i})<=0.03 && ~strcmp(project_abbrv,'Kskwm')
                            depths{i}={strcat('Temp_',sensor_type_temp,'_surf')};
                        else
                            if str2double(depths{i})<=-1.2
                                depths{i}={strcat('Temp_',sensor_type_temp,'_air')};
                            else
                                depths{i}={strcat('Temp_',sensor_type_temp,'_',depths{i})};
                            end
                        end
                    end
                else
                    if ismember(i,water_column_pos)
                        depths{i}={strcat('VWC__',sensor_type_water,'_',depths{i})};
                    end
                end
            end
        end

        table_data_temp=[];
        for i=1:length(table_data)
            table_next=table_data{1,i};
            table_data_temp=[table_data_temp, table_next];
        end

        table_data = [depths;table_data_temp];

        % modify file name to reflect the actual date range, also remove the
        % first and the last rows containing all NaNs
        [table_data,files(j).name] =...
            modify_file_name(table_data,date_start_line,files(j).name,date_position);

        % remove columns containing all NaNs
        [table_data,~] = remove_nan_columns(table_data,files(j).name);

        % when exporting with UTF-8 encoding, the first character of the
        % name is '', we need to get rid of it.
        % To do this, I compare lengths of the name. isempty() or strcmp()
        % do not work when comparing with '' obtained from data
        for i=1:length(lookup_table)
            if length(lookup_table{1,1})>name_length
                lookup_table{i,1}(1)=[];
            end
        end

        new_site_code = lookup_site_name(files(j).name(1:name_length),lookup_table);

        files(j).name = strcat(new_site_code,files(j).name((name_length+1):end));

        % save the file in \modified directory
        writetable(cell2table(table_data),fullfile(folder_modified,files(j).name),...
        'WriteVariableNames',false);

    else
        disp(' ');
        disp(errmsg);
    end
       
end


% create a table with file names
names_list=transpose(struct2cell(files));
names_table=cell2table(names_list(1:end,1));

writetable(names_table,fullfile(folder_modified,strcat(project_abbrv,'_FileNames_List.csv')),...
'WriteVariableNames',false);


%% FYI: converting height string into number
% number = str2double(string(10:16)), where 10:16 positions of the
% number's digits
