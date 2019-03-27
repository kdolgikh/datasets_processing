function check_dates_consistency(dates_column,averaging_type,filename)
%This function checks consistency of dates in a table. Consistency means
%that no dates are missing. If a date is missing, the function notifies a
%user. Currently, this function will only work for Day averaging
%as the averaging type of most interest for the lab.

    do_not_execute=0;

    % for Raw and Hour measurements, measurement rate may vary from once
    % per hour to once per 6 or 8 hours. For other averaging types,
    % measurement rate is defined.
    if averaging_type == AveragingType.Raw || ...
        averaging_type == AveragingType.Hour
        do_not_execute=1;   
    else
        if averaging_type == AveragingType.Day
            meas_rate=days(1);
        else
            if averaging_type == AveragingType.Week
                do_not_execute=1;
            else
                if averaging_type == AveragingType.Month
                    do_not_execute=1; 
                else
                    if averaging_type == AveragingType.Year
                        do_not_execute=1; 
                    end
                end
            end
        end
    end
    
    if ~do_not_execute
    
        j=1;
        inconsistent_date_index=[];
        for i=1:(length(dates_column)-1)
           date_current=datetime(dates_column(i));
           date_next=datetime(dates_column(i+1));    
           if date_next-date_current>meas_rate
               inconsistent_date_index(j)=i;
               j=j+1;
           end
        end

        if ~isempty(inconsistent_date_index)
           disp(' ');
           disp(['Warning! In ',filename,',']);
           disp('the following rows have inconsistent dates');
           disp(num2str(inconsistent_date_index));
        end
    
    end

end

