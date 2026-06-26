%% Load in data
% load("Data/Old/Extracted24.mat");
load("Data/AmodoRandoms/AmodoExtracted.mat");

responses = responseobject.responses;
targetpositions = responseobject.positions;

%% Perform F-Test ranking
ranking = franking(responses, targetpositions);

%% WAM localization: plot 10 random predictions from test set
% At the moment, these are the bad predictions
% Prediction in pink, ground truth in red
figure();
error = median(wamtesting(1:360, responses, targetpositions, 1))
sgtitle("Median error over entire test set: "+ string(error) + " mm");
% Note that naive mean prediction would be 29.8537 mm

% figure();
% rollingerror = zeros([359, 10]);
% for i = 2:360
%     i
%     for j = 1:10
%     rollingerror(i-1, j) = median(wamtesting(ranking(1:i), responses, targetpositions, 0));
%     end
% end
% plot(mean(rollingerror.'));
% return

figure();
errors = zeros([size(targetpositions, 1), 1]);
for i = 1:size(targetpositions, 1)
    if rem(i, 100) == 0
        i
    end
    errors(i) = median(wamtesting(1:360, responses, targetpositions, 0, find(1:size(targetpositions, 1)~=i), i));
end
% scatter(targetpositions(:, 1), targetpositions(:, 2), 30, errors, 'filled');
interpolatedcube(targetpositions(:, 1), targetpositions(:, 2), errors); colormap hot
% caxis([0 20])

% Median error per face
clear faceerrors
faceerrors{6} = [];
for i = 1:length(errors)
    face = returnfaces(targetpositions(i, :));
    faceerrors{face} = [faceerrors{face}; errors(i)];
end
medianfaces = zeros([6, 1]);

figure();
barcols = 1/255*[233 101 0; 0 181 0; 233 14 85; 0 181 214; 233 195 85; 233 104 85];
for i = 1:6
    medianfaces(i) = median(faceerrors{i});
    bar(i, medianfaces(i), 'facecolor', barcols(i, :), 'LineWidth', 2);
    hold on
end

box off
set(gca, 'LineWidth', 2, 'FontSize', 15);
set(gcf, 'color', 'w', 'position', [375 355 691 288]);
ylabel("Median Error (mm)");
xlabel("Face");

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
function allerrors = wamtesting(combinations, responses, targetpositions, figs, traininds, testinds)
        
    % responses = tanh(normalize(responses)); % Deal with outliers
     
    % responses = normalize(responses);

    % Updated normalisation June26
    responses = tanh(responses);
    responses = normalize(responses.').'; 

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
    % error = 0;
    allerrors = [];

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

        % % Prediction is the brightest pixel
        [~, ind] = sort(sum, 'descend');
        prediction = targetpositions(ind(1),:);

        % % Prediction is the brightest pixel on the same face
        % face = returnfaces(testpositions(i, :));
        % [~, ind] = sort(sum, 'descend');
        % for j = 1:size(targetpositions, 1)
        %     if returnfaces(targetpositions(ind(j), :)) == face
        %         break
        %     end
        % end
        % prediction = targetpositions(ind(j), :);

        % n = min(6, size(responses, 2));
        % prediction = [mean(targetpositions(ind(1:n), 1)),...
        %                 mean(targetpositions(ind(1:n), 2))];

        % Add localization error to running sum 
        % error = error + rssq(prediction-testpositions(i,:));
        allerrors = [allerrors; rssq(prediction-testpositions(i,:))];

        % Plot first 10 predictions
        if figs && i <= 10
        % if figs && rssq(prediction-testpositions(i,:)) > 20 && plotted < 10
            plotted = plotted + 1;
            subplot(2,5,plotted);

            % scatter(targetpositions(:,1), targetpositions(:,2), 30, sum>(mean(sum)+1.5*std(sum)), 'filled');
            % scatter(targetpositions(:,1), targetpositions(:,2), 30, sum, 'filled');
            interpolatedcube(targetpositions(:,1), targetpositions(:,2), sum);
            colorbar off

            hold on
            % Add ground truth and predicted touch locations
            scatter(testpositions(i, 1), testpositions(i, 2), 50, 'r', 'filled');
            scatter(prediction(1), prediction(2), 50, 'm', 'filled');
            axis off
            set(gcf, 'color', 'w');
        end
    end
    % error = error/size(testresponses, 1); % calculate mean

end

function faces = returnfaces(positions)
    faces = zeros([size(positions, 1), 1]);
    for i = 1:size(positions, 1)
        if positions(i, 1) < 30
            faces(i) = 1;
        elseif positions(i, 1) > 90
            faces(i) = 6;
        elseif positions(i, 1) >= 60
            faces(i) = 5;
        elseif positions(i, 2) > 30
            faces(i) = 2;
        elseif positions(i, 2) < 0
            faces(i) = 4;
        else
            faces(i) = 3;
        end
    end
end