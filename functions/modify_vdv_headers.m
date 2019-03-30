function [table,split_required] = modify_vdv_headers(site_code,table,num_columns,flags)
%This function modifies vdv headers according to the GIPL standard
%Inputs:
%site_code
%table - input data table
%num_columns - number of columns in input data table
%flags - file with table headers and associated flags derived from the
%site's h-file.
%Output:
%table - the data table with modified headers
%split_required - a flag that shows that some files have to be splitted in
%two files

    % if heave was set for a probe, then don't need to ask the user again
    % to enter heave. Ask, however, if it is the second probe
    heave_set_flag = 0;
    heave=0;

    split_required=0;
    
    % determine the data set year from the last timestamp
    dataset_year=str2double(table{end,1}(1:4));
    
    for i=2:num_columns % skip the timestamp column
       if strcmp(flags(i,Flags.Type),'t')
           if strcmp(flags(i,Flags.Sensor),'MRC') || strcmp(flags(i,Flags.Sensor),'THP')
                if strcmp(flags(i,Flags.OriginalDepth),'a')
                   table{1,i}=strcat('Temp_',flags(i,Flags.Sensor),'_air');
                else
                    if strcmp(flags(i,Flags.OriginalDepth),'s')
                        table{1,i}=strcat('Temp_',flags(i,Flags.Sensor),'_surf');
                    else
                        [depth,heave,heave_set_flag]=update_depth(site_code,...
                                                     dataset_year,...
                                                     str2double(flags(i,Flags.OriginalDepth)),...
                                                     heave, heave_set_flag,...
                                                     str2double(flags(i,Flags.FileNumber)));
                        table{1,i}=strcat('Temp_',flags(i,Flags.Sensor),'_',depth,'m');
                        if ~isnan((str2double(flags(i,Flags.FileNumber)))) && ~split_required
                            split_required=1;
                        end
                    end
                end                            
           else % for all other temp sensors
               if strcmp(flags(i,Flags.OriginalDepth),'a')
                   table{1,i}=strcat('Temp_',flags(i,Flags.Sensor),'_air');
               else
                   if strcmp(flags(i,Flags.OriginalDepth),'s')
                       table{1,i}=strcat('Temp_',flags(i,Flags.Sensor),'_surf');
                   else
                       depth=str2double(flags(i,Flags.OriginalDepth));
                       depth=num2str(depth,'%+07.2f');
                       table{1,i}=strcat('Temp_',flags(i,Flags.Sensor),'_',depth,'m');
                   end
               end          
           end
       else
           if strcmp(flags(i,Flags.Type),'w')
               depth=str2double(flags(i,Flags.OriginalDepth));
               depth=num2str(depth,'%+07.2f');
               table{1,i}=strcat('VWC__',flags(i,Flags.Sensor),'_',depth,'m');
           else
               if strcmp(flags(i,Flags.Type),'s')
                   table{1,i}=strcat('SnwD_',flags(i,Flags.Sensor));
               else
                   if strcmp(flags(i,Flags.Type),'h')
                       table{1,i}=strcat('HtFx_',flags(i,Flags.Sensor));
                       % for now, heat flux sensors depth is not accounted
                       % for
                   end
               end
           end
       end
    end

    

end

