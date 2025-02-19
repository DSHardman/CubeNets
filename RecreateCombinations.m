electrodes = zeros([360, 4]);

n = 1;
for i = 1:6
    for j = 1:6
        if j ~= i
            for k = 1:6
                if k ~= i && k ~= j
                    for l = 1:6
                        if l ~= i && l ~= j && l ~= k
                            electrodes(n, :) = [i j k l];
                            n = n + 1;
                        end
                    end
                end
            end
        end
    end
end