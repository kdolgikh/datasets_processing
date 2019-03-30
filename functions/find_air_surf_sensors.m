function [sensor_row_ind] = ...
    find_air_surf_sensors(flags,sensor_type,filename)
%This function determines the number and indeces of air or surface
%temperature measurements in the flags table

    global length_dim;

    if strcmp(sensor_type,'a')
        sensor='air';
    else
        if strcmp(sensor_type,'s')
            sensor='surface';
        else
            disp(' ')
            disp(['Error: in ',filename]);
            disp('unrecognized sensor type is encountered');
        end
    end
    
    flags_dim=size(flags);
    
    sensor_row_ind=[];
    j=1;
    for i=2:flags_dim(length_dim)
       if strcmp(flags(i,Flags.OriginalDepth),sensor_type)
            sensor_row_ind(j)=i;
            j=j+1;
       end
    end
    
    if length(sensor_row_ind)>2 % more than two measurement of the same type
        disp(' ');
        disp(['Warning: in ',filename]);
        disp(['there are ',length(sensor_row_ind),' ',sensor,' temperature measurements']);
        disp('The script expects not more than 2 measurements of this type');
        disp('Therefore, only the first 2 measurements will be included into the sorted table');
        sensor_row_ind=sensor_row_ind(1:2);
    else
        if isempty(sensor_row_ind)
            disp(' ');
            disp(['Warning: in ',filename]);
            disp(['there are no ',sensor,' temperature measurements']);
        end
    end

end

