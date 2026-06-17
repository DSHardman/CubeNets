load("FoldedFilm.mat");

for i = 1:12
    rec_img = inv_solve(inv2d, datas(i, :).', baselines(i, :).');
    eidorsto3d(rec_img, [1 1 1 1 1 1]);
    % hold on
    % scatter(touches(i, 1), touches(i, 2), 50, 'm', 'filled');
    % hold off
    % % title(string(i));
    % set(gcf, 'color', 'w');
    % axis off
    % colorbar off
    % exportgraphics(gca, "staticfree"+string(i)+".png", "resolution", 100);
    pause();

end
return