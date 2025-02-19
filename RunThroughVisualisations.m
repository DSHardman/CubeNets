I = imread("Cube6.png");
load("Cube6Locations.mat");

for i = 1:360
    imshow("Cube6.png");
    hold on
    scatter(pointlocs(electrodes(i, 1:2),1), pointlocs(electrodes(i, 1:2),2), 50, 'r', 'filled');
    scatter(pointlocs(electrodes(i, 3:4),1), pointlocs(electrodes(i, 3:4),2), 50, 'b', 'filled');
    title(string(i));
    pause();
    clf
end