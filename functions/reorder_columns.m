function [table_sorted]=reorder_columns(table,flags,filename,used_sensors)
%This function reorders columns, containing data from specific sensors.
%Ordering uses an order_value, which increases by 1 after each assignment.
%This value is passed to several functions, which find sensors of the
%specific type in the flags file. Therefore, the columns order is defined
%by the order in which these functions go.

    % value of the order, which increases by 1 after each assignment
    order_value=1;

    all_sensors=find_all_sensors(flags,filename);
    
    % create increasing indices for the table
    table_index = zeros(length(flags),1);
    table_index(1)=1;
    for i=2:length(flags)
        table_index(i)=table_index(i-1)+1;
    end
    
    % create an order array, which will be populated with sensors order
    order = zeros(length(flags),1);
    % concatenate table_index and order arrays
    index_order = cat(2,table_index,order);
    
    % assign order 1 to the timestamp column
    index_order(1,Sorting.Order)=order_value;
    order_value=order_value+1;
    
    % determine row indices for air  and surf temperature sensors
    ind_flgs_a=find_air_surf_sensors(flags,'a',filename);
    ind_flgs_s=find_air_surf_sensors(flags,'s',filename);
    
    % assign order to air and surf sensors
    [order_value,index_order]=...
        order_air_surf_sensors(order_value,index_order,ind_flgs_a,ind_flgs_s);
    
    % assign order to MRC sensors
    if all_sensors(Sensors.MRC)
        [order_value,index_order]=order_MRC_THP_sensors(order_value,index_order,flags);
    end
    
    % assign order to THP sensors
    if all_sensors(Sensors.THP)
        [order_value,index_order]=order_MRC_THP_sensors(order_value,index_order,flags);
    end
    
    % assign order to 107 sensors
    if all_sensors(Sensors.T107)
        [order_value,index_order]=order_sensors(order_value,index_order,flags,'107','t');
    end
        
    % assign order to 109 sensors
    if all_sensors(Sensors.T109)
        [order_value,index_order]=order_sensors(order_value,index_order,flags,'109','t');
    end
    
    % assign order to THS sensors
    if all_sensors(Sensors.THS)
        [order_value,index_order]=order_sensors(order_value,index_order,flags,'THS','t');
    end
    
    % assign order to HYP temperature sensors
    if used_sensors(SensorTypes.tempHYP)==1 &&...
       all_sensors(Sensors.HYP)==1 
        [order_value,index_order]=order_sensors(order_value,index_order,flags,'HYP','t');
    end
    
    % assign order to VWC HYP sensors
    if used_sensors(SensorTypes.VWC)==1 &&...
       all_sensors(Sensors.HYP)==1   
        [order_value,index_order]=order_sensors(order_value,index_order,flags,'HYP','w');
    end
    
    % assign order to a SnowDepth sensor (one per file)
    if used_sensors(SensorTypes.SnwD)==1 &&...
       (all_sensors(Sensors.JUDS)==1 || ...
        all_sensors(Sensors.SR50)==1 ||...
        all_sensors(Sensors.SR5A)==1)
        if all_sensors(Sensors.JUDS)==1
            snow_sensor='JUDS';
        else
            if all_sensors(Sensors.SR50)==1
                snow_sensor='SR50';
            else
                if all_sensors(Sensors.SR5A)==1
                    snow_sensor='SR5A';
                end
            end
        end      
        [order_value,index_order]=order_sensors(order_value,index_order,flags,snow_sensor,'s');
    end
    
    if used_sensors(SensorTypes.HtFx)==1 &&...
       all_sensors(Sensors.N_A)==1
        [order_value,index_order]=order_sensors(order_value,index_order,flags,'N/A','h');
    end
    
    % create a file with ordered columns
    for i=1:length(flags)
        table_sorted(:,index_order(i,Sorting.Order)) = table(:,i);
    end
    
end

