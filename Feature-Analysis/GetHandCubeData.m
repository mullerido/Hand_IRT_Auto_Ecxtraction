function [handCubeData, names] = GetHandCubeData(allFeatures, normaFlag, hand, smoothFlag)

mainFolde = 'C:\Projects\Hand_IRT_Auto_Ecxtraction\Feature-Analysis- matlab\Resize Feature\';
allFiles = struct2cell(dir(mainFolde))';
allFiles(1:2,:)=[];
xS = size(allFiles,1);
if strcmp(hand, 'right') ||  strcmp(hand, 'left') 
    xS = floor(xS/2);        
end
yS = length(allFeatures);
zS = 39;%19;
handCubeData = nan(xS, yS, zS);
names = cell(xS,1);
% for the moving average
windowSize = 5; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
pInd = 1;
for fileInd = 1: size(allFiles,1)
    
    currentFile = allFiles{fileInd,1};
    if strcmp(hand, 'right') && any(strfind(currentFile, 'right')) ||...
            strcmp(hand, 'left') && any(strfind(currentFile, 'left')) ||...
            strcmp(hand, 'both')
        
        [data,~,cellData] = xlsread([mainFolde currentFile]);
        
        relevantCols=[];
        for currentFeature = allFeatures
            col = cellfun(@(x) strcmp(x,currentFeature{:}), cellData(1,:));
            if sum(col)==1
                relevantCols = [relevantCols; find(col)];
            else
                x=1;
            end
        end
        
        temprelevantData = data(1:zS,relevantCols);
        relevantData = zeros(size(temprelevantData));
        if smoothFlag
            for r_i =1:size(relevantData,1)
                relevantIndsToSmooth = [max(1, r_i-floor(windowSize/2)):...
                    min(size(relevantData,1), r_i+floor(windowSize/2))];
                relevantData(r_i,:) = mean(temprelevantData(relevantIndsToSmooth,:), 1);
            end
            
            %for r_i =1:size(relevantData,2)
             %   relevantData(2:end,r_i ) = conv(relevantData(2:end, r_i),b);
            %end
        end
        
        if normaFlag
            relevantData = (relevantData(:,:) - relevantData(1,:))./...
                relevantData(1,:);
        end
        
        
        for t = 1:zS
            handCubeData (pInd, :,t) = relevantData(t, :)';
        end
        names{pInd,1} =  currentFile(1:end-5);
        pInd = pInd +1;
    end
    
end