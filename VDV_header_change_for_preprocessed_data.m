clear
clc

header_start_line=12;
date_position_in_name=5;

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

for j = 1:length(files)
   
    if ~exist(fullfile(folder_modified,files(j).name),'file')
       
        fid=fopen(fullfile(folder,files(j).name));

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

        data_header{1}='Date';
        
        % add '+' sign for all positive depths
        for i=2:num_columns
            if ~strcmp(data_header{i}(10),'-') &&...
               ~strcmp(data_header{i}(10),'A') &&...
               ~strcmp(data_header{i}(10),'S')
                data_header{i}=strcat(data_header{i}(1:9),'+',data_header{i}(10:end));
            end
            
            if strcmp(data_header{i}(10),'A')
                data_header{i}(10)='a';
            else
                if  strcmp(data_header{i}(10),'S')
                    data_header{i}(10)='s';
                else
                    data_header{i}=strcat(data_header{i}(10),'00',data_header{i}(11:end));
                end
            end
            
            if ~strcmp(data_header{i}(end),'m')
                data_header{i}(end)='m';
            end
        end
        
    end
    
end

