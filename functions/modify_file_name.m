function [table,name] = modify_file_name(table,date_pos_in_table,name,...
    date_pos_in_name)
% This function checks the first and the last dates of the data and changes
% the name to be consistent with actual dates. It also removes all
% NaNs row for the first/last date in the data.
% It also uses the following positions of the start/end date start and end
% characters, which is always true for data exported from OnsetDB and VDV:
% date_pos_in_name+9  : position of the last char in the first date
% date_pos_in_name+11 : position of the first char in the last date
% date_pos_in_name+20 : position of the last char in the last date

% Input: a table, a filename, the position of the date in the table (row)
% and the position of the date in the filename (index).
% Output: modified table and filename.
    
    table_size = size(table);
    date_column = 1;
    date_start_index=1; % beginning of the date
    date_stop_index=10; % end of the date
    length_dimension = 1;
    width_dimension = 2;
    
    % Find the first date and compare it with the first date in name
    if ~strcmp(table{date_pos_in_table,date_column}(date_start_index:date_stop_index),...
            name(date_pos_in_name:(date_pos_in_name+9)))
       name(date_pos_in_name:(date_pos_in_name+9))=...
           table{date_pos_in_table,date_column}(date_start_index:date_stop_index);
    end
    
    % Check if the first row contains all NaNs and remove this row if it
    % does. There may be several rows containing all NaNs.
    i=1;
    j=0;
    while j<table_size(length_dimension)
        while i<table_size(width_dimension) &&...
                strcmp(table{date_pos_in_table+j,date_column+i},'NaN')
            i=i+1;
        end
        if i<table_size(width_dimension)
           break;
        end
        i=1;
        j=j+1;
    end
    
    if j>0
       for k=(date_pos_in_table+j-1):-1:date_pos_in_table
           table(date_pos_in_table,:) = [];
       end
       name(date_pos_in_name:(date_pos_in_name+9))=...
           table{date_pos_in_table,date_column};    % update the name
       table_size = size(table);                    % update table size
    end
    
    % Find the last date and compare it with the last date in name
    if ~strcmp(table{table_size(1),date_column}(date_start_index:date_stop_index),...
            name((date_pos_in_name+11):(date_pos_in_name+20)))
       name((date_pos_in_name+11):(date_pos_in_name+20))=...
           table{table_size(length_dimension),date_column}(date_start_index:date_stop_index);
    end
    
    % Check if the last row contains all NaNs and remove this row if it
    % does. There can be several rows containing all NaNs.  
    i=1;
    j=table_size(length_dimension);
    while j>1
        while i<table_size(width_dimension) &&...
                strcmp(table{j,date_column+i},'NaN')
            i=i+1;
        end
        if i<table_size(width_dimension)
           break;
        end
        i=1;
        j=j-1;
    end
    
    if j<table_size(length_dimension)
       for k=table_size(length_dimension):-1:(j+1)
           table(k,:) = [];
       end
       name((date_pos_in_name+11):(date_pos_in_name+20))=...
           table{j,date_column};    % update the name
    end

end

