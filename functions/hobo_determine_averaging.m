function [averaging] = hobo_determine_averaging(filename)
    
    num_csv_chars = 4;      % number of chars in ".csv"
    
    if strcmp(filename(end-6:end-num_csv_chars),'raw')
        averaging=AveragingType.Raw;
    else
        if strcmp(filename(end-6:end-num_csv_chars),'ily')
            averaging=AveragingType.Day;
        else
            if strcmp(filename(end-6:end-num_csv_chars),'hly')
                averaging=AveragingType.Month;
            end
        end
    end
end

