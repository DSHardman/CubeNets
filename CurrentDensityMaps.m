% Can only be run after CubeMesh.m

channel = 49;
% channel = 4;

sim_img.fwd_model.mdl_slice_mapper.npx = 200;
sim_img.fwd_model.mdl_slice_mapper.npy = 200;
PLANE= [inf,inf,0];
sim_img.fwd_model.mdl_slice_mapper.level = PLANE;

q = show_current(sim_img, vh.volt(:,channel));

q_magnitude = zeros(size(q.xc));
for i = 1:size(q.xc, 1)
    for j = 1:size(q.xc, 2)
        q_magnitude(i,j) = sqrt(q.xc(i,j)^2+q.yc(i,j)^2);
    end
end

% Remove points from outside net
for k = 1:size(q.xc,1)
    for j = 1:size(q.xc,2)
        if (q.yp(j) > 0.5 || q.yp(j) < -0.5) && (q.xp(k) > 1 || q.xp(k) < 0)
            q_magnitude(j,k) = nan;
        end
    end
end
contourf(q.xp,q.yp,q_magnitude, 500, 'LineStyle', 'none');
colorbar;
axis off;
set(gcf, 'color', 'w');
