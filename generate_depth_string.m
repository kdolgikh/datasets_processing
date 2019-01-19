function [string] = generate_depth_string(depth)

    % This function uses the fact that number of digits after decimal point
    % will always be less than or equal to 2, when using data exported from
    % VDV or OnsetDB

    string=num2str(depth);
    string_length=numel(string);

    if string(1)=='-'
        
        
    else
        num_digits_before_dp_reqd = 3;
        num_digits_after_dp_reqd = 2;

        %find decimal point position
        decimal_point_pos = 0;
        for i=1:string_length
            if string(i) == '.'
                decimal_point_pos = i;
                break;
            end
        end

        % determine the number of digits before decimal point
        if decimal_point_pos == 0
            num_digits_before_dp = string_length;
        else
            num_digits_before_dp = decimal_point_pos - 1;
        end

        % add 0s before decimal point if required
        if num_digits_before_dp < num_digits_before_dp_reqd
            num_positions_to_add = num_digits_before_dp_reqd - num_digits_before_dp;
            for i=1:num_positions_to_add
               string = strcat('0',string); 
            end
        end

        if decimal_point_pos == 0
            string = strcat(string,'.00');
        end
        
        string = strcat('+',string);   
    end
    
end

