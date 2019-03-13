function [flag]=check_column(flag,measure_type,column_name,filename,display_flag)
%This function helps making code more readable by hiding repeated actions

    if flag==-1
        flag = is_meas_type_reqd(measure_type);
    end
    if flag==0
        if display_flag
            disp(' ');
            disp(['Warning: in ',filename]);
            disp(['column "',column_name,'" was removed per user request']);
        end
    end

end

