function [result] = find_cell_in_array(cell_array,cell_array_length,cell_to_find)
%This function finds a cell in the array of cells and returns 1 if a match
%has been found and 0 if a match hasn't been found.
%Only one cell string should be passed to the function.

    result = 0;
    
    for i=1:cell_array_length
        if strcmp(cell_to_find,cell_array(1,i))
            result = 1;
            break;
        end
    end

end

