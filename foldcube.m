function foldcube(responseobject, response, visiblesides)
    
    clear sides
    for i = 1:6
        sides(i) = SkinResponse([], NaN, []);
    end

    % Sort into cube sides
    for i = 1:length(responseobject.positions(:, 1))
        if responseobject.positions(i, 1) < 30
            % SIDE 1
            sides(1).positions = [sides(1).positions; responseobject.positions(i, :)];
            sides(1).responses = [sides(1).responses; responseobject.responses(i, :)];
        elseif responseobject.positions(i, 1) > 60 && responseobject.positions(i, 1) < 90
            % SIDE 3
            sides(3).positions = [sides(3).positions; responseobject.positions(i, :)];
            sides(3).responses = [sides(3).responses; responseobject.responses(i, :)];
        elseif responseobject.positions(i, 1) > 90
            % SIDE 4
            sides(4).positions = [sides(4).positions; responseobject.positions(i, :)];
            sides(4).responses = [sides(4).responses; responseobject.responses(i, :)];
        elseif responseobject.positions(i, 2) > 30
            % SIDE 5
            sides(5).positions = [sides(5).positions; responseobject.positions(i, :)];
            sides(5).responses = [sides(5).responses; responseobject.responses(i, :)];
        elseif responseobject.positions(i, 2) < 0
            % SIDE 6
            sides(6).positions = [sides(6).positions; responseobject.positions(i, :)];
            sides(6).responses = [sides(6).responses; responseobject.responses(i, :)];
        else
            % SIDE 2
            sides(2).positions = [sides(2).positions; responseobject.positions(i, :)];
            sides(2).responses = [sides(2).responses; responseobject.responses(i, :)];
        end
    end

    plot3(nan, nan, nan);
    hold on

    if visiblesides(1)
        scatter3(zeros(size(sides(1).positions(:,1))), sides(1).positions(:,2)./30, sides(1).positions(:,1)./30, 80, sides(1).responses(:, response), 'filled');
    end

    if visiblesides(2)
        scatter3((sides(2).positions(:,1)-30)./30, sides(2).positions(:,2)./30, ones(size(sides(2).positions(:,1))), 80, sides(2).responses(:, response), 'filled');
    end

    if visiblesides(3)
        scatter3(ones(size(sides(3).positions(:,1))), sides(3).positions(:,2)./30, (90-sides(3).positions(:,1))./30, 80, sides(3).responses(:, response), 'filled');
    end

    if visiblesides(4)
        scatter3((120-sides(4).positions(:,1))./30, sides(4).positions(:,2)./30, zeros(size(sides(4).positions(:,1))), 80, sides(4).responses(:, response), 'filled');
    end

    if visiblesides(5)
        scatter3((sides(5).positions(:,1)-30)./30, ones(size(sides(5).positions(:,1))), (60-sides(5).positions(:,2))./30, 80, sides(5).responses(:, response), 'filled');
    end

    if visiblesides(6)
        scatter3((sides(6).positions(:,1)-30)./30, zeros(size(sides(6).positions(:,1))), (sides(6).positions(:,2)+30)./30, 80, sides(6).responses(:, response), 'filled');
    end

    line([0 0], [0 0], [0 1], 'Color', 'k');
    line([0 0], [0 1], [0 0], 'Color', 'k');
    line([0 1], [0 0], [0 0], 'Color', 'k');
    line([0 0], [0 1], [1 1], 'Color', 'k');
    line([0 1], [0 0], [1 1], 'Color', 'k');
    line([1 1], [1 0], [0 0], 'Color', 'k');
    line([1 1], [1 1], [0 1], 'Color', 'k');
    line([1 0], [1 1], [0 0], 'Color', 'k');
    line([1 1], [0 1], [1 1], 'Color', 'k');
    line([1 1], [0 0], [1 0], 'Color', 'k');
    line([0 1], [1 1], [1 1], 'Color', 'k');
    line([0 0], [1 1], [1 0], 'Color', 'k');

    axis equal
    axis off
    set(gcf, 'color', 'w')
    view(3)
end