function districts = Indicators_To_Districts(indicators, numParishes, numDistricts)
    % Input:
    % indicators - the large indicator vector combining all districts
    % numParishes - number of parishes (same as the dimension of C in the original function)
    % numDistricts - number of districts

    % Initialize the district vector
    districts = zeros(numParishes, 1);

    % Loop through each district to decode their parishes
    for i = 1:numDistricts
        % Calculate the start and end index for the current district in the indicator vector
        startIndex = (i - 1) * numParishes + 1;
        endIndex = i * numParishes;

        % Extract the portion of the indicator vector corresponding to this district
        districtParishes = indicators(startIndex:endIndex);

        % Assign the district number to the correct parishes
        districts(districtParishes == 1) = i;
    end
end