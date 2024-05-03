function districts = Assign_Districts(C, centers)
    % Input:
    % C - 64x64 adjacency matrix of parishes
    % centers - array of initial district centers (parish indices)

    numParishes = size(C, 1);
    numDistricts = length(centers);
    
    % Initialize district assignment vector
    districts = zeros(numParishes, 1);

    % Assign each center to a unique district
    for i = 1:numDistricts
        districts(centers(i)) = i;
    end
    
    % While there are still unassigned parishes
    while any(districts == 0)
        % Find all unassigned parishes that are contiguous to at least one assigned parish
        unassigned = find(districts == 0);
        candidates = false(numParishes, 1);
        
        for i = unassigned'
            % Check if this parish is adjacent to any district
            contiguousDistricts = districts(C(i, :) == 1);
            if any(contiguousDistricts > 0)
                candidates(i) = true;
            end
        end
        
        % Select one of these candidates randomly
        candidates = find(candidates);
        selectedParish = candidates(randi(numel(candidates)));

        % Determine all districts this parish is contiguous to
        contiguousDistricts = districts(C(selectedParish, :) == 1);
        contiguousDistricts = unique(contiguousDistricts(contiguousDistricts > 0));
        
        % Randomly assign this parish to one of these districts
        districts(selectedParish) = contiguousDistricts(randi(length(contiguousDistricts)));
    end
    
end