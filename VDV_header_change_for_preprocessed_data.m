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

% z=0;

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
        depths=zeros(1,num_columns);
        depths_string=strings(1,num_columns);
        
        % add '+' sign for all positive depths
        for i=2:num_columns
            if strcmp(data_header{i}(6:7),'TS')||...    % thermistor string
                strcmp(data_header{i}(6:7),'TP')        % thermistor probe
                data_header{i}=strcat(data_header{i}(1:6),'H',data_header{i}(7:end));
            else
                if strcmp(data_header{i}(6:7),'HP') % hydra probe
                   data_header{i}=strcat(data_header{i}(1:6),'Y',data_header{i}(7:end)); 
                end
            end

            if strcmp(data_header{i}(10),'A')
                data_header{i}(10)='a';
            else
                if  strcmp(data_header{i}(10),'S')
                    data_header{i}(10)='s';
                else
                    depths(i)=str2double(data_header{i}(10:(end-1)));
                    depths_string(i)=generate_depth_string(depths(i));
                    data_header{i}=strcat(data_header{i}(1:9),depths_string(i),'m');
                end
            end
        end
        
        table_data_temp=[];
        for i=1:length(table_data)
            table_next=table_data{1,i};
            table_data_temp=[table_data_temp, table_next];
        end
        
        % This piece of code helped to determine that every file has an extra
        % column with null character ''
%         s=size(table_data_temp);
%         if s(2)>length(data_header)
%             z=z+1; %counts files with the extra column
%         end
        % Therefore, it is safe to remove the last column
        table_data_temp(:,end)=[];
        
        table_data = [data_header;table_data_temp];
        
        writetable(cell2table(table_data),fullfile(folder_modified,files(j).name),...
        'WriteVariableNames',false);
        
    end
    
end

