clear device
device = serialport("COM11",9600);
device.Timeout = 25;

baselines = zeros([39, 360]);
datas = zeros([39, 360]);

for i = 1:39
    fprintf("Baseline...\n");
    pause();
    baseline = readamodo(device, 5);
    fprintf("Stimulus...\n");
    pause();
    data = readamodo(device, 5);

    rec_img= inv_solve(inv2d, data.', baseline.');
    f = show_fem(rec_img, [1 0 0]);

    baselines(i, :) = baseline;
    datas(i, :) = data;
end

function data = readamodo(device, n)
    if nargin == 1
        n = 1;
    end
    flush(device); readline(device);
    data = zeros([1 360]);
    for i = 1:1
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