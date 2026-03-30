%% Load in data
% load("Data/Old/Extracted24.mat");
load("Data/AmodoRandoms/AmodoExtracted.mat");

responses = responseobject.responses;
targetpositions = responseobject.positions;

%% Perform F-Test ranking
ranking = franking(responses, targetpositions);

%% WAM localization using top 100 channels: plot 10 random predictions from test set
% At the moment, these are the bad predictions
% Prediction in pink, ground truth in red
figure();
error = wamtesting(ranking, responses, targetpositions, 1)
% sgtitle("Mean error over entire test set: "+ string(error) + " mm");
% Note that naive prediction would be 29.8537 mm

figure();
errors = zeros([size(targetpositions, 1), 1]);
for i = 1:size(targetpositions, 1)
    if rem(i, 100) == 0
        i
    end
    errors(i) = wamtesting(1:360, responses, targetpositions, 0, find(1:size(targetpositions, 1)~=i), i);
end
scatter(targetpositions(:, 1), targetpositions(:, 2), 30, errors, 'filled');
caxis([0 20])

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


%% Implement WAM method from Hardman et al., Tactile Perception in Hydrogel-based Robotic Skins, 2023
function error = wamtesting(combinations, responses, targetpositions, figs, traininds, testinds)
        
    responses = tanh(normalize(responses)); % Deal with outliers

    % Generate test & train sets
    if nargin == 4
        P = randperm(length(targetpositions));
        traininds = P(1:floor(0.9*length(targetpositions)));
        testinds = P(ceil(0.9*length(targetpositions)):end);
    end
    testresponses = responses(testinds, :);
    testpositions = targetpositions(testinds, :);
    responses = responses(traininds, :);
    targetpositions = targetpositions(traininds, :);

    % WAM using training set to predict test set
    error = 0;
    % Loop through test set

    plotted = 0;
    for i = 1:size(testresponses, 1)

        % Sum activation maps
        sum = zeros([size(responses, 1), 1]);
        for j = 1:length(combinations)
            newsum = testresponses(i, combinations(j))*responses(:, combinations(j));
            if isempty(find(isnan(newsum), 1))
                sum = sum + newsum;
            end
        end

        % Prediction is the average location of the n brightest pixels
        [~, ind] = sort(sum, 'descend');
        prediction = [targetpositions(ind(1),1),...
                        targetpositions(ind(1),2)];

        % n = min(6, size(responses, 2));
        % prediction = [mean(targetpositions(ind(1:n), 1)),...
        %                 mean(targetpositions(ind(1:n), 2))];

        % Add localization error to running sum 
        error = error + rssq(prediction-testpositions(i,:));

        % Plot worst predictions
        % if figs && i <= 10
        if figs && rssq(prediction-testpositions(i,:)) > 20 && plotted < 10
            plotted = plotted + 1;
            subplot(2,5,plotted);

            scatter(targetpositions(:,1), targetpositions(:,2), 30, sum>(mean(sum)+1.5*std(sum)), 'filled');
            % scatter(targetpositions(:,1), targetpositions(:,2), 30, sum, 'filled');

            hold on
            % Add ground truth and predicted touch locations
            scatter(testpositions(i, 1), testpositions(i, 2), 50, 'r', 'filled');
            scatter(prediction(1), prediction(2), 50, 'm', 'filled');
            axis off
            set(gcf, 'color', 'w');
        end
    end
    error = error/size(testresponses, 1); % calculate mean
end