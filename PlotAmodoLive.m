clear device
device = serialport("COM20",9600);
device.Timeout = 25;

global baseline
baseline = readamodo(device, 1);
clf
btn = uibutton(gcf, 'Text', 'Baseline', 'Position', [450 80 100 30],...
    'ButtonPushedFcn', @(src,event) baselinebutton(device));

for i = 1:3000
    data = readamodo(device, 1);

    % [sum, targetpositions] = plotWAMScube(data-baseline);
    % hold off
    plot(data-baseline);
    % plot(data);
    title(string(i));
    ylim([-0.01 0.01]);
    drawnow();
end


function data = readamodo(device, n)
    if nargin == 1
        n = 1;
    end
    % flush(device);
    readline(device);
    data = zeros([1 360]);
    for i = 1:n
        temp = split(readline(device), ",");
        for j = 1:360
            if contains(char(temp(j)), 'C')
                fprintf("Clipped\n");
                unclipped = char(temp(j));
                unclipped = unclipped(1:end-1);
                data(j) = data(j) + str2num(unclipped);
            else
                data(j) = data(j) + str2num(temp(j));
            end
        end
    end
    data = data./n;
end

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