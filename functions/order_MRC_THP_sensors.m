function [order_value,indices_order] = order_MRC_THP_sensors(order_value,indices_order,flags)
%This function assigns order to MRC/THP sensors. It uses the fact that
%MRC/THP sensors are always grouped and sorted based on the depth
%(from smaller to larger depths). Each table can have either MRC or THP
%sensors, but not both.

    global length_dim;
    flags_dim=size(flags);

    for i=1:flags_dim(length_dim)
        if (strcmp(flags(i,Flags.Sensor),'MRC') || strcmp(flags(i,Flags.Sensor),'THP')) &&...
           ~(strcmp(flags(i,Flags.OriginalDepth),'a') || strcmp(flags(i,Flags.OriginalDepth),'s'))
              indices_order(i,Sorting.Order)=order_value;
              order_value=order_value+1;
        end
    end

end

