lines = join(readlines("Data/AmodoRandoms/AmodoRandoms.txt"));
lines = split(lines, "] "); lines = lines(1:end-1);

positions = zeros([length(lines), 2]);
readingsA = zeros([length(lines), 360]);
readingsB = zeros([length(lines), 360]);

for i = 1:length(lines)
    intermediate = split(lines(i), ", [");
    positions(i, :) = str2double(split(intermediate(1), ",")).';
    tempreading = split(intermediate(2), "]");
    tempreading = split(regexprep(tempreading(1),' +',', '), ", ");
    readingsA(i, :) = str2double(tempreading(1:360)).';


    tempreading = regexprep(intermediate(3),' +',', ');
    tempreading = split(tempreading, ", ");
    readingsB(i, :) = str2double(tempreading(1:360)).';
end

responseobject = SkinResponse(readingsB-readingsA, nan, positions);