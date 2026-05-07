%% Part 1: measurement ratios
y = [17.6 14.9 0.5; 13.3 14.9 0.14];
bar(categorical({'A', 'B'}), y,'stacked');
colororder("sail")
set(gca, "linewidth", 2, "Fontsize", 15);
box off
set(gcf, 'color', 'w', 'position', [700 165 422 620]);
ylabel("Resistance (k\Omega)");
legend({"X_1 Discrete"; "X_2 Discrete"; "Continuum"});
legend boxoff

return

%% Part 2: spatial distribution

circles = [1, 0, 0.14;
    0 1 0.17;
    1 1 0.19;
    0 2 0.25;
    1 2 0.25;
    0 3 0.3;
    1 3 0.29;
    -2 4 0.52;
    -1 4 0.42;
    0 4 0.37;
    1 4 0.35;
    2 4 0.40;
    3 4 0.46;
    -2 5 0.53;
    -1 5 0.45;
    0 5 0.41;
    1 5 0.41;
    2 5 0.41;
    3 5 0.48;
    0 6 0.47;
    1 6 0.47;
    0 7 0.51;
    1 7 0.50];

scatter(circles(:, 1), circles(:,2), 500*circles(:,3), 'k', 'filled');
hold on
scatter(0, 0, 100, 'kx', 'linewidth', 2);

for i = 1:size(circles, 1)
    text(circles(i, 1), circles(i, 2)-0.35, string(circles(i,3)),...
        "HorizontalAlignment", "center", "Color", "k");
end

axis equal
axis off
set(gcf, 'color', 'w', 'position', [325 138 868 719]);

plot(polyshape([-0.5 1.5 1.5 3.5 3.5 1.5 1.5 -0.5 -0.5 -2.5 -2.5 -0.5 -0.5],...
    [-0.5 -0.5 3.5 3.5 5.5 5.5 7.5 7.5 5.5 5.5, 3.5 3.5 -0.5]), 'facecolor', 'none');

%% Part 3: spatial distribution with ribbons

circles = [1, 0, 28;
    0 1 30;
    1 1 26;
    0 2 32;
    1 2 28;
    0 3 34;
    1 3 30;
    -2 4 38;
    -1 4 39;
    0 4 35;
    1 4 35;
    2 4 26;
    3 4 24;
    -2 5 34;
    -1 5 31;
    0 5 29;
    1 5 27;
    2 5 25;
    3 5 23;
    0 6 30;
    1 6 28;
    0 7 30;
    1 7 32];

scatter(circles(:, 1), circles(:,2), 10*circles(:,3), 'k', 'filled');
hold on
scatter(0, 0, 100, 'kx', 'linewidth', 2);

for i = 1:size(circles, 1)
    text(circles(i, 1), circles(i, 2), string(circles(i,3)),...
        "HorizontalAlignment", "center", "Color", "red");
end

axis equal
axis off
set(gcf, 'color', 'w');

plot(polyshape([-0.5 1.5 1.5 3.5 3.5 1.5 1.5 -0.5 -0.5 -2.5 -2.5 -0.5 -0.5],...
    [-0.5 -0.5 3.5 3.5 5.5 5.5 7.5 7.5 5.5 5.5, 3.5 3.5 -0.5]), 'facecolor', 'none');