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

