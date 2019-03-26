function [order_value,indices_order] = ...
    order_air_surf_sensors(order_value,indices_order,index_flags_a,index_flags_s)
%This function orders air and surface temperature sensors.
%It assumes that each table has no more than two sensors of each type
%The logic (cases) used in this function can be found in "Order" GoogleSheet
%
%Input:
%indices_order - a matrix containing indices corresponding to rows in the
%flags file and order in which these rows should go
%order_value - current value of the order
%index_flags_a - rows containing air temp data in the flags file
%index_flags_s - rows containing surf temp data in the flags file

    if isempty(index_flags_a) && isempty(index_flags_s) % case 1
        % do nothing
    else
        if isempty(index_flags_a) && length(index_flags_s)==1 % case 2
            indices_order(index_flags_s,Sorting.Order)=order_value;
            order_value=order_value+1;
        else
            if isempty(index_flags_a) && length(index_flags_s)==2 % case 3
                indices_order(index_flags_s(1),Sorting.Order)=order_value;
                order_value=order_value+1;
                indices_order(index_flags_s(2),Sorting.Order)=order_value;
                order_value=order_value+1;
            else
                if length(index_flags_a)==1 && isempty(index_flags_s) % case 4
                    indices_order(index_flags_a,Sorting.Order)=order_value;
                    order_value=order_value+1;
                else
                    if length(index_flags_a)==1 && length(index_flags_s)==1 % case 5
                        indices_order(index_flags_a,Sorting.Order)=order_value;
                        order_value=order_value+1;
                        indices_order(index_flags_s,Sorting.Order)=order_value;
                        order_value=order_value+1;
                    else
                        if length(index_flags_a)==1 && length(index_flags_s)==2 % case 6
                            indices_order(index_flags_a,Sorting.Order)=order_value;
                            order_value=order_value+1;
                            indices_order(index_flags_s(1),Sorting.Order)=order_value;
                            order_value=order_value+1;
                            indices_order(index_flags_s(2),Sorting.Order)=order_value;
                            order_value=order_value+1;
                        else
                            if length(index_flags_a)==2 && isempty(index_flags_s) % case 7
                                indices_order(index_flags_a(1),Sorting.Order)=order_value;
                                order_value=order_value+1;
                                indices_order(index_flags_a(2),Sorting.Order)=order_value;
                                order_value=order_value+1;
                            else
                                if length(index_flags_a)==2 && length(index_flags_s)==1 % case 8
                                    indices_order(index_flags_a(1),Sorting.Order)=order_value;
                                    order_value=order_value+1;
                                    indices_order(index_flags_a(2),Sorting.Order)=order_value;
                                    order_value=order_value+1;
                                    indices_order(index_flags_s,Sorting.Order)=order_value;
                                    order_value=order_value+1;
                                else
                                    if length(index_flags_a)==2 && length(index_flags_s)==2 % case 9
                                        indices_order(index_flags_a(1),Sorting.Order)=order_value;
                                        order_value=order_value+1;
                                        indices_order(index_flags_a(2),Sorting.Order)=order_value;
                                        order_value=order_value+1;
                                        indices_order(index_flags_s(1),Sorting.Order)=order_value;
                                        order_value=order_value+1;
                                        indices_order(index_flags_s(2),Sorting.Order)=order_value;
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

