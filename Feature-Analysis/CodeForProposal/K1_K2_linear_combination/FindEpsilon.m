
% This is the huristics I use to find epsilon (see this paper: Heterogeneous Datasets Representation and Learning using Diffusion Maps and Laplacian Pyramids.N Rabin, RR Coifman, SDM, 189-199)

% For input send:  dist = squareform(pdist(YourInputData));
% For other metrics:   dist = squareform(pdist(YourInputData, 'cosine'));



  function epsilon = FindEpsilon( dist)
  
  [ bands, xSize] = size( dist);
  
  mins = min(dist + eye(xSize) * max(dist(:)));
  
  epsilon   = max(mins);


%  You can change this to be:   
%   epsilon   = mean(mins)
%   epsilon = median(mins) * 2;

% anoterh option:   epsilon = median(dist(:)) / 2;

