function plotall4(data, baseline, inv2d)
    subplot(2,2,1);
    [sum, targetpositions] = plotWAMScube(data-baseline);
    subplot(2,2,2);
    foldcube(SkinResponse(sum, nan, targetpositions), 1, [1 1 1 1 1 1]);
    subplot(2,2,3)
    rec_img= inv_solve(inv2d, data.', baseline.');
    eresponse = eidorsto3d(rec_img, [1 1 1 1 1 1]);
    subplot(2,2,4)
    foldcube(eresponse, 1, [1 1 1 1 1 1]);
    view([200 30]);
end