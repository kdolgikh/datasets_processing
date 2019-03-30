function split_data(file_number,table,flags,old_site_code,...
                    site_code_lookup_table,folder,...
                    filename,averaging_type,used_sensors)
%This function removes data that do not belong to the file,
%then assignes a new site code and a filename, and saves the file
    
    global length_dim;  
    flags_dim=size(flags);

    for i=flags_dim(length_dim):-1:2 % skip Timestamp column
        if ~strcmp(flags(i,Flags.FileNumber),num2str(file_number))
           table(:,i)=[];
           flags(i,:)=[];
        end
    end
    
    site_code=lookup_site_name(old_site_code,site_code_lookup_table);
    
    % change the site code from XX_XXX_X00 to XX_XXX_X01 and XX_XXX_X02
    site_code(end)=num2str(file_number);
    
    modify_reorder_and_save_table(table,flags,site_code,folder,...
                             filename,averaging_type,used_sensors);

end

