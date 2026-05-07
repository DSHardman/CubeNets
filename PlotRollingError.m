load("Data/RollingError.mat");

% plot(2:360, mean(rollingerror.'));
% hold on
% plot(2:360, mean(rollingerror.')+std(rollingerror.'));
% plot(2:360, mean(rollingerror.')-std(rollingerror.'));

avg_data = mean(rollingerror,2,'omitnan').';
std_data = std(rollingerror,0,2,'omitnan').';
x = 2:360;

fill([x, flip(x)], [avg_data+std_data, flip(avg_data-std_data)], [0.6 0.6 0.6], 'EdgeColor','none')
hold on
plot(x, smooth(avg_data), 'k', 'linewidth', 2);
plot([0 360], [4.8 4.8], 'linewidth', 1, 'linestyle', '--', 'color', 'k');

box off
set(gca, 'color', 'w', 'fontsize', 15, 'linewidth', 2);
xlim([0 360]);
xlabel("Number of Configurations");
ylabel("Localization Error (mm)");
set(gcf, 'color', 'w', 'position', [100 100 544 313]);
