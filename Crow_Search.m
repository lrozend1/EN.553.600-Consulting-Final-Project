rng("default")

% Define the parish names
parishNames = {'Acadia', 'Allen', 'Ascension', 'Assumption', 'Avoyelles', 'Beauregard', 'Bienville', 'Bossier', ...
               'Caddo', 'Calcasieu', 'Caldwell', 'Cameron', 'Catahoula', 'Claiborne', 'Concordia', 'De Soto', ...
               'East Baton Rouge', 'East Carroll', 'East Feliciana', 'Evangeline', 'Franklin', 'Grant', 'Iberia', ...
               'Iberville', 'Jackson', 'Jefferson', 'Jefferson Davis', 'Lafayette', 'Lafourche', 'LaSalle',...
               'Lincoln', 'Livingston', 'Madison', 'Morehouse', 'Natchitoches', 'Orleans', 'Ouachita', 'Plaquemines', ...
               'Pointe Coupee', 'Rapides', 'Red River', 'Richland', 'Sabine', 'St. Bernard', 'St. Charles', 'St. Helena', ...
               'St. James', 'St. John the Baptist', 'St. Landry', 'St. Martin', 'St. Mary', 'St. Tammany', 'Tangipahoa', ...
               'Tensas', 'Terrebonne', 'Union', 'Vermilion', 'Vernon', 'Washington', 'Webster', 'West Baton Rouge', ...
               'West Carroll', 'West Feliciana', 'Winn'};

% Load the adjacency matrix from the CSV file, assuming the rows and columns are ordered as per parishNames
C = readmatrix('Pairwise County Adjacency.csv');
C = C(:, 2:65);

% Number of vertices
n = numnodes(G);
K = 6;  % Number of districts

% Initialize the distance matrix
D = zeros(n,n);

% Calculate shortest paths
for i = 1:n
    for j = 1:n
        if i ~= j
            [~,pathlen] = shortestpath(G, i, j);
            D(i,j) = pathlen;
        end
    end
end

% District centers are at Caddo (i=9), Calcasieu (i=10), East Baton Rouge (i =17), Jefferson (i=26),  Orleans (i=36), Rapides (i=40)
% set D to be a 64x6 matrix of the distance of each parish from each
% district center
centers = [9, 10, 17,26,36,40];
CaddoDistance = D(:, 9);
CalcasieuDistance = D(:,10);
EastbatonrougeDistance = D(:,17);
JeffersonDistance = D(:,26);
OrleansDistance = D(:,36);
RapidesDistances = D(:,40);
D = [CaddoDistance, CalcasieuDistance, EastbatonrougeDistance,JeffersonDistance,OrleansDistance,RapidesDistances];

% Load data from CSV file
data = readtable('Louisiana County All Data.csv');

% Get parish population vector
P = table2array(data(:, "TotalPopulation"));

% Get parish voting age population vector
VP = table2array(data(:, "VotingAgePopulation"));

% Get parish any part black voting age population vector
APBVP = table2array(data(:, "BlackVotingAgePopulation"));

% Parameters for Crow Search Algorithm
N = 100; % Number of crows (solutions)
max_iter = 100; % Maximum number of iterations
fl = 0.1; % Flight length (a parameter that controls the step size)
AP = 0.5; % Awareness probability
r = 10;  % penalty parameter

% Initialize the positions of crows
y = zeros(N, n*K); % 100 rows for 100 crows, 64*6 columns for 64 parishes and 6 districts

% Each row corresponds to a crow, each column to a parish
% Loop to call assignDistricts 50 times
for i = 1:N
    random_districts = Assign_Districts(C, centers);
    y(i,:) = Districts_To_Indicators(random_districts, centers);
end

% Main loop of CSA
memory = y; % Memory initialization
fitness = inf(N, 1);

for i = 1:N
    fitness(i) = CSO_OF(y(i, :), D, P, VP, APBVP, r);
end
best_fitness = min(fitness);
best_position = y(find(fitness == best_fitness, 1, 'first'), :);
best_position = Indicators_To_Districts(best_position, 64, 6);

for t = 1:max_iter
    for i = 1:N
        if rand() >= AP
            % Follow the crow
            i_districts = Indicators_To_Districts(y(i, :), n,K);
            j_memory_districts = Indicators_To_Districts(memory(j, :), n,K);
            
            diff_indices = find(i_districts ~= j_memory_districts);  % indices where the assignments differ
            num_changes = ceil(fl * length(diff_indices));  % number of changes to make, based on flight length
            change_indices = randsample(diff_indices, num_changes);  % select random indices to swap
            i_districts(change_indices) = j_memory_districts(change_indices);
            %check that new solution is still contiguous
            if Check_District_Contiguity(C, i_districts, K) == true
                y(i,:) = Districts_To_Indicators(i_districts, centers);
            end
        else
            % Random search
            random_districts = Assign_Districts(C, centers);
            y(i, :) = Districts_To_Indicators(random_districts, centers);
        end
        
        % Evaluate new position
        new_fitness = CSO_OF(y(i, :), D, P, VP, APBVP, r);        
        % Update memory and current position
        if new_fitness < fitness(i)
            memory(i, :) = y(i, :);
            fitness(i) = new_fitness;
            if new_fitness < best_fitness
                best_fitness = new_fitness;
                best_position = memory(i, :);
            end
        end
    end
end

fprintf('Best fitness achieved: %f\n', best_fitness);
% Best position gives the district assignment of each parish

best_position = Indicators_To_Districts(best_position, 64, 6);


%%

% Initialize a cell array for districts
districts = cell(K, 2);

% Names of the districts as strings
districtNames = {'District 1', 'District 2', 'District 3', 'District 4', 'District 5', 'District 6'};

% Fill the districts cell array with district names
for i = 1:K
    districts{i, 1} = districtNames{i};
end

% Loop over each parish
for i = 1:length(best_position)
    districtIndex = best_position(i);
    parishName = parishNames{i};

    % Check if the parish list for the current district has been started
    if isempty(districts{districtIndex, 2})
        districts{districtIndex, 2} = {parishName};
    else
        districts{districtIndex, 2} = [districts{districtIndex, 2}, parishName];
    end
end


% Initialize table for results
results = table;
results.District = cell(length(districts), 1);
results.TotalPopulation = zeros(length(districts), 1);
results.VotingAgePopulation = zeros(length(districts), 1);
results.BlackVotingAgePopulation = zeros(length(districts), 1);
results.ProportionOfStatePopulation = zeros(length(districts), 1);
results.ProportionBlackVAP = zeros(length(districts), 1);

% Calculate total state population
totalStatePopulation = sum(data.TotalPopulation);

% Calculate sums for each district
for i = 1:length(districts)
    districtName = districts{i, 1};
    parishes = districts{i, 2};
    
    % Find indices of parishes in this district
    idx = ismember(data.('ParishName'), parishes);
    
    % Sum the data for these indices
    totalPopulation = sum(data.TotalPopulation(idx));
    votingAgePopulation = sum(data.VotingAgePopulation(idx));
    blackVotingAgePopulation = sum(data.BlackVotingAgePopulation(idx));
    
    % Store results
    results.District{i} = districtName;
    results.TotalPopulation(i) = totalPopulation;
    results.VotingAgePopulation(i) = votingAgePopulation;
    results.BlackVotingAgePopulation(i) = blackVotingAgePopulation;
    results.ProportionOfStatePopulation(i) = totalPopulation / totalStatePopulation;
    results.ProportionBlackVAP(i) = blackVotingAgePopulation / votingAgePopulation;
end

% Format the display of results
disp('District Population Summary:')
fprintf('%-15s %-20s %-25s %-30s %-25s %-25s\n', 'District', 'Total Population', 'Voting Age Population', 'Black Voting Age Population', 'Proportion of State', 'Proportion Black VAP');
for i = 1:height(results)
    fprintf('%-15s %-20d %-25d %-30d %-25.2f %-25.2f\n', results.District{i}, results.TotalPopulation(i), results.VotingAgePopulation(i), results.BlackVotingAgePopulation(i), results.ProportionOfStatePopulation(i) * 100, results.ProportionBlackVAP(i) * 100);
end



for k = 1:K
    % Find nodes in the current district
    nodesInDistrict = find(best_position == k);
    parishNamesInDistrict = parishNames(nodesInDistrict);

    subG = subgraph(G, nodesInDistrict);

    % Plot the graph with labels
    figure;
    plot(subG, 'NodeLabel', parishNamesInDistrict);
    title('Subgraph Representation of Louisiana District at Best Position');

end