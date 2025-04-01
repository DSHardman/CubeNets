% Inefficient script for extracting data - good enough for functionality
% [readings, readingtimes] = extracteit("Data/Data24Flat/Data24Flat_3");
% [positions, positiontimes] = extractprinter("Data/Data24Flat/Data24Flat_skin_3.txt");

readingst = [];
readingtimest = [];
for i = 1:9
    load("cube24_"+string(i)+".mat");
    readingst = [readingst; readings];
    readingtimest = [readingtimest readingtimes];
end

load("extractedpositions.mat");
responseobject = combinedata(readingst, readingtimest, positions, positiontimes);
save("wholeway.mat", "responseobject");

% Extract data from EIT board
function [readings, readingtimes] = extracteit(filename)
    lines = readlines(filename);
    lines = lines(2:end-1);
    
    % readings = zeros([length(lines), 360]);
    % readingtimes(length(lines)) = datetime();

    readings = zeros([10000, 360]);
    readingtimes(10000) = datetime();

    for k = 1:9
        for i = 1:10000
            if mod(i, 100) == 0
                i
            end
            line = char(lines(i+(k-1)*10000));
            readingtimes(i) = datetime(line(2:24));
            response = str2double(split(line(27:end), ", "));
            readings(i, :) = response(1:360);
        end
        save("cube24_"+string(k)+".mat", "readings", "readingtimes");
    end
end


% Extract data from printer
function [positions, positiontimes] = extractprinter(filename)
    lines = readlines(filename);
    lines = lines(1:end-1);
    
    positions = zeros([length(lines), 2]);
%     positions = zeros([length(lines), 3]);
    positiontimes(length(lines), 3) = datetime();
    
    for i = 1:length(lines)
        items = split(char(lines(i)), ", ");
        positions(i, :) = [str2double(items{1, 1}) str2double(items{2, 1})];
%         positions(i, :) = [str2double(items{1, 1}) str2double(items{2, 1}) str2double(items{3, 1})];
        positiontimes(i, :) = [datetime(items{3, 1}) datetime(items{4, 1}) datetime(items{5, 1})];
%         positiontimes(i, :) = [datetime(items{4, 1}) datetime(items{5, 1}) datetime(items{6, 1})];
    end
end

% Combine data to create object
function responseobject = combinedata(readings, readingtimes, positions, positiontimes)

    % Ensure there are no nans in response before beginning
    goodindices = [];
    for i = 1:length(readings)
        if ~any(isnan(readings(i, :)))
            goodindices = [goodindices; i];
        end
    end
    readings = readings(goodindices, :);
    readingtimes = readingtimes(goodindices);

    responses = zeros([length(positions), 360]);
    for i = 1:length(positions)
        i
        ind1 = find(readingtimes>positiontimes(i, 2), 1, "first");
        ind2 = find(readingtimes<positiontimes(i, 2)+seconds(5), 1, "last");

        ind3 = find(readingtimes>positiontimes(i, 1)-seconds(5), 1, "first");
        ind4 = find(readingtimes<positiontimes(i, 1), 1, "last");

        if isempty(ind1) || isempty(ind2) || isempty(ind3) || isempty(ind4)
            i
            fprintf("NAN READING\n");
        end

        responses(i, :) = mean(readings(ind1:ind2, :)) - mean(readings(ind3:ind4, :));
    end
    responseobject = SkinResponse(responses, positiontimes(:, 2), positions);
end