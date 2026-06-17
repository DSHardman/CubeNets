function plotWAMScube(datab)

    load("Data/AmodoRandoms/AmodoExtracted.mat");
    responses = responseobject.responses;
    targetpositions = responseobject.positions;
    responses = tanh(normalize(responses)); % Deal with outliers
    % Generate test & train sets
    traininds = randperm(length(targetpositions));
    responses = responses(traininds, :);
    targetpositions = targetpositions(traininds, :);
    
    combinations = 1:360;
    
    sum = zeros([size(responses, 1), 1]);
    for j = 1:length(combinations)
        newsum = datab(combinations(j))*responses(:, combinations(j));
        if isempty(find(isnan(newsum), 1))
            sum = sum + newsum;
        end
    end
    
    % Prediction is brightest pixel
    [~, ind] = sort(sum, 'descend');
    prediction = targetpositions(ind(1), :);
    
    % Plot prediction
    scatter(targetpositions(:,1), targetpositions(:,2), 150, sum, 'filled');
    sum = max(sum, 0);
    % clim([0 max(0.03, max(sum))]);
    colorbar
    
    hold on
    scatter(prediction(1), prediction(2), 200, 'm', 'filled');
    axis off
    set(gca, 'XDir', 'reverse', 'YDir', 'reverse');
    set(gcf, 'color', 'w');
    hold off
    drawnow();

end