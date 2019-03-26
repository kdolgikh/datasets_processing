function reorder_columns(flags,filename)
%This function reorders columns in the table according to the provided
%order.
%Air temperature always goes first, followed by surface temperature
%regardless of the sensor type.

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
    
    % determine row indices for air  and surf temperature(s) measurements
    ind_flgs_a=find_air_surf_temp(flags,'a',filename);
    ind_flgs_s=find_air_surf_temp(flags,'s',filename);
    
    % assign order to air and surf measurements
    % see "Order" Google Sheet
    if isempty(ind_flgs_a) && isempty(ind_flgs_s) % case 1
        % do nothing
    else
        if isempty(ind_flgs_a) && length(ind_flgs_s)==1 % case 2
            index_order(ind_flgs_s,Sorting.Order)=order_value;
            order_value=order_value+1;
        else
            if isempty(ind_flgs_a) && length(ind_flgs_s)==2 % case 3
                index_order(ind_flgs_s(1),Sorting.Order)=order_value;
                order_value=order_value+1;
                index_order(ind_flgs_s(2),Sorting.Order)=order_value;
                order_value=order_value+1;
            else
                if length(ind_flgs_a)==1 && isempty(ind_flgs_s) % case 4
                    index_order(ind_flgs_a,Sorting.Order)=order_value;
                    order_value=order_value+1;
                else
                    if length(ind_flgs_a)==1 && length(ind_flgs_s)==1 % case 5
                        index_order(ind_flgs_a,Sorting.Order)=order_value;
                        order_value=order_value+1;
                        index_order(ind_flgs_s,Sorting.Order)=order_value;
                        order_value=order_value+1;
                    else
                        if length(ind_flgs_a)==1 && length(ind_flgs_s)==2 % case 6
                            index_order(ind_flgs_a,Sorting.Order)=order_value;
                            order_value=order_value+1;
                            index_order(ind_flgs_s(1),Sorting.Order)=order_value;
                            order_value=order_value+1;
                            index_order(ind_flgs_s(2),Sorting.Order)=order_value;
                            order_value=order_value+1;
                        else
                            if length(ind_flgs_a)==2 && isempty(ind_flgs_s) % case 7
                                index_order(ind_flgs_a(1),Sorting.Order)=order_value;
                                order_value=order_value+1;
                                index_order(ind_flgs_a(2),Sorting.Order)=order_value;
                                order_value=order_value+1;
                            else
                                if length(ind_flgs_a)==2 && length(ind_flgs_s)==1 % case 8
                                    index_order(ind_flgs_a(1),Sorting.Order)=order_value;
                                    order_value=order_value+1;
                                    index_order(ind_flgs_a(2),Sorting.Order)=order_value;
                                    order_value=order_value+1;
                                    index_order(ind_flgs_s,Sorting.Order)=order_value;
                                    order_value=order_value+1;
                                else
                                    if length(ind_flgs_a)==2 && length(ind_flgs_s)==2 % case 9
                                        index_order(ind_flgs_a(1),Sorting.Order)=order_value;
                                        order_value=order_value+1;
                                        index_order(ind_flgs_a(2),Sorting.Order)=order_value;
                                        order_value=order_value+1;
                                        index_order(ind_flgs_s(1),Sorting.Order)=order_value;
                                        order_value=order_value+1;
                                        index_order(ind_flgs_s(2),Sorting.Order)=order_value;
                                        order_value=order_value+1;
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

