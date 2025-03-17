classdef SkinResponse
    % Class to store responses & methods of each skin test

    properties
        responses
        times
        positions
    end

    methods
        function obj = SkinResponse(responses, times, positions)
            % Constructor - this is run in extraction script
            obj.responses = responses;
            obj.times = times;
            obj.positions = positions;
        end
    end
end