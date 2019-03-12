function [table] = replace_null_with_nan(table,table_width)
%This function replaces all NULLs with NaNs in a data table containing cell
%arrays

   for i=1:length(table)
       for j=1:table_width
           if strcmp(table{i,j},'NULL')
              table{i,j}='NaN'; 
           end
       end 
    end

end

