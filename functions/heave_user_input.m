function [heave,heave_set] = heave_user_input(site_code,file_number,dataset_year,heave_set)
%This function asks a user to provide heave information

    % boil is always 1, interboil is always 2
    if file_number==1 && ~strcmp(site_code,'IV4')
        subcode='_boil';
    else
        if file_number==1 && strcmp(site_code,'IV4')
            subcode='_North';
        else
            if file_number==2 && ~strcmp(site_code,'IV4')
                subcode='_interboil';
            else
                if file_number==2 && strcmp(site_code,'IV4')
                    subcode='_South';
                else   
                    if isnan(file_number)
                        subcode='';
                    end
                end
            end
        end
    end

    prompt = ['For ',site_code,subcode,' enter heave in m measured in ',num2str(dataset_year-1),':\n'];

    accepted_value = 0;
    while ~accepted_value
        disp(' ');
        heave = input(prompt);
        if heave >=-0.4 && heave <=1
            accepted_value=1;
            heave_set=modify_heave_flag(heave_set,file_number);
        else
            disp('Error. Heave value should be between -0.3 to 1 meter\n');
        end
    end
end

