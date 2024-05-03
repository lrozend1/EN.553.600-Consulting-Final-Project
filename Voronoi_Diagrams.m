% Load and display the map of Louisiana
figure;
ax = usamap('Louisiana');
states = readgeotable("BNDY_DOTD_ParishBoundaries.shp");
geoshow(ax, states, 'DisplayType', 'polygon', 'FaceColor', [1 1 1])

% Define seed points in geographic coordinates (latitude, longitude)
seeds = [
    32.5806,	-93.8823; %Caddo
    30.2293,	-93.3581; %Calcasieu
    31.1986,	-92.5332; %Rapides
    30.5383,	-91.0956; %East Baton Rouge
    29.7882,	-90.1276; %Jefferson
    30.0687,	-89.9289; %Orleans
];



% Convert geographic coordinates to map coordinates
[x, y] = mfwdtran(seeds(:,1), seeds(:,2));

% Generate and plot Voronoi diagram
hold on;
[vx, vy] = voronoi(x, y);
plot(vx, vy, 'k-');

% Enhance display
title('Voronoi Diagram Overlaid on Map of Louisiana');
xlabel('Longitude');
ylabel('Latitude');
hold off;

%% Get the district data for the districts created from the Voronoi diagrams

% Load data from CSV file
data = readtable('Louisiana County All Data.csv');



% Define districts
districts = {
    'District 1', {'De Soto', 'Red River', 'Caddo', 'Bossier', 'Webster', 'Bienville', 'Claiborne', 'Lincoln', 'Union'};
    'District 2', {'Sabine', 'Vernon', 'Allen', 'Evangeline', 'St. Landry', 'Avoyelles', 'Rapides', 'Natchitoches', 'Grant', 'Winn', 'La Salle', 'Catahoula', 'Concordia', 'Caldwell', 'Jackson', 'Ouachita', 'Richland', 'Franklin', 'Tenses', 'Madison', 'East Carroll', 'West Carroll', 'Morehouse'};
    'District 3', {'Beauregard', 'Calcasieu', 'Jefferson Davis', 'Acadia', 'Cameron', 'Vermilion'};
    'District 4', {'West Feliciana', 'East Feliciana', 'St. Helena', 'Tangipahoa', 'Pointe Coupee', 'West Baton Rouge', 'East Baton Rouge', 'Livingston', 'Ascension', 'St James', 'Iberville', 'Assumption', 'St Martin', 'Iberia', 'St Mary', 'Lafayette'};
    'District 5', {'Washington', 'St. Tammany', 'Orleans', 'St. Bernard'};
    'District 6', {'St. John the Baptist', 'St. Charles', 'Jefferson', 'Lafourche', 'Plaquemines', 'Terrebonne'}
};

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