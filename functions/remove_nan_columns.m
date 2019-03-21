function [table,NaN_columns] = remove_nan_columns(table,filename)
%This function removes columns that contain only NaNs
%Input data should have the following format:
%- the first column should be date
%- the first row should be a header for data
%With this formatting, the first data cell will be {2,2}
% The function also returns indexes of the removed columns 

    table_size = size(table);
    length_dimension = 1;
    width_dimension = 2;
    NaN_columns=[];

    i=2;
    for j=2:table_size(width_dimension)
        while i <= table_size(length_dimension) && strcmp(table{i,j},'NaN')
            i=i+1;
        end
        
        if i==table_size(length_dimension)+1
            NaN_columns=[NaN_columns,j];
            i=2; % reset i
        end
    end

    if ~isempty(NaN_columns)
        disp(' ');
        disp('The following columns containing all NaN values'); 
        disp(['were removed from ',filename,':']);
        for i=1:length(NaN_columns)
            disp(['Column #',num2str(NaN_columns(i)),': ',table{1,NaN_columns(i)}]);
        end
    end
    
    % remove columns with all NaNs
    for i=length(NaN_columns):-1:1
        table(:,NaN_columns(i))=[];
    end

end

