function [depth,heave,heave_set] = update_depth(site_code,dataset_year,...
            install_depth,heave_table,heave,heave_set,file_number)
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
    
    global length_dim;
    global width_dim;
    heave_table_dim=size(heave_table);
    
    header_row=1;
    site_code_column=1;
    file_number_column=2;
    year_column=3;
    
    if (~heave_set(HeaveSet.File1) && file_number==1) ||...
            (~heave_set(HeaveSet.File2) && file_number==2) ||...
            (~heave_set(HeaveSet.File3) && file_number==3) ||...
            (all(heave_set)==0 && isnan(file_number))
           
        % check year
        % if no year, then ask user.
        % if year, then check file number 
        % if no data for the year and file number, ask user
        
        for i=heave_table_dim(width_dim):-1:year_column
            if str2double(heave_table{header_row,i})==(dataset_year-1)
                for j=(header_row+1):heave_table_dim(length_dim)
                    if strcmp(site_code,heave_table{j,site_code_column})
                        if ~isempty(heave_table{j,file_number_column})
                            if str2double(heave_table{j,file_number_column})==file_number
                                if ~isempty(heave_table{j,i})
                                    heave=str2double(heave_table{j,i});
                                    heave_set=modify_heave_flag(heave_set,file_number);
                                    break;
                                else
                                    [heave,heave_set]=heave_user_input(site_code,file_number,dataset_year,heave_set);
                                    break;
                                end
                            end
                        else
                            if ~isempty(heave_table{j,i})
                                heave=str2double(heave_table{j,i});
                                heave_set=modify_heave_flag(heave_set,file_number);
                                break;
                            else
                                [heave,heave_set]=heave_user_input(site_code,file_number,dataset_year,heave_set);
                                break;
                            end
                        end
                    end
                end
                break;
            else
                if i==year_column && any(heave_set)==0
                    heave=heave_user_input(site_code,file_number,dataset_year,heave_set);
                end
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

