function contiguous = Check_District_Contiguity(C, y, K)
    % Check that all districts are contiguous based on a contiguity matrix and district assignments
    %
    % Inputs:
    % C - 64x64 adjacency matrix where C(i, j) = 1 if parish i is contiguous to parish j, 0 otherwise
    % districtAssignments - 64-element vector with district assignments for each parish
    % numDistricts - Number of districts
    %
    % Output:
    % contiguous - Logical indicating overall contiguity of this
    % solution vector

    % Initialize the graph from the adjacency matrix

    G = graph(C);

    % Initialize the output
    contiguous = true;

    % Check each district for contiguity
    for k = 1:K
        % Find nodes in the current district
        nodesInDistrict = find(y == k);

        % Extract the subgraph for these nodes
        if isempty(nodesInDistrict)
            contiguous = false;
            continue;  % Skip to next iteration if no nodes are assigned to this district
        end

        subG = subgraph(G, nodesInDistrict);

        % Check if the subgraph is connected
        % conncomp returns a vector that labels the component number for each node
        componentLabels = conncomp(subG);

        % If there is more than one unique component, then the district is not contiguous
        if numel(unique(componentLabels)) > 1
            contiguous = false;
        end
    end

    % Return the contiguity status
    return
end
