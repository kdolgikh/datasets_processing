function [heave_flag] = modify_heave_flag(heave_flag,file_number)
%This function modifies heave_set flag when heave value has been entered

    if file_number==1
        heave_flag(HeaveSet.File1)=1;
    else
        if file_number==2
            heave_flag(HeaveSet.File2)=1;
        else
            if file_number==3
                heave_flag(HeaveSet.File3)=1;
            else
                if isnan(file_number)
                    heave_flag=[1,1,1];
                end
            end
        end
    end

end

