%% Load in and process WAMs data

load("Data/Extracted24.mat");
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
device = serialport("COM17",115200);
device.Timeout = 25;

for i=1:500
    data = readline(device);
    baseline = str2num(data);
    if length(baseline) == 360
        break
    end
    i
end

baselineframes = [baseline; baseline; baseline; baseline; baseline];

n = 300;
for i = 1:n
    i
    data = readline(device);
    if ~isempty(data)
        data = str2num(data);
    end
    % plot(data);

    % baseline = mean(baselineframes);
    datab = data - baseline;
    % baselineframes = [baselineframes(2:5, :); data];

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
    n = min(6, size(responses, 2));
    prediction = [mean(targetpositions(ind(1:n), 1)),...
                    mean(targetpositions(ind(1:n), 2))];

    % Plot prediction
    scatter(targetpositions(:,1), targetpositions(:,2), 150, sum, 'filled');
    clim([-0.5 0.5]);
    title(string(i));

    hold on
    if mean(sum) > 0.015
        % scatter(prediction(1), prediction(2), 200, 'm', 'filled');
    end
    axis off
    set(gcf, 'color', 'w');
    hold off
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
