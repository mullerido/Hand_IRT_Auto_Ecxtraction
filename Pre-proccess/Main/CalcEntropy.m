function H = CalcEntropy(vec)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Use to calculate the entropy inside a vector of data.
 %
 % Written by Ido Muller
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uniqueVal = unique(vec);
% Create bin vector- add 1 to count the last value in vec
uniquValBins = [uniqueVal; uniqueVal(end)+1];


P=histcounts(vec ,uniquValBins);
P = P ./ numel(vec);

% Compute the Shannon's Entropy
H = -sum(P .* log2(P)); % 1.5