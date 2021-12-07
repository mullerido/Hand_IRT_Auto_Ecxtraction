function [intens, entropy, kurtos, skewne, histogram] = GetImageFeatures(data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to get the relevant fetures for certain data (ROI):
%
%   1) Histogram
%   2) Average intence
%   3) Enropy
%   4) Kurtosis
%   5) Skewness
%
% Written by Ido Muller
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bins=100:10:250;

% Histogram
histogram = histcounts(data, bins);

% Intense
intens = mean(data);

% Entropy
entropy = CalcEntropy(data);

% Kurtosis
kurtos = kurtosis(data);

% Skewness
skewne = skewness(data);

