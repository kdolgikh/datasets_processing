function [string] = generate_depth_string(depth)

    % This function uses the fact that number of digits after decimal point
    % will always be less than or equal to 2, when using data exported from
    % VDV or OnsetDB

    num_digits_before_dp_reqd = 3;
    num_digits_after_dp_reqd = 2;
    
    string=num2str(depth);

    % add missing '+'
    if(string(1)~='-')
        string = strcat('+',string);
    end
    
    string_length=numel(string);
    
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
        num_digits_before_dp = string_length-1;
        num_digits_after_dp = num_digits_after_dp_reqd;
        string = strcat(string,'.00');
    else
        num_digits_before_dp = decimal_point_pos - 2;
        num_digits_after_dp = string_length - decimal_point_pos;
    end

    % add 0s before decimal point, if required
    if num_digits_before_dp < num_digits_before_dp_reqd
        while (num_digits_before_dp < num_digits_before_dp_reqd)
           string = strcat(string(1),'0',string(2:end)); % leading '-' or '+' stays in place
           num_digits_before_dp = num_digits_before_dp +1;
        end
    end

    % add or remove 0s after decimal point, if required
    if num_digits_after_dp < num_digits_after_dp_reqd
        while num_digits_after_dp < num_digits_after_dp_reqd
           string = strcat(string,'0');
           num_digits_after_dp = num_digits_after_dp +1;
        end
    else
        if num_digits_after_dp > num_digits_after_dp_reqd
            while num_digits_after_dp > num_digits_after_dp_reqd
               string=string(1:(end-1));
               num_digits_after_dp = num_digits_after_dp -1;
            end   
        end
    end
   
end

