clf
close all
global baseline

% mode = 'd'; % discrete
mode = 'c'; % continuous

%% Load in and process WAMs data
load("Data/AmodoRandoms/AmodoExtracted.mat");
responses = responseobject.responses;
targetpositions = responseobject.positions;
responses = tanh(normalize(responses)); % Deal with outliers
% Generate test & train sets
traininds = randperm(length(targetpositions));
responses = responses(traininds, :);
targetpositions = targetpositions(traininds, :);

%% Additively build mesh and electrodes
clear elec_nodes;

% Mesh 1
elec_nodes{1}= [-1.75 -0.25];
[x,y] = meshgrid(linspace(-2,2,65), linspace(-0.5,0.5,17));
vtx= [x(:),y(:)];
fmdl1 = mk_fmdl_from_nodes(vtx, elec_nodes, 0.01, 'test');

% Mesh 2
elec_nodes{1}= [0 0.5];
[x,y] = meshgrid(linspace(0,1,17), linspace(0.5,1.5,17));
vtx= [x(:),y(:)];
fmdl2 = mk_fmdl_from_nodes(vtx, elec_nodes, 0.01, 'test');

% Mesh 3
elec_nodes{1}= [0 -0.5];
[x,y] = meshgrid(linspace(0,1,17), linspace(-1.5,-0.5,17));
vtx= [x(:),y(:)];
fmdl3 = mk_fmdl_from_nodes(vtx, elec_nodes, 0.01, 'test');

% Combine meshes
fmdl = merge_meshes(fmdl1, fmdl2, fmdl3);

% Add electrodes
el_nodes = [73 81 209 217 345 353 481 489 617 625 753 761,...
    889 897 1025 1033 1446 1574 1454 1582 1173 1301 1181 1309];
for i=1:length(el_nodes)
    n = el_nodes(i);
    fmdl.electrode(i).nodes= n;
    fmdl.electrode(i).z_contact= 0.001; % choose a low value
end

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

% % Add OPAD and ADAD for each of the 5 sets
n_stims = 0;

for i = 1:size(sets, 1)
    for j = 1:size(opadinds, 1)
        % Add OPAD measurements
        measmatrix = zeros([(size(opadinds,2)-2)/2, 24]);
        n_stims = n_stims + 1;
        fmdl.stimulation(n_stims).stim_pattern = sparse([sets(i, opadinds(j, 1)) sets(i, opadinds(j, 2))],1,[1,-1],24,1); 
        for k = 1:((size(opadinds,2)-2)/2)
            measmatrix(k, sets(i, opadinds(j, k*2+1))) = 1;
            measmatrix(k, sets(i, opadinds(j, k*2+2))) = -1;
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
            measmatrix(k, sets(i, adadinds(j, k*2+1))) = 1;
            measmatrix(k, sets(i, adadinds(j, k*2+2))) = -1;
        end
        fmdl.stimulation(n_stims).meas_pattern = sparse(measmatrix);
        fmdl.stimulation(n_stims).stimulation = 'Amp';
    end

end

%% Set up inverse model
inv2d= eidors_obj('inv_model', 'EIT inverse');
inv2d.reconst_type= 'difference';
inv2d.jacobian_bkgnd.value = 1;
inv2d.fwd_model= fmdl;
inv2d.hyperparameter.value = 0.5;
inv2d.solve=       'inv_solve_diff_GN_one_step';
inv2d.RtR_prior=   'prior_laplace';
inv2d.stimulation = fmdl.stimulation;

%% Connect to board
clear device
device = serialport("COM11",9600);
device.Timeout = 25;

flush(device); readline(device);
fprintf("Collecting baseline...\n");
baseline = zeros([1 360]);
for i = 1:1
    temp = split(readline(device), ",");
    for j = 1:360
        if contains(char(temp(j)), 'C')
            fprintf("Baseline Clipped\n");
            unclipped = char(temp(j));
            unclipped = unclipped(1:end-1);
            baseline(j) = baseline(j) + str2num(unclipped);
        else
            baseline(j) = baseline(j) + str2num(temp(j));
        end
    end
end
baseline = baseline./i;
fprintf("Baseline collected.\n");

baselinebuffer = [baseline; baseline; baseline; baseline];

figure();
btn = uibutton(gcf, 'Text', 'Baseline', 'Position', [450 80 100 30],...
    'ButtonPushedFcn', @(src,event) baselinebutton(device));

% Continuous mode: initial baseline
while 1
        flush(device);
        % readline(device);
        temp = split(readline(device),",");
        while length(temp) ~= 360
            temp = split(readline(device),",");
        end
        for j = 1:360
            if contains(char(temp(j)), 'C')
                fprintf("Clipped\n");
                unclipped = char(temp(j));
                unclipped = unclipped(1:end-1);
                data(j) = str2num(unclipped);
            else
                data(j) = str2num(temp(j));
            end
        end

        if mode == 'c'
            % baselinebuffer = [baselinebuffer(2:4, :); data];
            % baseline = baselinebuffer(1,:);
            ;
        else
            baseline = data;
            pause();
            fprintf("Collecting data...\n");
            flush(device);
            readline(device);
            temp = split(readline(device),",");
            for j = 1:360
                if contains(char(temp(j)), 'C')
                    fprintf("Clipped\n");
                    unclipped = char(temp(j));
                    unclipped = unclipped(1:end-1);
                    data(j) = str2num(unclipped);
                else
                    data(j) = str2num(temp(j));
                end
            end
        end

        rec_img= inv_solve(inv2d, baseline.', data.');

        upperlimit = 0.00015; % Cut colorbar at zero
        if max(rec_img.elem_data) < upperlimit
            rec_img.calc_colours.ref_level = upperlimit/2;
            rec_img.calc_colours.clim = upperlimit/2;
        end
        rec_img.elem_data = max(rec_img.elem_data, 0);

        % subplot(1,2,1);
        % show_fem(rec_img, [1 0 0]);
        % axis off
        % axis equal
        % % drawnow();
        % colorbar('delete')
        eidorsto3d(rec_img, [1 1 1 1 1 1]);

        subplot(2,2,3);
        % Realtime WAMs prediction
        datab = data - baseline;
        sum = zeros([size(responses, 1), 1]);
        combinations = 1:360;
        for j = 1:length(combinations)
            newsum = datab(combinations(j))*responses(:, combinations(j));
            if isempty(find(isnan(newsum), 1))
                sum = sum + newsum;
            end
        end

        % Plot WAMs
        % sum = max(sum, 0);
        % targetpositions = ([-1 0; 0 -1]*(targetpositions - [60 15]).').' + [60 15];
        scatter(targetpositions(:,1), targetpositions(:,2), 150, sum, 'filled');

        if mode == 'd'
            [~, ind] = sort(sum, 'descend');
            prediction = [targetpositions(ind(1),1),...
                            targetpositions(ind(1),2)];
            hold on
            scatter(prediction(1), prediction(2), 300, 'm', 'filled');
            hold off
        end

        % interpolatedcube(targetpositions(:,1), targetpositions(:,2), sum);
        clim([min(-0.03, min(sum)) max(0.03, max(sum))]);
        colorbar off
        axis off
        axis equal
        set(gca, 'XDir', 'reverse', 'YDir', 'reverse');

        subplot(2,2,4);
        foldcube(SkinResponse(sum, nan, targetpositions), 1, [1 1 1 1 1 1]);

        set(gcf, 'color', 'w');
        drawnow;

        if mode == 'd'
            pause();
            fprintf("Collecting baseline...\n");
        end
end

clear device

function baselinebutton(device)
    fprintf("Updating baseline...\n");
    global baseline
    % flush(device);
    readline(device);
    temp = split(readline(device),",");
    for j = 1:360
        if contains(char(temp(j)), 'C')
            fprintf("Clipped\n");
            unclipped = char(temp(j));
            unclipped = unclipped(1:end-1);
            data(j) = str2num(unclipped);
        else
            data(j) = str2num(temp(j));
        end
    end
    baseline = data;
    fprintf("Baseline updated.\n");
end