function [depth,heave,heave_set] = update_depth(site_code,dataset_year,...
            install_depth,heave,heave_set,file_number)
%This function updates depth of MRC/THP probe using heave information
%provided by a user
%Input:
%install_depth -  instalation depth
%site_code - WD1 site requires special formula to calculate depth.
%TODO: Check if there are other sites that require special formula.
%dataset_year - data set year is used to give a clue to the user on which
%year heave value to use
%Output:
%depth - updated depth
    
    % boil is always 1, interboil is always 2
    if file_number==1
        prompt = ['For ',site_code,'_boil, enter heave in cm measured in ',num2str(dataset_year-1),':\n'];
    else
        if file_number==2
            prompt = ['For ',site_code,'_interboil, enter heave in cm measured in ',num2str(dataset_year-1),':\n'];
        else
            if isnan(file_number)
                prompt = ['For ',site_code,', enter heave in cm measured in ',num2str(dataset_year-1),':\n'];
            end
        end
    end
    
    if (~heave_set && file_number==1) ||...
            (heave_set && file_number ==2) ||...
            (~heave_set && isnan(file_number))
        accepted_value = 0;
        while ~accepted_value
            disp(' ');
            heave = input(prompt)/100; % convert into meters
            if heave >=0 && heave <=1
                accepted_value=1;
                heave_set = ~heave_set; % flip the value
            else
                disp('Error. Heave value should be between 0 to 100 cm\n');
            end
        end
    end

    if ~strcmp(site_code,'WD1')
        depth = install_depth - heave;
    else
        depth = install_depth-(heave-0.185);
    end

    % return depth as a string of format +/-XXX.XX
    depth=num2str(depth,'%+07.2f');
    
end
