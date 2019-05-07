function [heave,heave_set] = heave_user_input(site_code,subcode,file_number,dataset_year,heave_set)
%This function asks a user to provide heave information

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

