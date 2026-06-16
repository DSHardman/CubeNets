% Requires mesh to have previously been set up with CubeMesh.m
load("Data/AmodoRandoms/AmodoExtracted.mat");

errors = zeros([3000, 1]);
for i = 1:3000
    rec_img= inv_solve(inv2d, responseobject.responses(i,:).', zeros([360, 1]));

    groundtruth = [(60-responseobject.positions(i, 1))/30 (15-responseobject.positions(i,2))/30];
    [~, ind] = min(rec_img.elem_data);
    prediction = mean(rec_img.fwd_model.nodes(rec_img.fwd_model.elems(ind, :), :));
    errors(i) = 30*rssq(groundtruth-prediction);

    % rec_img.elem_data = -rec_img.elem_data;
    % upperlimit = 0.0005; % Cut colorbar at zero
    % rec_img.calc_colours.ref_level = upperlimit/2;
    % rec_img.calc_colours.clim = upperlimit/2;
    % f = show_fem(rec_img, [1 0 0]);
    % set(gca, 'xdir', 'reverse');
    % set(gca, 'ydir', 'reverse');
    % hold on
    % scatter(groundtruth(1), groundtruth(2), 60, 'm', 'filled');
    % scatter(prediction(1), prediction(2), 60, 'w', 'filled');
    % title(string(i));
    % pause()
    % hold off
end