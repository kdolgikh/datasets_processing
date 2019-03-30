function [all_sensors] = find_all_sensors(flags,filename)
%This function finds all sensors that appear in a specific file

    global length_dim;

    num_sensors = 11; % number of sensor nomenclatures currently used in the lab (2019)
    
    flags_dim=size(flags); % use number of rows
    
    all_sensors=zeros(1,num_sensors);
    for i=1:flags_dim(length_dim)
        if strcmp(flags{i,Flags.Sensor},'MRC')
            if all_sensors(Sensors.MRC)==0
                all_sensors(Sensors.MRC)=1;
            end
        else
            if strcmp(flags{i,Flags.Sensor},'THP')
                if all_sensors(Sensors.THP)==0
                    all_sensors(Sensors.THP)=1;
                end
            else
                if strcmp(flags{i,Flags.Sensor},'107')
                    if all_sensors(Sensors.T107)==0
                        all_sensors(Sensors.T107)=1;
                    end
                else
                    if strcmp(flags{i,Flags.Sensor},'109')
                        if all_sensors(Sensors.T109)==0
                            all_sensors(Sensors.T109)=1;
                        end
                    else
                        if strcmp(flags{i,Flags.Sensor},'THS')
                            if all_sensors(Sensors.THS)==0
                                all_sensors(Sensors.THS)=1;
                            end
                        else
                            if strcmp(flags{i,Flags.Sensor},'HYP')
                                if all_sensors(Sensors.HYP)==0
                                    all_sensors(Sensors.HYP)=1;
                                end
                            else
                                if strcmp(flags{i,Flags.Sensor},'JUDS')
                                    if all_sensors(Sensors.JUDS)==0
                                        all_sensors(Sensors.JUDS)=1;
                                    end
                                else
                                    if strcmp(flags{i,Flags.Sensor},'SR50')
                                        if all_sensors(Sensors.SR50)==0
                                            all_sensors(Sensors.SR50)=1;
                                        end
                                    else
                                        if strcmp(flags{i,Flags.Sensor},'SR5A')
                                            if all_sensors(Sensors.SR5A)==0
                                                all_sensors(Sensors.SR5A)=1;
                                            end
                                        else
                                            if strcmp(flags{i,Flags.Sensor},'HF1')
                                                if all_sensors(Sensors.HF1)==0
                                                    all_sensors(Sensors.HF1)=1;
                                                end
                                            else
                                                if strcmp(flags{i,Flags.Sensor},'HF3')
                                                    if all_sensors(Sensors.HF3)==0
                                                        all_sensors(Sensors.HF3)=1;
                                                    end
                                                else
                                                    if isempty(flags{i,Flags.Sensor}) % very important to have curly braces
                                                        %do nothing
                                                    else
                                                        disp(' ');
                                                        disp(['Warning! In ',filename,',']);
                                                        disp([flags{i,Flags.Sensor},' is not recognized as a valid sensor.'])
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

end

