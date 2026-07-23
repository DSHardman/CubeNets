factor1 = 12;
factor2 = -10;
injections = [1 2];

% 2D Model
imdl= mk_common_model('d2s',8);
stim = imdl.fwd_model.stimulation;

clear elec_nodes;
elec_nodes{1}= [-1.75 -0.25];
[x,y] = meshgrid(linspace(-2,2,65), linspace(-1.5,1.5,35));
vtx= [x(:),y(:)];
fmdl = mk_fmdl_from_nodes(vtx, elec_nodes, 0.01, 'test');
% Add electrodes
el_nodes = [300 1910 1911:1916];
for i=1:length(el_nodes)
    n = el_nodes(i);
    fmdl.electrode(i).nodes= n;
    fmdl.electrode(i).z_contact= 0.001; % choose a low value
end
imdl.fwd_model = fmdl;
imdl.fwd_model.stimulation = stim;

% Create an homogeneous image
img_1 = mk_image(imdl);

% Add a circular object
img_v = img_1;
select_fcn = inline('(x+0.75).^2+(y+0.5).^2<0.4^2','x','y','z');
% select_fcn = inline('(x).^2+(10*y+3).^2<0.5^2','x','y','z');
img_v.elem_data = factor1 + factor2*elem_select(img_v.fwd_model, select_fcn);

% Visualise FEM
% show_fem(img_v);
% axis off; axis equal;

PLANE= [inf,inf,0]; % show voltages on this slice

img_v.fwd_solve.get_all_meas = 1;
vh = fwd_solve(img_v);


%% Plot Current quiver
img_v.fwd_model.mdl_slice_mapper.npx = 64;
img_v.fwd_model.mdl_slice_mapper.npy = 64;
img_v.fwd_model.mdl_slice_mapper.level = PLANE;
q = show_current(img_v, vh.volt(:,1));

img_v = rmfield(img_v, 'elem_data');
img_v.node_data = vh.volt(:,1);
img_v.calc_colours.npoints = 256;
imgs = calc_slices(img_v,PLANE);

% sx = [linspace(-1,1,15)'; linspace(-1,1,15)'; linspace(-1,1,15)'; linspace(-1,1,15)'];
% sy = [linspace(-1,1,30)'; linspace(1,-1,30)'];

% Choose starting points from a circle around first injection electrode
sx = [];
sy = [];
inj = fmdl.nodes(el_nodes(1), :);
inj_x = inj(1); inj_y = inj(2);
for i = 0:pi/20:2*pi
    [dx, dy] = pol2cart(i, 0.03);
    sx = [sx; dx+inj_x];
    sy = [sy; dy+inj_y];
end

hh=streamline(q.xp,q.yp, q.xc, q.yc,sx,sy); set(hh,'Linewidth',1, 'color', [0.5 0.5 0.5]);
% hh=streamline(q.xp,q.yp,-q.xc,-q.yc,sx,sy); set(hh,'Linewidth',1, 'color', [0.5 0.5 0.5]);
hold on; rectangle('Position',[-2 -1.5 4 3]);
scatter3(nan, nan, nan)

hold off; axis off; axis equal;
