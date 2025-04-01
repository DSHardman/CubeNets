electrodes = opad([0 1 5 12 16 7 6 2]);
electrodes = [electrodes; adad([0 1 5 12 16 7 6 2])];

electrodes = [electrodes; opad([5 12 13 14 18 17 16 7])];
electrodes = [electrodes; adad([5 12 13 14 18 17 16 7])];

electrodes = [electrodes; opad([9 8 7 5 12 16 22 23])];
electrodes = [electrodes; adad([9 8 7 5 12 16 22 23])];

electrodes = [electrodes; opad([7 5 4 3 10 11 12 16])];
electrodes = [electrodes; adad([7 5 4 3 10 11 12 16])];

electrodes = [electrodes; opad([13 14 15 21 20 19 18 17])];
electrodes = [electrodes; adad([13 14 15 21 20 19 18 17])];

function electrodes = opad(numbers)
    numbers = numbers + 1;
    electrodes = [];
    for i = 1:8
        for j = 1:8
            if j ~= i && j ~= mod(i+3, 8)+1 && mod(j, 8)+1 ~= i && mod(j, 8)+1 ~= mod(i+3, 8)+1
                electrodes = [electrodes; numbers(i) numbers(mod(i+3, 8)+1) numbers(j) numbers(mod(j, 8)+1)];
            end
        end
    end
end


function electrodes = adad(numbers)
    numbers = numbers + 1;
    electrodes = [];
    for i = 1:8
        for j = 1:8
            if j ~= i && j ~= mod(i, 8)+1 && mod(j, 8)+1 ~= i && mod(j, 8)+1 ~= mod(i, 8)+1
                electrodes = [electrodes; numbers(i) numbers(mod(i, 8)+1) numbers(j) numbers(mod(j, 8)+1)];
            end
        end
    end
end