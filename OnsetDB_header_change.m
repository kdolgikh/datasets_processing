clear
clc

% prompt for directory
prompt = 'Enter or copy a path to a directory with .csv \nfiles exported from OnsetDB. \nNote that path should end with "\\":\n';
folder = input(prompt,'s');

% prompt for sensor type
prompt = 'Enter or copy a sensor type (TMC, THB, or TMB):\n';
sensor_type = input(prompt,'s');

% folder = 'D:\GoogleDrive\!GIPL\Data\APP\datasets\2018-Copy\';
files = dir(fullfile(folder, '*.csv'));

for j = 1:length(files)
    
    opts=detectImportOptions([folder files(j).name]);
    table=readtable([folder files(j).name],opts);
    table(:,10)=[]; % delete column 10
    table.Properties.VariableNames(1) = 'DATE';
    
    for i = 2:width(table)
        height = num2str(table{1,i});
        table.Properties.VariableNames(i) = strcat('Temp_',sensor_type,'_',height);
    end
    
    
    
    table.(name).Var1{3}='site_code:'; %replace "site_name" with "site_code"
    
    % replace site name from Onset DB with NGEE site code:
    % for "Council" or "CN" - "CN_MM_71"
    % for "Kougarok" - "KG_MM_64"
    % for "Teller Road" - "TL_MM_27" 
    if isempty(strfind(table.(name).Var2{3},'Council')) == false
        table.(name).Var2{3}=' "CN_MM_71" ';
    end
        
    if isempty(strfind(table.(name).Var2{3},'CN')) == false
        table.(name).Var2{3}=' "CN_MM_71" ';
    end
    
    if isempty(strfind(table.(name).Var2{3},'Kougarok')) == false
        table.(name).Var2{3}=' "KG_MM_64" ';
    end
    
    if isempty(strfind(table.(name).Var2{3},'Teller')) == false
        table.(name).Var2{3}=' "TL_MM_27" ';
    end    
    
    table.(name).Var1{4}='area_code:'; %replace "site_code" with "area_code"
    
    table.(name)([5,6],:)=[]; % delete rows 5,6
    
    table.(name).Var2{10}=' "Soil temperature [°C] and moisture [VWC] data collected at multiple depths by HOBO systems located at Intensive Monitoring Stations. Data are retrieved annually." ';
    table.(name).Var1{14}='Date'; % replace "date/time" with "Date"

    % replace  "Temp [°C]" with "Tsoil_depth"
    for i = 2:6
        depth_next = table.(name){15,i};
        table.(name){14,i}=strcat('Tsoil_',cellstr(depth_next),'m');
    end

    % replace "Water Content [N/A]" with "VWC_depth"
    for i = 7:9
        depth_next = table.(name){15,i};
        table.(name){14,i}=strcat('VWC_',cellstr(depth_next),'m');
    end

    table.(name)(15,:)=[]; % delete row 15

    % change date format
    table_size = size(table.(name));
    time=[];
    for i = 15:table_size(1)
        if strcmp(table.(name){i,1},'') == false % sometimes imported data has empty strings in the end - checking for this
            time = datetime(table.(name){i,1},'Format','MM/dd/yyyy');  %specify original date formatting
            table.(name){i,1}=cellstr(datestr(time,'yyyy-mm-dd'));     %change formatting and assign newly formatted date instead of original date
        end
    end

    % save modified .csv file with the same name as original file
    writetable(table.(name),files(j).name,'WriteVariableNames',false);
end
