function indicators = Districts_To_Indicators(districts, centers)
    % Input:
    % districts - 64-element vector of district assignments
    % centers - array of initial district centers (parish indices)

    numParishes = length(districts);
    numDistricts = length(centers);

    % Initialize the indicator vector
    indicators = zeros(numParishes * numDistricts, 1);

    % Fill the indicator vector
    for i = 1:numDistricts
        districtIndex = centers(i);
        districtParishes = districts == i;  % Logical vector for parishes in district i
        indicators((i-1) * numParishes + 1 : i * numParishes) = districtParishes;
    end
end