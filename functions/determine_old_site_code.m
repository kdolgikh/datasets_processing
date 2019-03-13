function [old_site_code] = determine_old_site_code(filename,lookup_table)
% This function determines a site code  from VDV filename
% VDV has five averaging types: hour, day, week, month, and year.
% It also hase a very specific date format.
% These two factors are used to determine the number of characters that
% belong to a SiteName

% Input - VDV filename
% Output - three chars old style SiteCode

% All VDV sites have a unique three chars site code. For new VDV stations
% it will be necessary to assign a 3 chars old style site code.
% When preparing files for submission, which, among other things, 
% will include creating new files for different installation types
% belonging to one site, new style site codes will be generated.
    
    num_date_chars = 22;    % number of date characters
    num_csv_chars = 4;      % number of chars in ".csv"
    start_index=5;          % start after "vdv_"
    stop_index=length(filename)-num_date_chars;
    
    if strcmp(filename(end-6:end-num_csv_chars),'our')
        stop_index=stop_index-9;
    else
        if strcmp(filename(end-6:end-num_csv_chars),'day')
            stop_index=stop_index-8;
        else
            if strcmp(filename(end-6:end-num_csv_chars),'eek')
                stop_index=stop_index-9;
            else
                if strcmp(filename(end-6:end-num_csv_chars),'nth')
                    stop_index=stop_index-10;
                else
                    if strcmp(filename(end-6:end-num_csv_chars),'ear')
                        stop_index=stop_index-9;
                    else % no averaging (RAW) 
                        stop_index=stop_index-num_csv_chars;
                    end
                end
            end
        end
    end
    
    sitename=filename(start_index:stop_index);
    old_site_code=lookup_site_name(sitename,lookup_table);

end

