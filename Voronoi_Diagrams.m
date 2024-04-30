% Load and display the map of Louisiana
figure;
ax = usamap('Louisiana');
states = readgeotable("BNDY_DOTD_ParishBoundaries.shp");
geoshow(ax, states, 'DisplayType', 'polygon', 'FaceColor', [0.5 1 0.5])

% Define seed points in geographic coordinates (latitude, longitude)
seeds = [
    30.9843, -91.9623;  % Baton Rouge
    29.9511, -90.0715;  % New Orleans
    32.5252, -93.7502;  % Shreveport
    30.2241, -92.0198;  % Lafayette
    30.2131, -93.2044;  % Lake Charles
    32.5093, -92.1193;  % Monroe
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

