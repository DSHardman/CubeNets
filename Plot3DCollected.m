load("Data/FoldedFilm/FoldedFilm.mat");

for i = 1:12
    rec_img = inv_solve(inv2d, datas(i, :).', baselines(i, :).');
    eresponse = eidorsto3d(rec_img, [1 1 1 1 1 1]);
    foldexplodecube(eresponse, 1);

    % hold on
    % scatter(touches(i, 1), touches(i, 2), 50, 'm', 'filled');
    % hold off
    % % title(string(i));
    set(gcf, 'color', 'none');
    % axis off
    % colorbar off
    % exportgraphics(gca, "foldedtouch"+string(i)+".pdf", "resolution", 100);
    exportgraphics(gca, "foldedtouch"+string(i)+".pdf",...
        'BackgroundColor','none', 'ContentType', 'Vector');
    
    % pause();
    clf

end
return