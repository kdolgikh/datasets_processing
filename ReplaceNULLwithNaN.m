clear
clc

% Used this script to replace NULLs with NaNs in preprocessed VDV data.
% It won't be used in the future.

header_start_line=1;

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
        
        for i=1:length(table_data_temp)
           for k=1:num_columns
               if strcmp(table_data_temp{i,k},'NULL')
                  table_data_temp{i,k}='NaN'; 
               end
           end 
        end

        table_data = [data_header;table_data_temp];
        
        writetable(cell2table(table_data),fullfile(folder_modified,files(j).name),...
        'WriteVariableNames',false);
        
    else
        disp(' ');
        disp(errmsg);
    end
   
end