function fitness = CSO_OF(y, D, P, VP, APBVP, r)
    % Define constants
    n = size(D, 1); % Number of parishes
    K = size(y, 2) / n; % Number of districts
    totalPopulation = sum(P);
    minPop = 0.1 * totalPopulation; % Minimum population for a district
    maxPop = 0.2 * totalPopulation; % Maximum population for a district

    M = 100000; % arbirary constant for big M

    % Initialize the fitness vector
    fitness = zeros(size(y, 1), 1);

    % Loop over each solution
    for idx = 1:size(y, 1)
        % Reshape the solution to match districts and parishes
        assignmentMatrix = reshape(y(idx, :), [n, K]);

        % Calculate the primary objective
        distanceCost = sum(sum(assignmentMatrix .* D));

        % Initialize penalties
        penalty1 = 0; %underpopulation penalty
        penalty2 = 0; %overpopulation penalty

        %penalties for not having two majority black districts
        penalty3 = 0; 
        penalty4 = 0;

        %Initialize count of non-majority black districts
        h_i_count = 0;

        % Calculate population penalties for each district
        for k = 1:K
            %get district data
            districtPopulation = sum(P .* assignmentMatrix(:, k));
            districtVPopulation = sum(VP .* assignmentMatrix(:, k));
            districtAPBVPopulation = sum(APBVP .* assignmentMatrix(:, k));

            %initialize the indicator variable for non-majority black
            %population
            h_i = 0;
            % Penalty for underpopulation
            penalty1 = penalty1 + max([0, minPop - districtPopulation]);
            % Penalty for overpopulation
            penalty2 = penalty2 + max([0, districtPopulation - maxPop]);

            % Check if district has a majority black voting age population
            if districtAPBVPopulation < 0.5*districtVPopulation
                h_i_count = h_i_count + 1;
                h_i = 1;
            end
            penalty3 = penalty3 + max([0, 0.5*districtVPopulation-districtAPBVPopulation-h_i*(M)]);  
        end
        penalty4 = max([0, h_i_count - 4]);


        % Calculate total penalty
        totalPenalty = penalty1 + penalty2 + penalty3 + penalty4;

        % Compute total cost including penalties
        fitness(idx) = distanceCost + r * totalPenalty;
    end
end