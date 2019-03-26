function reorder_columns(flags,filename)
%This function reorders columns, containing data from specific sensors.
%Ordering uses an order_value, which increases by 1 after each assignment.
%This value is passed to several functions, which find sensors of the
%specific type in the flags file. Therefore, the columns order is defined
%by the order in which these functions go.

    % value of the order, which increases by 1 after each assignment
    order_value=1;

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
    
    % assign order to MRC/THP sensors. Each file can have either MRC or THP
    % sensor, but not both.
    [order_value,index_order]=order_MRC_THP_sensors(order_value,index_order,flags);
    
    %assign order to 107 sensors
    [order_value,index_order]=order_107_109_THS_HYP_sensors(order_value,index_order,flags,'107');
    
    %assign order to 109 sensors
    [order_value,index_order]=order_107_109_THS_HYP_sensors(order_value,index_order,flags,'109');
    
    %assign order to THS sensors
    [order_value,index_order]=order_107_109_THS_HYP_sensors(order_value,index_order,flags,'THS');
    
    %assign order to HYP temperature sensors
    [order_value,index_order]=order_107_109_THS_HYP_sensors(order_value,index_order,flags,'HYP');

end

