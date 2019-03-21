clear
clc

load('sites_flags_struct.mat');
sites_flags_fn=fieldnames(sites_flags);
old_codes_lookup_table = load_lookup_table('sites_old_code_lookup.csv');

header_start_line=7; % header in exported data starts at line 7
date_start_line=2; % the row in which date starts for !processed! data
date_position_in_name=12; % index of the first date character for a !processed! site name
average_length=9; % number of chars in [average]

% If flags are moved inside the j = 1:length(files) loop,
% then question to include a specific measurement type into a dataset
% will be asked for every file.
% When these flags are initialized outside the loop (as below), such
% question will be asked only once.
flag_t=-1; % HydraProbe temperature flag
flag_w=-1; % VWC flag
flag_s=-1; % snow depth flag
flag_h=-1; % heat flux flag

% prompt for directory
prompt = 'Enter\\copy a path to a directory with .csv \nfiles exported from VDV:\n';
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

for j = 1:length(files)
       
    errmsg='';
    [fid,errmsg]=fopen(fullfile(folder,files(j).name));

    if fid>0

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
        
        [old_site_code, averaging] = determine_old_site_code(files(j).name,old_codes_lookup_table);
        
        for i=1:length(files)
           if strcmp(old_site_code,sites_flags_fn{i})
               flags=sites_flags.(sites_flags_fn{i});
           end
        end
        
        % remove [average] from all column headers
        if averaging>1 % for any averaging type
            for i=2:num_columns % exclude the timestamp column from loop
                data_header{i}=data_header{i}(1:end-average_length);
            end
        end
        
        
        table_data = [data_header;table_data_temp];

% Uncomment if you want the question to include a specific measurement type
% to be asked for each file.
%         flag_t=-1; % HydraProbe temperature flag
%         flag_w=-1; % VWC flag
%         flag_s=-1; % snow depth flag
%         flag_h=-1; % heat flux flag
        column_to_remove=[];
        
        for k=1:length(flags)    
            if find_cell_in_array(table_data(1,:),num_columns,flags(k))
                if ~isempty(flags{k,Flags.Type})
                    switch (flags{k,Flags.Type})
                        case 'd'    % date
                            % TODO: check consistency of dates
                        case 't'    % temperature
                            if isempty(flags{k,Flags.AlwaysUsed})
                                flag_t = check_column(flag_t,flags{k,Flags.Type},...
                                            flags{k},files(j).name,notify_flag2);
                                if flag_t==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 'w'    % VWC
                            if isempty(flags{k,Flags.AlwaysUsed})
                                flag_w = check_column(flag_w,flags{k,Flags.Type},...
                                            flags{k},files(j).name,notify_flag2);
                                if flag_w==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 's'    % snow depth
                            if isempty(flags{k,Flags.AlwaysUsed})
                                flag_s = check_column(flag_s,flags{k,Flags.Type},...
                                            flags{k},files(j).name,notify_flag2);
                                if flag_s==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 'h'    % heat flux
                            if isempty(flags{k,Flags.AlwaysUsed})
                                flag_h = check_column(flag_h,flags{k,Flags.Type},...
                                            flags{k},files(j).name,notify_flag2);
                                if flag_h==0
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
        [table_data]=modify_vdv_headers(old_site_code,table_data,num_columns,flags);
        
        % split files if required
        
        % reorder columns
        
        % change filename:
        % 1) replace an old site code with a new site code
        
        
        % 2) verify dates, remove NaN rows in the beginning/end, and update
        % the name
%         [table_data,files(j).name] =...
%             modify_file_name(table_data,date_start_line,files(j).name,date_position_in_name);
        
        %save file
%         writetable(cell2table(table_data),fullfile(folder_modified,files(j).name),...
%         'WriteVariableNames',false);

        
    else
        disp(' ');
        disp(errmsg);
    end
   
end