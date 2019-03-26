function [order_value,indices_order]=...
    order_107_109_THS_HYP_sensors(order_value,indices_order,flags,sensor_type)
%This function orders rows containing data from 107/109, THS, and HYP
%sensors. It uses depths of these sensor to sort them. Depths are used
%because in some cases sensors do not go in correct order (e.g. in Bonanza
%Creek 2 (burned)). Also, incorrect order wrt depths can occur due to
%sensors' variable names.

    sensor_index=[];
    sensor_depth=[];
    for i=1:length(flags)
        if strcmp(flags(i,Flags.Sensor),sensor_type) &&...
           ~(strcmp(flags(i,Flags.OriginalDepth),'a') || strcmp(flags(i,Flags.OriginalDepth),'s')) &&...
           strcmp(flags(i,Flags.Type),'t')
            sensor_index_next=i;
            sensor_depth_next=str2double(flags(i,Flags.OriginalDepth));
            sensor_index=[sensor_index, sensor_index_next];
            sensor_depth=[sensor_depth, sensor_depth_next];
        end
    end
    
    [~,sorted_depth_index] = sort(sensor_depth);
    
    for i=1:length(sensor_index)
        indices_order(sensor_index(sorted_depth_index(i)),Sorting.Order)=...
            order_value;
        order_value=order_value+1;
    end
    
end

