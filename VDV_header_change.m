clear
clc

load('sites_flags_struct.mat');
sites_flags_fn=fieldnames(sites_flags);
old_codes_lookup_table = load_lookup_table('sites_old_code_lookup.csv');

header_start_line=7;

% If flags are moved inside the j = 1:length(files) loop,
% then question to include a specific measurement type into a dataset
% will be asked for every file.
% When these flags are initialized outside the loop (as below), such
% question will be asked only once.
t_flag=-1; w_flag=-1; s_flag=-1; h_flag=-1;

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
        
        old_site_code = determine_old_site_code(files(j).name,old_codes_lookup_table);
        
        for i=1:length(files)
           if strcmp(old_site_code,sites_flags_fn{i})
               flags=sites_flags.(sites_flags_fn{i});
           end
        end
        
        table_data = [data_header;table_data_temp];

        column_to_remove=[];
        
        for k=1:length(flags)    
            if find_cell_in_array(table_data(1,:),num_columns,flags(k))
                if ~isempty(flags{k,Flags.Type})
                    switch (flags{k,Flags.Type})
                        case 'd'    % date
                            % TODO: check consistency of dates
                        case 't'    % temperature
                            if isempty(flags{k,Flags.AlwaysUsed})
                                t_flag = check_column(t_flag,flags{k,Flags.Type},...
                                            flags{k},files(j).name,notify_flag2);
                                if t_flag==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 'w'    % VWC
                            if isempty(flags{k,Flags.AlwaysUsed})
                                w_flag = check_column(w_flag,flags{k,Flags.Type},...
                                            flags{k},files(j).name,notify_flag2);
                                if w_flag==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 's'    % snow depth
                            if isempty(flags{k,Flags.AlwaysUsed})
                                s_flag = check_column(s_flag,flags{k,Flags.Type},...
                                            flags{k},files(j).name,notify_flag2);
                                if s_flag==0
                                   column_to_remove=[column_to_remove;k];
                                end
                            end
                        case 'h'    % heat flux
                            if isempty(flags{k,Flags.AlwaysUsed})
                                h_flag = check_column(h_flag,flags{k,Flags.Type},...
                                            flags{k},files(j).name,notify_flag2);
                                if h_flag==0
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
       
        % remove columns marked for removal
        for i=length(column_to_remove):-1:1
            table_data(:,column_to_remove(i))=[];
        end
        
        % update num_columns
        num_columns=num_columns-length(column_to_remove);
        
        % replace NULL with NaN
        table_data = replace_null_with_nan(table_data,num_columns);
        
        % remove columns with all NaNs
        table_data = remove_nan_columns(table_data,files(j).name);
        
        
        % 
        
        
%         writetable(cell2table(table_data),fullfile(folder_modified,files(j).name),...
%         'WriteVariableNames',false);

        
    else
        disp(' ');
        disp(errmsg);
    end
   
end