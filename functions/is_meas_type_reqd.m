function [answer] = is_meas_type_reqd(measurement_type)
%This function asks a user if a specific measurement type is required and
%returns the user's answer
    
    switch (measurement_type)
        case 't'
            measurement_type = 'HydraProbe temperature';
        case 'w'
            measurement_type = 'VWC';
        case 's'
            measurement_type = 'snow depth';
        case 'h'
            measurement_type = 'heat flux';
    end
    
    disp(' ');
    accepted_val = 0;        
    while ~accepted_val
        prompt = ['Is measurement type "',measurement_type,'" required\nin this data set? Answer y/n \n'];
        answer = input(prompt,'s');
        if strcmp(answer,'y') || strcmp(answer,'n')
           accepted_val=1; 
        end
    end
    
    switch(answer)
        case 'y'
            answer=1;
        case 'n'
            answer=0;
    end
    
end

