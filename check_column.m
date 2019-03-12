function [flag]=check_column(flag,measure_type,column_name,filename)
%This function helps making code more readable

    if flag==-1
        flag = is_meas_type_reqd(measure_type);
    end
    if flag==0
        disp(['Warning: in ',filename]);
        disp(['column "',column_name,'" was removed per user request']);
        disp(' ');
    end

end

