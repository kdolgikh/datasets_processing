clc
clear

num_csv_chars = 4;      % number of chars in ".csv"

% prompt for directory
prompt='Enter\\copy a path to a directory with .csv \nfiles with station flags:\n';
folder=input(prompt,'s');

% the directory should end with "\". Add "\" if it is missing
if ~strcmp(folder(end),'\')
    folder=strcat(folder,'\');
end

files=dir(fullfile(folder, '*.csv'));

% Ask a user to provide a lookup table
prompt='Enter the name of the sites lookup table:\n';
lookup_table_name=input(prompt,'s');
lookup_table=load_lookup_table(lookup_table_name);

sites_flags=struct();

for j = 1:length(files)
    
    errmsg='';
    [fid,errmsg]=fopen(fullfile(folder,files(j).name),'r','n','UTF-8');
    
    if fid>0
        
        hfile=textscan(fid,'%s %s %s %s %s','Delimiter',',');
        fclose(fid);
        
        h_file=[];
        for i=1:length(hfile)
            hfile_next=hfile{1,i};
            h_file=[h_file, hfile_next];
        end
        
       h_file(1,:)=[]; % remove the header row since we will not need it
        
        site_code=lookup_site_name(files(j).name(1:(end-num_csv_chars)),lookup_table);
        
        sites_flags.(site_code)=h_file;
        
    else
        disp(' ');
        disp(errmsg);
    end
    
end

save('sites_flags_struct.mat','sites_flags');

