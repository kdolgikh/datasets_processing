function [table] = check_dates_consistency(table,averaging_type,filename)
%This function checks consistency of dates in a table. Consistency means
%that no dates are missing. If a date is missing, the function notifies a
%user. Currently, this function will only work for Day averaging
%as the averaging type of most interest for the lab.

    global header_start_line; % header in exported data starts at line 7
    do_not_execute=0;

    % dates are always in column #1, and the first row is always "Timestamp"
    dates_column_str=table(2:end,1);
    
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
        dates_column_datetime=[];
        for i=1:(length(dates_column_str)-1)
           date_current=datetime(dates_column_str(i));
           if i==1
               dates_column_datetime=date_current;
           end
           date_next=datetime(dates_column_str(i+1));    
           dates_column_datetime=[dates_column_datetime; date_next];
           if date_next-date_current>meas_rate
               inconsistent_date_index(j)=i+1; %plus 1 accounts for the ommited "Timestamp" row
               j=j+1;
           end
        end

        if ~isempty(inconsistent_date_index)
           disp(' ');
           disp(['Warning! In ',filename,',']);
           disp('the following rows have inconsistent dates');
           disp(num2str(inconsistent_date_index+header_start_line));
           table=pad_missing_dates_and_data(table,dates_column_datetime,...
                                            inconsistent_date_index,meas_rate);
        end
        

    
    end

end

