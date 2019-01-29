function [table] = remove_NaN_columns(table)
%This function removes columns that contain only NaNs
%Input data should have the following format:
%- the first column should be date
%- the first row should be a header for data
%With this formatting, the first data cell will be {2,2}

    table_size = size(table);
    length_dimension = 1;
    width_dimension = 2;
    NaN_column=[];

    i=2;
    for j=2:table_size(width_dimension)
        while i <= table_size(length_dimension) && strcmp(table{i,j},'NaN')
            i=i+1;
        end
        
        if i==table_size(length_dimension)+1
            NaN_column=[NaN_column,j];
            i=2; % reset i
        end
    end
    
    % remove columns with all NaNs
    for i=length(NaN_column):-1:1
        table(:,NaN_column(i))=[];
    end

end

