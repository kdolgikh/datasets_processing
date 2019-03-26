function modify_filename_and_save(table,flags,site_code,...
                                  folder,filename,averaging_type,...
                                  used_sensors)
%This function assignes a new site code, checks consistency of dates in the
%filename and inside the table, reorders columns, and saves the file.

    num_chars_date=21; % number of chars in the date YYYY-MM-DD_YYYY-MM-DD 
    num_chars_csv=4; % number of chars in .csv
    date_position_in_name=12; % for the filename with the new site code
    date_row_in_table=2;
    
    % specify the filename ending for different averaging types
    switch averaging_type
        case AveragingType.Day
            filename_ending='_daily';
        case AveragingType.Hour
            filename_ending='_hourly';
        case AveragingType.Year
            filename_ending='_annually';
        case AveragingType.Week
            filename_ending='_weekly';
        case AveragingType.Month
            filename_ending='_monthly';
    end
    
    %retrieve the part of the filename containing dates
    file_dates = filename((end-num_chars_csv-num_chars_date):(end-num_chars_csv));
    
    % create the new filename
    filename=strcat(site_code,file_dates,filename_ending,'.csv');
    
    % check that dates in the filename and inside the table are consistent,
    % update the filename if not.
    [table,filename]=modify_file_name(table,date_row_in_table,filename,date_position_in_name);
    
    % reorder columns
    reorder_columns(flags,filename,used_sensors);
    
    %save the file
    writetable(cell2table(table),fullfile(folder,filename),...
        'WriteVariableNames',false);
    
end

