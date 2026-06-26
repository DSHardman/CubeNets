% %% FLAT
% electrodes = opad([21 15 14 13 17 18 19 20]);
% electrodes = [electrodes; adad([21 15 14 13 17 18 19 20])];
% 
% electrodes = [electrodes; opad([14 13 12 5 7 16 17 18])];
% electrodes = [electrodes; adad([14 13 12 5 7 16 17 18])];
% 
% electrodes = [electrodes; opad([12 5 1 0 2 6 7 16])];
% electrodes = [electrodes; adad([12 5 1 0 2 6 7 16])];
% 
% electrodes = [electrodes; opad([3 4 5 7 16 12 11 10])];
% electrodes = [electrodes; adad([3 4 5 7 16 12 11 10])];
% 
% electrodes = [electrodes; opad([5 7 8 9 23 22 16 12])];
% electrodes = [electrodes; adad([5 7 8 9 23 22 16 12])];

%% FOLDED
electrodes = opad([5 17 19 21 13 11 9 7]);
electrodes = [electrodes; adad([5 17 19 21 13 11 9 7])];

electrodes = [electrodes; opad([19 21 23 10 14 15 13 11])];
electrodes = [electrodes; adad([19 21 23 10 14 15 13 11])];

electrodes = [electrodes; opad([23 10 2 0 4 12 14 15])];
electrodes = [electrodes; adad([23 10 2 0 4 12 14 15])];

electrodes = [electrodes; opad([6 8 10 14 15 23 22 20])];
electrodes = [electrodes; adad([6 8 10 14 15 23 22 20])];

electrodes = [electrodes; opad([10 14 16 18 1 3 15 23])];
electrodes = [electrodes; adad([10 14 16 18 1 3 15 23])];

%% OLD
% electrodes = opad([0 1 5 12 16 7 6 2]);
% electrodes = [electrodes; adad([0 1 5 12 16 7 6 2])];
% 
% electrodes = [electrodes; opad([5 12 13 14 18 17 16 7])];
% electrodes = [electrodes; adad([5 12 13 14 18 17 16 7])];
% 
% electrodes = [electrodes; opad([9 8 7 5 12 16 22 23])];
% electrodes = [electrodes; adad([9 8 7 5 12 16 22 23])];
% 
% electrodes = [electrodes; opad([7 5 4 3 10 11 12 16])];
% electrodes = [electrodes; adad([7 5 4 3 10 11 12 16])];
% 
% electrodes = [electrodes; opad([13 14 15 21 20 19 18 17])];
% electrodes = [electrodes; adad([13 14 15 21 20 19 18 17])];

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