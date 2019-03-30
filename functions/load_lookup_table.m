function [lookup_table] = load_lookup_table(lookup_table_name)
% This function loads a lookup table, which is a .csv file with
% two columns of data - original values and new values associated
% with the original values.
    lookup_table=[];
    
    [fid,errmsg]=fopen(lookup_table_name,'r','n','UTF-8');
    
    if fid >0      
        lookup_t = textscan(fid,'%s %s','Delimiter',',');
        fclose(fid);
        
        for i=1:length(lookup_t)
            table_next=lookup_t{1,i};
            lookup_table=[lookup_table, table_next];
        end
        
        % when exporting with UTF-8 encoding, the first character may be '',
        % we need to remove it.
        % Warning! Because of this check, value in lookup
        % table should start with a letter only!
        if ~isletter(lookup_table{1,1}(1))
            lookup_table{1,1}(1)=[];
        end
            
    else
        disp(' ');
        disp(errmsg);
    end

end

