function [table] = pad_missing_dates_and_data(table,dates,missing_dates_index,meas_rate)
%This function adds missing dates and pads data, that corresponds to these
%dates, with NaNs. It currently accepts only daily averages of data.
    
    width_dim=2;
    table_dim=size(table);
    
    for i=1:length(missing_dates_index)    
        % determine number of rows to pad. Index (i)-1 accounts for the fact that
        % dates are less than table by 1 (header is removed)
        
        % indices of rows in dates are smaller by 1 compared to the indices
        % of the corresponding rows in table. Therefore i below points to
        % the end data in the inconsistency (inconsistency includes a
        % start and an end date), and (i)-1 points to the start date
        num_rows_to_pad=...
            (dates(missing_dates_index(i))-dates(missing_dates_index(i)-1))/meas_rate-1;
        
        table_end=table(((missing_dates_index(i)+1):end),:);
        dates_end=dates((missing_dates_index(i):end),:);
        
        table_start=table((1:missing_dates_index(i)),:);
        dates_start=dates((1:(missing_dates_index(i)-1)),:);
        
        padding=cell(num_rows_to_pad,table_dim(width_dim));
        padding_dates=NaT(num_rows_to_pad,1);
        
        table_start=cat(1,table_start,padding);
        dates_start=vertcat(dates_start,padding_dates);
        
        table=cat(1,table_start,table_end);
        dates=vertcat(dates_start,dates_end);
        
        for j=1:num_rows_to_pad
            for k=1:table_dim(width_dim)
                if k==1
                    date_start=datetime(table((missing_dates_index(i)-1+j),k));
                    table{(missing_dates_index(i)+j),k}=...
                        datestr((date_start+meas_rate),'YYYY-mm-dd');
                else
                    table{(missing_dates_index(i)+j),k}='NaN';
                end
            end
        end
        if length(missing_dates_index)>1 && i<length(missing_dates_index)
            missing_dates_index((i+1):end)=missing_dates_index((i+1):end)+num_rows_to_pad;
        end
    end
    
    disp('Missing dates were recovered and data was padded with NaNs');
    
end

