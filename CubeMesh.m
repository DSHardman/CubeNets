clf

%% Create cube net mesh and electrodes

% Start with rectangle, from which elements will be removed
n_elec = [24, 1];
xy_size = [64, 48];
xy_size = xy_size + 1;

xvec = linspace(-2,2,xy_size(1));
yvec = linspace(-1.5,1.5,xy_size(2));
fmdl = mk_grid_model([],xvec,yvec);

% Position electrodes
el_nodes = [];
for i = 1:8
    el_nodes = [el_nodes 1305+(i-1)*8 1825+(i-1)*8];
end
el_nodes = [el_nodes 297 305 817 825];
el_nodes = [el_nodes 2377 2385 2897 2905];

for i=1:length(el_nodes)
    n = el_nodes(i);
    fmdl.electrode(i).nodes= n;
    fmdl.electrode(i).z_contact= 0.001; % choose a low value
end

% Remove elements not from mesh
to_remove = [];
for i = 1:16
    to_remove = [to_remove 1+(i-1)*128:64+(i-1)*128];
    to_remove = [to_remove 97+(i-1)*128:128+(i-1)*128];
    to_remove = [to_remove 6017-(i-1)*128:6080-(i-1)*128];
    to_remove = [to_remove 6113-(i-1)*128:6144-(i-1)*128];
end
fmdl = remove_elems(fmdl, to_remove, {});

%% Generate stimulation patterns

% Create initial structure for stim pattern: this is overwritten
stim = mk_stim_patterns(24, 1, '{op}', '{ad}', {}, 1);
fmdl.stimulation = stim;

% Flat sets (mapping to breakout connectors)
sets = [2 4 6 8 7 5 3 1;
        6 8 10 12 11 9 7 5;
        10 12 14 16 15 13 11 9;
        24 22 12 11 9 10 21 23;
        12 11 20 18 17 19 9 10];

opadinds = [1 5 2 3 3 4 6 7 7 8;
            2 6 3 4 4 5 7 8 8 1;
            3 7 1 2 4 5 5 6 8 1;
            4 8 1 2 2 3 5 6 6 7;
            5 1 2 3 3 4 6 7 7 8;
            6 2 3 4 4 5 7 8 8 1;
            7 3 1 2 4 5 5 6 8 1;
            8 4 1 2 2 3 5 6 6 7];

adadinds = [1 2 3 4 4 5 5 6 6 7 7 8;
            2 3 4 5 5 6 6 7 7 8 8 1;
            3 4 1 2 5 6 6 7 7 8 8 1;
            4 5 1 2 2 3 6 7 7 8 8 1;
            5 6 1 2 2 3 3 4 7 8 8 1;
            6 7 1 2 2 3 3 4 4 5 8 1;
            7 8 1 2 2 3 3 4 4 5 5 6;
            8 1 2 3 3 4 4 5 5 6 6 7];

% opadinds = [1 5 2 3; 1 5 3 4; 1 5 6 7; 1 5 7 8;
%             2 6 3 4; 2 6 4 5; 2 6 7 8; 2 6 8 1;
%             3 7 1 2; 3 7 4 5; 3 7 5 6; 3 7 8 1;
%             4 8 1 2; 4 8 2 3; 4 8 5 6; 4 8 6 7;
%             5 1 2 3; 5 1 3 4; 5 1 6 7; 5 1 7 8;
%             6 2 3 4; 6 2 4 5; 6 2 7 8; 6 2 8 1;
%             7 3 1 2; 7 3 4 5; 7 3 5 6; 7 3 8 1;
%             8 4 1 2; 8 4 2 3; 8 4 5 6; 8 4 6 7];
% 
% adadinds = [1 2 3 4; 1 2 4 5; 1 2 5 6; 1 2 6 7; 1 2 7 8;
%             2 3 4 5; 2 3 5 6; 2 3 6 7; 2 3 7 8; 2 3 8 1;
%             3 4 1 2; 3 4 5 6; 3 4 6 7; 3 4 7 8; 3 4 8 1;
%             4 5 1 2; 4 5 2 3; 4 5 6 7; 4 5 7 8; 4 5 8 1;
%             5 6 1 2; 5 6 2 3; 5 6 3 4; 5 6 7 8; 5 6 8 1;
%             6 7 1 2; 6 7 2 3; 6 7 3 4; 6 7 4 5; 6 7 8 1;
%             7 8 1 2; 7 8 2 3; 7 8 3 4; 7 8 4 5; 7 8 5 6;
%             8 1 2 3; 8 1 3 4; 8 1 4 5; 8 1 5 6; 8 1 6 7];

% Add OPAD and ADAD for each of the 5 sets
n_stims = 0;
% for i = 1:size(sets, 1)
%     for j = 1:size(opadinds, 1)
%         % Add OPAD measurements
%         n_stims = n_stims + 1;
%         fmdl.stimulation(n_stims).stim_pattern = sparse([sets(i, opadinds(j, 1)) sets(i, opadinds(j, 2))],1,[1,-1],24,1);
%         fmdl.stimulation(n_stims).meas_pattern = sparse(1, [sets(i, opadinds(j, 3)) sets(i, opadinds(j, 4))],[1,-1],1,24);
%         fmdl.stimulation(n_stims).stimulation = 'Amp';
%     end
% 
%     for j = 1:size(adadinds, 1)
%         % Add ADAD measurements
%         n_stims = n_stims + 1;
%         fmdl.stimulation(n_stims).stim_pattern = sparse([sets(i, adadinds(j, 1)) sets(i, adadinds(j, 2))],1,[1,-1],24,1);
%         fmdl.stimulation(n_stims).meas_pattern = sparse(1, [sets(i, adadinds(j, 3)) sets(i, adadinds(j, 4))],[1,-1],1,24);
%         fmdl.stimulation(n_stims).stimulation = 'Amp';
%     end
% end
for i = 1:size(sets, 1)
    for j = 1:size(opadinds, 1)
        % Add OPAD measurements
        measmatrix = zeros([(size(opadinds,2)-2)/2, 24]);
        n_stims = n_stims + 1;
        fmdl.stimulation(n_stims).stim_pattern = sparse([sets(i, opadinds(j, 1)) sets(i, opadinds(j, 2))],1,[1,-1],24,1); 
        for k = 1:((size(opadinds,2)-2)/2)
            measmatrix(k, opadinds(k*2+1)) = 1;
            measmatrix(k, opadinds(k*2+2)) = -1;
        end
        fmdl.stimulation(n_stims).meas_pattern = sparse(measmatrix);
        fmdl.stimulation(n_stims).stimulation = 'Amp';
    end

    for j = 1:size(adadinds, 1)
        % Add ADAD measurements
        measmatrix = zeros([(size(adadinds,2)-2)/2, 24]);
        n_stims = n_stims + 1;
        fmdl.stimulation(n_stims).stim_pattern = sparse([sets(i, adadinds(j, 1)) sets(i, adadinds(j, 2))],1,[1,-1],24,1);
        % fmdl.stimulation(n_stims).meas_pattern = sparse(1, [sets(i, adadinds(j, 3)) sets(i, adadinds(j, 4))],[1,-1],1,24);
        for k = 1:((size(adadinds,2)-2)/2)
            measmatrix(k, adadinds(k*2+1)) = 1;
            measmatrix(k, adadinds(k*2+2)) = -1;
        end
        fmdl.stimulation(n_stims).meas_pattern = sparse(measmatrix);
        fmdl.stimulation(n_stims).stimulation = 'Amp';
    end
end

%% Add any inclusions to mesh
sim_img= mk_image(fmdl,1);

homo_c = 0.1;
for j = 1:length(sim_img.elem_data)
    sim_img.elem_data(j) = homo_c;
end

% inclusion_c = 0.7;
% for i = 1:5
%     sim_img.elem_data(1619-(i-1)*64:1624-(i-1)*64) = inclusion_c;
% end

subplot(1,3,1);
show_fem(sim_img); axis off;

%% Solve forward model
sim_img.fwd_solve.get_all_meas = 1;
vh = fwd_solve(sim_img);

%% Set up inverse model
inv2d= eidors_obj('inv_model', 'EIT inverse');
inv2d.reconst_type= 'difference';
inv2d.jacobian_bkgnd.value= 1;
inv2d.fwd_model= fmdl;
inv2d.hyperparameter.value = 0.8;
inv2d.solve=       'inv_solve_diff_GN_one_step';
inv2d.RtR_prior=   'prior_laplace';
inv2d.stimulation = fmdl.stimulation;

%% Plot quiver of selected channel (dependent on injections only)
channel = 30; % Up to 360

sim_img.fwd_model.mdl_slice_mapper.npx = 64;
sim_img.fwd_model.mdl_slice_mapper.npy = 64;
PLANE= [inf,inf,0];
sim_img.fwd_model.mdl_slice_mapper.level = PLANE;

subplot(1,3,2);
q = show_current(sim_img, vh.volt(:,channel));
quiver(q.xp,q.yp, q.xc,q.yc,10, 'b');
axis equal;
xlim([-2 2]);
ylim([-1.5 1.5]);
box off; axis off;
title("Channel " + string(channel));

%% Plot measurements
subplot(1,3,3);
line([channel channel], [0 5], 'color', 'k', 'LineStyle', '--');
hold on;
for i = 1:5
    plot([1+(i-1)*72:32+(i-1)*72], abs(vh.meas(1+(i-1)*72:32+(i-1)*72)), 'color', 'b');
    plot([33+(i-1)*72:72+(i-1)*72], abs(vh.meas(33+(i-1)*72:72+(i-1)*72)), 'color', 'r');
end
xlim([1 360]);
box off;

set(gcf, 'position', [61         388        1397         261], 'color', 'w');

return
%% Plot actual data, if board attached
clear device
device = serialport("COM17",9600);
device.Timeout = 25;

flush(device); readline(device);
fprintf("Collecting baseline...\n");
baseline = zeros([1 360]);
for i = 1:10
    baseline = baseline + str2num(readline(device));
end
baseline = baseline./10;
fprintf("Baseline collected.\n");

figure();
set(gcf, 'position', [979   123   391   186], 'color', 'w');
for i = 1:1000
    data = str2num(readline(device));
    % data = data - baseline;
    % 
    % clf
    % for i = 1:5
    %     plot([1+(i-1)*72:32+(i-1)*72], data(1+(i-1)*72:32+(i-1)*72), 'color', 'b');
    %     hold on
    %     plot([33+(i-1)*72:72+(i-1)*72], data(33+(i-1)*72:72+(i-1)*72), 'color', 'r');
    % end
    % 
    % box off;
    % xlim([1 360]);
    % ylim([-0.05 0.05]);
    % set(gcf, 'position', [979   123   391   186], 'color', 'w');
    % drawnow();

    rec_img= inv_solve(inv2d, baseline.', data.');
    f = show_fem(rec_img, [1 0 0]);
    drawnow();
end

clear device

%%%




% f = show_fem(rec_img, [1 0 0]);
% eidors_colourbar(500,0);

