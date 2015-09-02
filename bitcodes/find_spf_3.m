function isThere = find_spf_3(str)
    parts = strsplit(str, '_');
    if numel(parts) > 3
        third = parts{3};
        fourth = parts{4};
        if strcmp(third, 'Sf') && strcmp(fourth, '3')
                       
            isThere = 1;
        else
            isThere = 0;
        end
    else
        isThere = 0;
    end
end