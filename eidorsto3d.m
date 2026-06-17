function eidorsto3d(rec_img, visiblesides)

    positions = zeros([size(rec_img.fwd_model.elems, 1) 2]);
    
    for i = 1:size(positions, 1)
        positions(i, :) = mean(rec_img.fwd_model.nodes(rec_img.fwd_model.elems(i,:), :));
    end
    positions(:,1) = 30*(2-positions(:,1));
    positions(:,2) = 30*(0.5-positions(:,2));

    subplot(1,3,1);
    interpolatedcube(positions(:,1), positions(:,2), rec_img.elem_data);
    axis equal
    colorbar off
    set(gca, 'XDir', 'Reverse');
    set(gca, 'YDir', 'Reverse');
    
    subplot(1,3,2);
    foldcube(SkinResponse(rec_img.elem_data, nan, positions), 1, visiblesides);
    view([200 30]);

    subplot(1,3,3);
    foldcube(SkinResponse(rec_img.elem_data, nan, positions), 1, visiblesides);
    view([20 -30]);
end