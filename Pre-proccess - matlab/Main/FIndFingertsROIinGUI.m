function FIndFingertsROIinGUI (fingerName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This open an image and allow the user to press on the image to sign the
% center of the finger ROI on the image. The function will use this
% information to create the best circle inside the finger ans use this
% region as ROI.
%
% Written by Ido Muller
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure (20);
global imageProccess
fingersBW = imageProccess.fingers.BW;
handSide = imageProccess.handSide;
imshow(imageProccess.fingers.BW);hold on
titleTxt = sprintf('Choose ROI in %s', fingerName);
title(titleTxt);

if ~isfield(imageProccess,'fingers') || ~isfield(imageProccess.fingers,'props')
    %% Extract Centroid
    % New section that need to be completed- find fingers ROIS
    
    tempFingersProps = regionprops(fingersBW,'centroid','PixelList','Area',...
        'Circularity', 'SubarrayIdx', 'Orientation', 'MinorAxisLength', 'MajorAxisLength');
    
    
    %% Find fingers ROI by the 5 highest areas in fingers image
    fingersPropsTable = struct2table(tempFingersProps);
    fingersArea = fingersPropsTable.Area;
    [~, highestInds] = sort(fingersArea, 'descend');
    fingersProps = fingersPropsTable(highestInds(1:5),:);
    
    fingersCentroid = fingersProps.Centroid;
    fingersCentroid = round(fingersCentroid);
    colCenter = fingersCentroid(:,1);
    rowCenter = fingersCentroid(:,2);
    imageSize = size(fingersBW);
    
    fingerNames = {'Thumbs', 'Index', 'Middle', 'Ring', 'Pinky'};
    if strcmp(handSide, 'left')
        [~, fingerPositionInds] = sort(colCenter, 'descend');
        fingersProps.fingerNames(fingerPositionInds)= fingerNames';
    else
        [~, fingerPositionInds] = sort(colCenter, 'ascend');
        fingersProps.fingerNames(fingerPositionInds)= fingerNames';
    end
    imageProccess.fingers.props = fingersProps;
end

if ~isfield(imageProccess.fingers,'fingersBase')
    imageProccess.fingers.fingersBase = zeros(5,3);
end
   
if ~isfield(imageProccess.fingers,'fingersTips') 
    imageProccess.fingers.fingersTips = zeros(5,3);
end

if ~isfield(imageProccess,'fingers') || ~isfield(imageProccess.fingers,'Boundary')||...
        isempty(imageProccess.fingers.Boundary.x)
    fingerBoundary = bwboundaries(imageProccess.fingers.BW);
    imageProccess.fingers.Boundary.x=[];
    imageProccess.fingers.Boundary.y=[];
    for ind = 1:size(fingerBoundary,1)
        b = fingerBoundary{ind}; % Extract from cell.
        imageProccess.fingers.Boundary.x = [imageProccess.fingers.Boundary.x; b(:, 2)];
        imageProccess.fingers.Boundary.y = [imageProccess.fingers.Boundary.y; b(:, 1)];
    end
end

[Userx,Usery] = ginput(1);
% Get distances from center to each of the edge pixels.
distances = sqrt((imageProccess.fingers.Boundary.x - Userx).^2 +...
    (imageProccess.fingers.Boundary.y - Usery).^2);
% Find the min distance.
[minDistance, indexOfMin] = min(distances);

fingersROI=[Userx, Usery, floor(minDistance)-3];
ang=0:0.01:2*pi;
xp=fingersROI(3)*cos(ang);
yp=fingersROI(3)*sin(ang);
plot(fingersROI(1)+xp,fingersROI(2)+yp);%,'Parent',handles.FingersAxes);

currentFingerInd = cellfun(@(x) ~isempty(strfind(x, fingerName(1:1:4))), imageProccess.fingers.props.fingerNames);
switch fingerName
    case{'ThumbsProx'}
        imageProccess.fingers.fingersBase(currentFingerInd,:) = fingersROI;
    case{'ThumbsDist'}
        imageProccess.fingers.fingersTips(currentFingerInd,:) = fingersROI;
    case{'IndexProx'}
        imageProccess.fingers.fingersBase(currentFingerInd,:) = fingersROI;
    case{'IndexDist'}
        imageProccess.fingers.fingersTips(currentFingerInd,:) = fingersROI;
    case{'MiddleProx'}
        imageProccess.fingers.fingersBase(currentFingerInd,:) = fingersROI;
    case{'MiddleDist'}
        imageProccess.fingers.fingersTips(currentFingerInd,:) = fingersROI;
    case{'RingProx'}
        imageProccess.fingers.fingersBase(currentFingerInd,:) = fingersROI;
    case{'RingDist'}
        imageProccess.fingers.fingersTips(currentFingerInd,:) = fingersROI;
    case{'PinkyProx'}
        imageProccess.fingers.fingersBase(currentFingerInd,:) = fingersROI;
    case{'PinkyDist'}
        imageProccess.fingers.fingersTips(currentFingerInd,:) = fingersROI;
end

close(20)
