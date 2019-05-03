function [data_table,header,num_columns] = read_table_data(fid,header_start_line)
%This function reads table data with unspecified number of columns.
%For the function to work, data table should be already open with fopen.

    % read lines until get to the line with column header
    for i=1:header_start_line
        header = fgetl(fid);
    end
    header = strsplit(header,',');
    num_columns = length(header);

    % create a string to be used in textscan to read data
    data_string = '%s';
    for i=1:num_columns
        data_string = strcat(data_string,' %s');
    end

    table_temp = textscan(fid,data_string,'Delimiter',',');

    data_table=[];
    for i=1:length(table_temp)
        table_next=table_temp{1,i};
        data_table=[data_table, table_next];
    end

    data_table(:,end)=[];
    
end

