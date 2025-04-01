I = imread("Cube24.jpg");
load("ElectrodeOrder24.mat");
load("Cube24Locations.mat");
load("Data/Extracted24.mat");

for i = 1:360
    subplot(2,1,1);
    imshow(I);
    hold on
    scatter(pointlocs(electrodes(i, 1:2),1), pointlocs(electrodes(i, 1:2),2), 50, 'r', 'filled');
    scatter(pointlocs(electrodes(i, 3:4),1), pointlocs(electrodes(i, 3:4),2), 50, 'b', 'filled');

    subplot(2,1,2);
    % scatter(responseobject.positions(:,1), -responseobject.positions(:,2), 30, responseobject.responses(:, i), 'filled');
    scatter(-responseobject.positions(:,1), responseobject.positions(:,2), 30, responseobject.responses(:, i), 'filled');

    sgtitle(string(i));

    pause();
    clf
end