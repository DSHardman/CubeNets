clear device
device = serialport("COM13",9600);
device.Timeout = 25;

n = 100;

classes = {"1Touch"; "1Conduct"; "1Press"; "2Touch"; "2Conduct"; "2Press"};
clear combinedclasses; combinedclasses{n} = "";

baselines = zeros([n, 360]);
datas = zeros([n, 360]);

for i = 1:n
    i
    fprintf("Baseline...\n");
    pause();

    combinedclasses{i} = classes{randi(6)};
    fprintf(combinedclasses{i}+"\n");
    baseline = readamodo(device, 1);
    fprintf("Stimulus...\n");
    pause();
    data = readamodo(device, 1);
    baselines(i, :) = baseline;
    datas(i, :) = data;
end

function data = readamodo(device, n)
    if nargin == 1
        n = 1;
    end
    flush(device); readline(device);
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