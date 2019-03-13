function [site_name_new] = lookup_site_name(site_name_old, lookup_table)
% This functions looks for a pair old name - new name and returns the new
% name value

    site_name_new = 'not_found';
    
    for i=1:length(lookup_table)
        if strcmp(lookup_table{i,1},site_name_old)
            site_name_new = lookup_table{i,2};
            break;
        end
    end
    
    if strcmp(site_name_new,'not_found')
        disp(' ');
        disp(['No match is found for the site name ',site_name_old,' in the provided lookup table']);
        site_name_new = site_name_old;
    end
    
end

