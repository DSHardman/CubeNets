%% Load in and process WAMs data

load("Data/AmodoRandoms/AmodoExtracted.mat");

responses = responseobject.responses;
targetpositions = responseobject.positions;
combinations = franking(responses, targetpositions);
responses = tanh(normalize(responses)); % Deal with outliers
% Generate test & train sets
traininds = randperm(length(targetpositions));
responses = responses(traininds, :);
targetpositions = targetpositions(traininds, :);


%% Connect to board and set baseline

clear device
device = serialport("COM11",9600);
device.Timeout = 25;

flush(device); readline(device);
fprintf("Collecting baseline...\n");
baseline = zeros([1 360]);
for i = 1:5
    temp = split(readline(device), ",");
    for j = 1:360
        if contains(char(temp(j)), 'C')
            fprintf("Baseline Clipped\n");
            unclipped = char(temp(j));
            unclipped = unclipped(1:end-1);
            baseline(j) = baseline(j) + str2num(unclipped);
        else
            baseline(j) = baseline(j) + str2num(temp(j));
        end
    end
end
baseline = baseline./i;
fprintf("Baseline collected.\n");


baselineframes = [baseline; baseline; baseline; baseline; baseline];

n = 300;
for i = 1:n
    i
    temp = split(readline(device),",");
    for j = 1:360
        if contains(char(temp(j)), 'C')
            fprintf("Clipped\n");
            unclipped = char(temp(j));
            unclipped = unclipped(1:end-1);
            data(j) = str2num(unclipped);
        else
            data(j) = str2num(temp(j));
        end
    end

    baseline = mean(baselineframes);
    datab = data - baseline;
    baselineframes = [baselineframes(2:5, :); data];

    % Realtime WAMs prediction
    sum = zeros([size(responses, 1), 1]);
    for j = 1:length(combinations)
        newsum = datab(combinations(j))*responses(:, combinations(j));
        if isempty(find(isnan(newsum), 1))
            sum = sum + newsum;
        end
    end

    % Prediction is the average location of the n brightest pixels
    [~, ind] = sort(sum, 'descend');
    prediction = targetpositions(ind(1), :);

    % n = min(6, size(responses, 2));
    % prediction = [mean(targetpositions(ind(1:n), 1)),...
    %                 mean(targetpositions(ind(1:n), 2))];

    % Plot prediction
    scatter(targetpositions(:,1), targetpositions(:,2), 150, sum, 'filled');
    sum = max(sum, 0);
    % clim([0 max(0.03, max(sum))]);
    colorbar
    title(string(i));

    hold on
    if mean(sum) > 1e-3
        scatter(prediction(1), prediction(2), 200, 'm', 'filled');
    end
    axis off
    set(gca, 'XDir', 'reverse', 'YDir', 'reverse');
    set(gcf, 'color', 'w');
    hold off
    drawnow();
end


%% F-Test Ranking
function ranking = franking(responses, targetpositions)
    combs2_x= fsrftest(responses, targetpositions(:, 1)); % x direction
    combs2_y= fsrftest(responses, targetpositions(:, 2)); % y direction

    % Combine directions
    combinedweights = zeros(size(combs2_x));
    for i = 1:size(responses, 2)
        combinedweights(i) = find(combs2_x==i)+find(combs2_y==i);
    end
    [~, ranking] = sort(combinedweights, "ascend");
end
