function [palmProps, palmElipse, plamBox]= ExtractPalmFeatures (palmBW, plotFlag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function extract the palm ROI and its properties
%
% Written by Ido Muller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

palmCC = bwconncomp(palmBW);
palmProps = regionprops(palmCC,'Area');
palmAreas = cat(1,palmProps.Area);

%keep only largest blob if more then 1 have been retained 
if size(palmAreas,1) > 1
    [removeThresh] = max(palmAreas);
    removeThresh = removeThresh - 1;
    palmBW = bwareaopen(palmBW,removeThresh);
end

%Extract Centroid
palmProps = regionprops(palmBW,'centroid', 'MinorAxisLength',...
    'MajorAxisLength', 'Perimeter', 'Orientation');

[plamBox, palmElipse] = ExtractPalmROI(palmBW, palmProps, plotFlag);