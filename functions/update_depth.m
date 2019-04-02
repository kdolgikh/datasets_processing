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
    
    if (~heave_set(HeaveSet.File1) && file_number==1) ||...
            (~heave_set(HeaveSet.File2) && file_number==2) ||...
            (~heave_set(HeaveSet.File3) && file_number==3) ||...
            (all(heave_set)==0 && isnan(file_number))
        accepted_value = 0;
        while ~accepted_value
            disp(' ');
            heave = input(prompt);
            if heave >=-0.4 && heave <=1
                accepted_value=1;
                if file_number==1
                    heave_set(HeaveSet.File1)=1;
                else
                    if file_number==2
                        heave_set(HeaveSet.File2)=1;
                    else
                        if file_number==3
                            heave_set(HeaveSet.File3)=1;
                        else
                            if isnan(file_number)
                                heave_set=[1,1,1];
                            end
                        end
                    end
                end
            else
                disp('Error. Heave value should be between -0.3 to 1 meter\n');
            end
        end
    end

    if strcmp(site_code,'DH1')
        depth = round((install_depth-(heave-0.18)),2);
    else
        if strcmp(site_code,'FB1')
            depth = round((install_depth-(heave-0.145)),2);
        else
            if strcmp(site_code,'WD1')
                depth = round((install_depth-(heave-0.185)),2);
            else
                depth = round((install_depth - heave),2);
            end
        end
    end

    % return depth as a string of format +/-XXX.XX
    depth=num2str(depth,'%+07.2f');
    
end

