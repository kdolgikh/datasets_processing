function split_data(table,flags,old_site_code,...
                    site_code_lookup_table,folder,...
                    filename,averaging_type,used_sensors)
%This function split a table into two tables using info from flags,
%then assignes new site codes and filenames, and saves the files
    
    table1=table; flags1=flags;
    table2=table; flags2=flags;
    
    
    for i=length(flags):-1:2 % skip Timestamp column
        if strcmp(flags(i,Flags.FileNumber),'2')
           table1(:,i)=[];
           flags1(i,:)=[];
        end
    end
    
    for i=length(flags):-1:2 % skip Timestamp column
        if strcmp(flags(i,Flags.FileNumber),'1')
           table2(:,i)=[];
           flags2(i,:)=[];
        end
    end
    
    site_code=lookup_site_name(old_site_code,site_code_lookup_table);
    
    % change the site code from XX_XXX_X00 to XX_XXX_X01 and XX_XXX_X02
    site_code1=site_code;
    site_code1(end)='1';
    
    site_code2=site_code;
    site_code2(end)='2';
    
    modify_filename_and_save(table1,flags1,site_code1,folder,...
                             filename,averaging_type,used_sensors);
    modify_filename_and_save(table2,flags2,site_code2,folder,...
                             filename,averaging_type,used_sensors);

end

