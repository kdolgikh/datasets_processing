clear
clc

load('sites_flags_struct.mat');
sites_flags_fn=fieldnames(sites_flags);
old_codes_lookup_table = load_lookup_table('vdv_sites_old_code_lookup.csv');
new_codes_lookup_table = load_lookup_table('VDV_GIPL_SiteCodes_Lookup_Table.csv');

global header_start_line;

num_chars_average=9; % number of chars in [average]
num_char_csv=4;
num_char_day=3;  % number of chars in day
num_chars_hwy=4; % number of chars in hour/week/year
num_chars_month=5; % number of chars in month

global length_dim;   % length dimension of a table (number of rows)
length_dim=1;

% If "sensors_used" flags are moved inside the j = 1:length(files) loop,
% then question to include a specific measurement type into a dataset
% will be asked for every file.
% When these flags are initialized outside the loop (as below), such
% question will be asked only once.
% sensors_used(1) - HydraProbe temperature flag
% sensors_used(2) -  VWC flag
% sensors_used(3) - snow depth flag
% sensors_used(4) - heat flux flag
sensors_used=[-1,-1,-1,-1];

% prompt for directory
prompt = 'Enter\\copy a path to a directory with .csv \nfiles exported from VDV:\n';
folder = input(prompt,'s');

% the directory should end with "\". Add "\" if it is missing
if ~strcmp(folder(end),'\')
    folder=strcat(folder,'\');
end

% log everything from the command window into a text file
log_name_date=date;
log_name=strcat(log_name_date,'_VDV_data_processing_log.txt');
dname = fullfile(folder,log_name);
diary(dname);
diary on

files = dir(fullfile(folder, '*.csv'));

% Save files in a new folder (modified)
folder_modified = strcat(folder,'modified\');
if ~exist(folder_modified,'dir')
    mkdir(folder,'modified')
end

disp(' ');
accepted_val = 0;        
while ~accepted_val
    prompt = 'Notify when unnecessary column is removed? Answer y/n\n';
    notify_flag = input(prompt,'s');
    if strcmp(notify_flag,'y') || strcmp(notify_flag,'n')
       accepted_val=1;
    else
       disp('Error: unacceptable answer. Acceptable answers are: y or n');
    end
end

switch(notify_flag)
    case 'y'
        notify_flag=1;
    case 'n'
        notify_flag=0;
end

disp(' ');
accepted_val = 0;        
while ~accepted_val
    prompt = 'Notify when column with a specific measurement\ntype is removed? Answer y/n\n';
    notify_flag2 = input(prompt,'s');
    if strcmp(notify_flag2,'y') || strcmp(notify_flag2,'n')
       accepted_val=1;
    else
        disp('Error: unacceptable answer. Acceptable answers are: y or n')
    end
end

switch(notify_flag2)
    case 'y'
        notify_flag2=1;
    case 'n'
        notify_flag2=0;
end

files_to_remove=[];
filenames=[];

for j = 1:length(files)
       
    errmsg='';
    [fid,errmsg]=fopen(fullfile(folder,files(j).name));

    if fid>0

        [old_site_code, averaging] = determine_old_site_code(files(j).name,old_codes_lookup_table);
        
        if averaging == AveragingType.Raw
            header_start_line=6; % header in raw data starts at line 6
        else
            header_start_line=7; % header in averaged data starts at line 7
        end
        
        % read lines until get to the line with column header
        for i=1:header_start_line
            data_header = fgetl(fid);
        end
        data_header = strsplit(data_header,',');
        num_columns = length(data_header);

        % create a string to be used in textscan to read data
        data_string = '%s';
        for i=1:num_columns
            data_string = strcat(data_string,' %s');
        end

        table_data = textscan(fid,data_string,'Delimiter',',');

        fclose(fid);
        
        table_data_temp=[];
        for i=1:length(table_data)
            table_next=table_data{1,i};
            table_data_temp=[table_data_temp, table_next];
        end
        
        table_data_temp(:,end)=[];       
        
        % Imnaviat site is different from all other sites. When the new MRC was
        % installed in 2017, variables from the old MRC were reused.
        % However, thermistor installation depths are different for the new MRC.
        % Additionally, the last two thermistors(variables) are not used on
        % the new MRC. Therefore, for datasets prior 2017, the special
        % flags file is loaded and used. One should be careful and not
        % use data that combine data obtained with both the old and the new
        % MRCs. The old MRC data ended on Jan 05, 2017. The new MRC data
        % starts on Aug 23, 2017.
        if ~strcmp(old_site_code,'IM1')
            for i=1:length(sites_flags_fn)
               if strcmp(old_site_code,sites_flags_fn{i})
                   flags=sites_flags.(sites_flags_fn{i});
               end
            end
        else
            dataset_year=str2double(table_data_temp{end,1}(1:4));
            if dataset_year>2017
                flags=sites_flags.IM1;
            else
                load('sites_flags_struct_IM.mat');
                flags=sites_flags_IM.IM1;
                disp(' ');
                disp('For IM1 site, h-file with information on the'); 
                disp('old MRC probe is going to be used');
            end
        end
        
        % remove [average] from all column headers
        if averaging>1 % for any averaging type
            for i=2:num_columns % exclude the timestamp column from loop
                data_header{i}=data_header{i}(1:end-num_chars_average);
            end
        end
        
        % remove averaging type from a filename
        switch averaging
            case AveragingType.Day
                files(j).name((end-num_char_csv-num_char_day):(end-num_char_csv)) = [];
            case AveragingType.Hour
            case AveragingType.Year
            case AveragingType.Week
                files(j).name((end-num_char_csv-num_chars_hwy):(end-num_char_csv)) = [];
            case AveragingType.Month
                files(j).name((end-num_char_csv-num_chars_month):(end-num_char_csv)) = [];
            case AveragingType.Raw
        end
        
        % create a data table with a header
        table_data = [data_header;table_data_temp];

        % Uncomment if you want the question to include a specific measurement type
        % to be asked for each file.
        % sensors_used=[-1,-1,-1,-1];
        
        flags_dim=size(flags);
        column_to_remove=[];
        
        for k=1:flags_dim(length_dim)  
            if find_cell_in_array(table_data(1,:),num_columns,flags(k))
                if ~isempty(flags{k,Flags.Type})
                    switch (flags{k,Flags.Type})
                        case 'd'    % date
                            % Currently, dates consistency is only checked for daily averaged data
                            if averaging==AveragingType.Day
                                table_data=check_dates_consistency(table_data,averaging,files(j).name);
                            end
                        case 't'    % temperature
                            if isempty(flags{k,Flags.AlwaysUsed})
                                sensors_used(SensorTypes.tempHYP) = check_column(sensors_used(SensorTypes.tempHYP),...
                                                                                 flags{k,Flags.Type},...
                                                                                 flags{k},files(j).name,...
                                                                                 notify_flag2);
                                if sensors_used(SensorTypes.tempHYP)==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 'w'    % VWC
                            if isempty(flags{k,Flags.AlwaysUsed})
                                sensors_used(SensorTypes.VWC) = check_column(sensors_used(SensorTypes.VWC),...
                                                                             flags{k,Flags.Type},...
                                                                             flags{k},files(j).name,...
                                                                             notify_flag2);
                                if sensors_used(SensorTypes.VWC)==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 's'    % snow depth
                            if isempty(flags{k,Flags.AlwaysUsed})
                                sensors_used(SensorTypes.SnwD) = check_column(sensors_used(SensorTypes.SnwD),...
                                                                              flags{k,Flags.Type},...
                                                                              flags{k},files(j).name,...
                                                                              notify_flag2);
                                if sensors_used(SensorTypes.SnwD)==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 'h'    % heat flux
                            if isempty(flags{k,Flags.AlwaysUsed})
                                sensors_used(SensorTypes.HtFx) = check_column(sensors_used(SensorTypes.HtFx),...
                                                                              flags{k,Flags.Type},...
                                                                              flags{k},files(j).name,...
                                                                              notify_flag2);
                                if sensors_used(SensorTypes.HtFx)==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                    end
                else
                    column_to_remove=[column_to_remove;k];
                    if notify_flag
                        disp(' ');
                        disp(['Warning: in ',files(j).name]);
                        disp(['unnecessary column "',flags{k},'" was removed']);
                    end
                end
            else
                if ~isempty(flags{k,Flags.Type})
                    disp(' ');
                    disp(['Warning: in ',files(j).name]);
                    disp(['column "',flags{k},'" is missing. Check input data']);
                end
            end
        end
       
        if ~isempty(column_to_remove) % empty means that only valid VDV variables were exported
            
            % remove columns marked for removal in both data and flags
            for i=length(column_to_remove):-1:1
                table_data(:,column_to_remove(i))=[];
                flags(column_to_remove(i),:)=[]; % flags variables are transposed
            end

            % update num_columns
            num_columns=num_columns-length(column_to_remove);

            % replace NULL with NaN
            table_data=replace_null_with_nan(table_data,num_columns);

            % remove columns with all NaNs
            [table_data,NaN_columns]=remove_nan_columns(table_data,files(j).name);

            % remove flags columns corresponding to all NaNs columns
            for i=length(NaN_columns):-1:1
                flags(NaN_columns(i),:)=[]; % flags variables are transposed
            end

            % update num_columns
            num_columns=num_columns-length(NaN_columns);

            % change headers
            [table_data,flag_split_data]=modify_vdv_headers(old_site_code,table_data,num_columns,flags);

            % split files if required
            if flag_split_data
                % determine the number of files
                num_files=max(str2double(flags(:,Flags.FileNumber)));
                for i=1:num_files
                    new_filename=split_data(i,table_data,flags,old_site_code,new_codes_lookup_table,...
                               folder_modified,files(j).name,averaging,sensors_used);
                    filenames=[filenames;cellstr(new_filename)];
                end
            else
                site_code=lookup_site_name(old_site_code,new_codes_lookup_table);
                new_filename=modify_reorder_and_save_table(table_data,flags,site_code,...
                                         folder_modified,files(j).name,...
                                         averaging,sensors_used);
                filenames=[filenames;cellstr(new_filename)];
            end
        
        else
            disp(' ');
            disp(['Warning: in ',files(j).name,',']);
            disp('not all variables have been exported from VDV.');
            disp('To work properly, this script requires all variables to be exported.');
            disp('Therefore, this file will not be processed');
        end

    else
        disp(' ');
        disp(errmsg);
    end
   
end

if ~isempty(filenames)
    writetable(cell2table(filenames),fullfile(folder_modified,'!GIPL_FileNames_List.csv'),...
    'WriteVariableNames',false);
end

diary off