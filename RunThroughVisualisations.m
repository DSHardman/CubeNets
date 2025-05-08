n_elec = 6;

I = imread("Cube"+string(n_elec)+".jpg");
load("ElectrodeOrder"+string(n_elec)+".mat");
load("Cube"+string(n_elec)+"Locations.mat");
load("Data/Extracted"+string(n_elec)+".mat");

for i = 1:360
    subplot(2,1,1);
    imshow(I);
    hold on
    scatter(pointlocs(electrodes(i, 1:2),1), pointlocs(electrodes(i, 1:2),2), 50, 'r', 'filled'); % Inject red
    scatter(pointlocs(electrodes(i, 3:4),1), pointlocs(electrodes(i, 3:4),2), 50, 'b', 'filled'); % Measure blue

    subplot(2,1,2);
    if n_elec == 6
        scatter(responseobject.positions(:,1), -responseobject.positions(:,2), 30, responseobject.responses(:, i), 'filled');
    elseif n_elec == 24
        scatter(-responseobject.positions(:,1), responseobject.positions(:,2), 30, responseobject.responses(:, i), 'filled');
    end

    set(gcf, 'color', 'w', 'position', [1147 290 270 420]);
    sgtitle(string(i));

    pause();
    clf
end