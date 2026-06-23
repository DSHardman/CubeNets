load("Data/FoldedFilm/film2.mat");
clf

figureplots = [2 4 5 9];
limits = 1e-3*[-0.069 0.07; -0.335 1.1; -0.1 0.7;-0.147 1.4];

for i = 1:4
    subplot(1,4,i);
    rec_img= inv_solve(inv2d, datas(figureplots(i), :).', baselines(figureplots(i), :).');
    eresponse = eidorsto3d(rec_img, nan);
    foldexplodecube(eresponse, 1);
    clim(limits(i, :));
    % set(gcf, 'color', 'none')
    % set(gca, 'color', 'none');
    % exportgraphics(gca, "folded"+string(i)+".png", "resolution", 200);
end
set(gcf, 'position', [114 323 1264 418]);

%% Raw signals
% for i = 1:4
%     subplot(1,4,i);
%     plot(1000*[datas(figureplots(i), :)-baselines(figureplots(i), :)], 'color', 'r', 'linewidth', 2);
%     box off
%     ylim([-6 4]);
%     xlim([0 360]);
%     set(gcf, 'color', 'w', 'position', [114 323 1182 170]);
%     set(gca, 'linewidth', 2, 'fontsize', 15);
% end
% set(gcf, 'position', [114 323 1264 418]);

%% Plot all 12 in a single figure: supplementary material
% for i = 1:12
%     % clf
%     rec_img= inv_solve(inv2d, datas(i, :).', baselines(i, :).');
%     eresponse = eidorsto3d(rec_img, nan);
%     subplot(3,4,i);
%     % clf
%     foldexplodecube(eresponse, 1);
%     title(string(i));
%     % pause();
% end