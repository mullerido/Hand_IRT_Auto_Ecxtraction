%% Resize feature to have same number of time stamps

load('C:\Projects\Hand_IRT_Auto_Ecxtraction\Feature-Analysis- matlab\featureDataFile.mat')

[allDT , timeFactor, updateAllDts]= deal([]);
maxTime = 20*60;

for ind=1:size(allFeatureMat,3)
    allDT = [allDT, allFeatureMat(:,3,ind)];
    timeFactor =[timeFactor, maxTime/max(allFeatureMat(:,3,ind))];
    updateAllDts = [updateAllDts, allFeatureMat(:,3,ind)*timeFactor(end)];
end

s=[];
for ind=1:size(allDT,2)
    s=[s, sum(~isnan(allDT(:,ind)))];
end


numFrames = min(s);
dframe = 20*60/numFrames;%(20 minutes * 60 seconds)/ min number of frames
reSizeFeature = nan(numFrames, size(allFeatureMat,2), size(allFeatureMat,3));

%% Resample using time scaling to 20 min
for sInd = 1: size(allFeatureMat,3)
    current_s_id = correspondedId{sInd};
    current_hand = correspondedHandSide{sInd};
    sprintf('%s - %s', current_s_id, current_hand)%sInd
    currentFeatures_original = allFeatureMat(:,:,sInd);
    
    aveData = movmean(currentFeatures_original,3);
    aveData(:,1:3) = currentFeatures_original(:,1:3);
    
    currentdTs = updateAllDts(:,sInd);
    currentFactor = timeFactor(sInd);
    updateDFrame = dframe*currentFactor;
    dAllFrames = 0:dframe:20*60;
    currentAlldTs=dAllFrames;
    currentFeatures = nan(numFrames, size(allFeatureMat,2));
    for iDT = 1:numFrames
        %iDT
        relevantDT = dAllFrames(iDT);
        
        relevantInd = find(currentdTs>=relevantDT, 1, 'first');
        if ~isempty(relevantInd)
            try
                currentFeatures(iDT,:) = allFeatureMat(relevantInd,:,sInd);
%                 currentFeatures(iDT,:) = aveData(relevantInd,:);
            catch
                x=1;
            end
            currentAlldTs(1:relevantInd)=nan;
        end
    end
    if any(isnan(currentFeatures(:)))
        x=1;
    end
    reSizeFeature(:,:,sInd) = currentFeatures;
    
    featureTable =  array2table(currentFeatures, 'VariableNames', variableNames);
    dashId = strfind(current_s_id,'_');
    sName = [current_s_id(1:dashId(2)) current_hand];
%     if strfind(sName,'s_19')
%         x=1;
%     end
    filesName = ['C:\Users\IdoMuller\OneDrive - DreaMed, Ltd\Desktop\Temp\JPG Resize Feature Tables\' sName '.xlsx'];
    try
        writetable(featureTable, filesName);
    catch
        x=1;
    end
    clear featureTable currentFeatures
end

%% Simple resample with same timing

for sInd = 1: size(allFeatureMat,3)
    
    dAllFrames = 0:dframe:20*60;
    currentFeatures = allFeatureMat(:,:,sInd);
    currentAlldTs = allDT(:,sInd);
    
    currentFeatures = nan(numFrames, size(allFeatureMat,2));
    for iDT = 1:numFrames
        relevantDT = dAllFrames(iDT);
        
        relevantInd = find(currentAlldTs>=relevantDT, 1, 'first');
        if ~isempty(relevantInd)
            try
                currentFeatures(iDT,:) = allFeatureMat(relevantInd,:,sInd);
            catch
                x=1;
            end
            currentAlldTs(1:relevantInd)=nan;
        end
    end
    if any(isnan(currentFeatures(:)))
        x=1;
    end
    reSizeFeature(:,:,sInd) = currentFeatures;
end