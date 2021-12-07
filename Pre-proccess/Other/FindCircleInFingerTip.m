function tipCircle = FindCircleInFingerTip (imageEdges, rowCenter, colCenter)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use to find a circle in bwtween edges, given center points.
%
% Written by Ido Muller
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x = imageEdges(:, 2);
y = imageEdges(:, 1);
    
% Get distances from center to each of the edge pixels.
distances = sqrt((x - colCenter).^2 + (y - rowCenter).^2);
% Find the min distance.
[minDistance] = min(distances);
% Find x and y of the min
% xMin = x(indexOfMin);
% yMin = y(indexOfMin);

tipCircle=[colCenter,rowCenter, floor(minDistance)-1];