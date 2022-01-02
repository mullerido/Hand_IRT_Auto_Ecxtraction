clear all
if false
    %% Analyze temp at t0 or between t_gravity-t0 in relate to the characteristics

    clear all
    savepath = 'G:\My Drive\Thesis\Project\Results\Charectarisitcs analysis\Vs Gravity to BaseLine\';%Vs BaseLine\';%
    filesPath='C:\Projects\Hand_IRT_Auto_Ecxtraction\Feature-Analysis\featureDataFile.mat';%JPGfeatureDataFile.mat';
    load(filesPath);
    type='grav2Base';  % 'BaseLine';%Or 
    chaPat='G:\My Drive\Thesis\Data\Characteristics.xlsx';
    characteristicTable = readtable(chaPat);

    analyzedCharectTitle = {'SBP', 'DBP'};%{'Gender_Annova', 'Age', 'High', 'Weight','BMI','Is_smoking_Annova',...
        %'Phys_Act_Freq_Annova','Phys_Act_Intence_Annova', 'Pulse_Presure'};
    
    nameOfCharactaristic = {'SBP', 'DBP'};%{'Gender_m_0_F_1_', 'Age', 'High_cm_','Weight_kg_','BMI', 'Is_smoking_', ...
       %'PhysicalActivity_frequency_0_0_1_2_1_2_3_2_3AndUp_3', 'Physical_activity_intensit_light_0_Mild_1Intens_2_','PP'};
    currentAnalysis = 'intence';
    allCurrentAnaInds = cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(lower(x), currentAnalysis), variableNames,'UniformOutput',false));

    allROIs = variableNames(allCurrentAnaInds);
    leftMat(1:size(characteristicTable,1), 1:2, 1:size(allROIs,2)) = nan;
    rightMat=leftMat;%[rows = patient #
    % cols = 1- char Val,   2- data from image
    % Depth - ROI]

    %% Collect the data
    for charInd = 1:length(analyzedCharectTitle)
        curCharTitle = analyzedCharectTitle{charInd};
        curChageName = nameOfCharactaristic{charInd};
        if strcmp(type, 'grav2Base')
            for paInd = 1:size(characteristicTable,1)
                currentId = characteristicTable.Ext_name_fix{paInd};
                leftMat(paInd,1,:) = characteristicTable.(curChageName)(paInd); % Change struct field according to the analyzedCarect
                rightMat(paInd,1,:)= characteristicTable.(curChageName)(paInd);% Change struct field according to the analyzedCarect
                matchInd = find(cellfun(@(x) strcmp(x, currentId), correspondedId));

                if ~isempty(matchInd)
                    for ind =matchInd'
                        currentHand = correspondedHandSide{ind};

                        if strcmp(currentHand,'left')

                            for ROIind = 1:size(allROIs,2)

                                dataId = find(cellfun(@(x) x==1, cellfun(@(x) strcmpi(lower(x), allROIs{ROIind}), variableNames,'UniformOutput',false)));
                                BaseLine = allFeatureMat(1,dataId,ind);
                                endGrav = allFeatureMat(find(allFeatureMat(:,1,ind)==2,1,'first')-1, dataId,ind);
                                leftMat(paInd, 2, ROIind) = endGrav-BaseLine;

                            end

                        elseif strcmp(currentHand,'right')
                            for ROIind = 1:size(allROIs,2)

                                dataId = find(cellfun(@(x) x==1, cellfun(@(x) strcmpi(lower(x), allROIs{ROIind}), variableNames,'UniformOutput',false)));
                                BaseLine = allFeatureMat(1,dataId,ind);
                                endGrav = allFeatureMat(find(allFeatureMat(:,1,ind)==2,1,'first')-1, dataId,ind);
                                rightMat(paInd, 2, ROIind) = endGrav-BaseLine;

                            end

                        else
                            error('Error with hand side');
                        end


                    end

                end

            end
            % Compare with BaseLine
        else%if strcmp(type,'BaseLine')
            for paInd = 1:size(characteristicTable,1)
                currentId = characteristicTable.Ext_name_fix{paInd};
                leftMat(paInd,1,:) = characteristicTable.(curChageName)(paInd); % Change struct field according to the analyzedCarect
                rightMat(paInd,1,:)= characteristicTable.(curChageName)(paInd);% Change struct field according to the analyzedCarect
                matchInd = find(cellfun(@(x) strcmp(x, currentId), correspondedId));

                if ~isempty(matchInd)
                    for ind =matchInd'
                        currentHand = correspondedHandSide{ind};

                        if strcmp(currentHand,'left')

                            for ROIind = 1:size(allROIs,2)

                                dataId = find(cellfun(@(x) x==1, cellfun(@(x) strcmpi(lower(x), allROIs{ROIind}), variableNames,'UniformOutput',false)));
                                leftMat(paInd, 2, ROIind) = allFeatureMat(1,dataId,ind);

                            end

                        elseif strcmp(currentHand,'right')
                            for ROIind = 1:size(allROIs,2)

                                dataId = find(cellfun(@(x) x==1, cellfun(@(x) strcmpi(lower(x), allROIs{ROIind}), variableNames,'UniformOutput',false)));
                                rightMat(paInd, 2, ROIind) = allFeatureMat(1,dataId,ind);

                            end

                        else
                            error('Error with hand side');
                        end


                    end

                end

            end

        end
        %% Plot the data
        if strfind(curCharTitle, 'Annova')
            for ROIind = 1:size(allROIs,2)
                %% Left Hand
                titleTxt = ['Left Hand : ' curCharTitle ' Vs. ' allROIs{ROIind}];
                [a,b,stats]=anova1(leftMat(:,2,ROIind), leftMat(:,1,ROIind));
                [c,~,~,gnames] = multcompare(stats);
                

                compTable = array2table(c(:,[1,2,6]), 'VariableName', {'group 1','group 2', 'p_value'});
                close all
                L_Fig = figure(1);
                axes('position',[.1,.4,.8,.5])
                boxplot(leftMat(:,2,ROIind), leftMat(:,1,ROIind));
                ylabel(currentAnalysis);
                txtBox = sprintf('%s',titleTxt);
                title(txtBox, 'Interpreter', 'none');
                
                % Convert Table to cell to char array
                tableCell = [compTable.Properties.VariableNames; table2cell(compTable)];
                tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
                tableChar = splitapply(@strjoin,pad(tableCell),[1:size(tableCell,1)]');
                % Add axes (not visible) & text (use a fixed width font)
                axes('position',[.1,.15,.8,.2], 'Visible','off');
                text(.2,.95,tableChar,'VerticalAlignment','Top','HorizontalAlignment','Left','FontName','Consolas', 'Interpreter', 'none');
                if any(c(:,6)<0.05)
                    
                    saveas(L_Fig, [savepath 'Left\Significant\' curCharTitle ' _Vs_ ' allROIs{ROIind} '.png']);
                else
                    saveas(L_Fig, [savepath 'Left\' curCharTitle ' _Vs_ ' allROIs{ROIind} '.png']);
                    
                end
                close all
                %% Right Hand
                titleTxt = ['Right Hand : ' curCharTitle ' Vs. ' allROIs{ROIind}];
                [a,b,stats]=anova1(rightMat(:,2,ROIind), rightMat(:,1,ROIind));
                [c,~,~,gnames] = multcompare(stats);
                
                compTable = array2table(c(:,[1,2,6]), 'VariableName', {'group 1','group 2', 'p_value'});
                close all
                L_Fig = figure(1);
                axes('position',[.1,.4,.8,.5])
                boxplot(rightMat(:,2,ROIind), rightMat(:,1,ROIind));
                ylabel(currentAnalysis);
                txtBox = sprintf('%s',titleTxt);
                title(txtBox, 'Interpreter', 'none');
                
                % Convert Table to cell to char array
                tableCell = [compTable.Properties.VariableNames; table2cell(compTable)];
                tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
                tableChar = splitapply(@strjoin,pad(tableCell),[1:size(tableCell,1)]');
                % Add axes (not visible) & text (use a fixed width font)
                axes('position',[.1,.15,.8,.2], 'Visible','off');
                text(.2,.95,tableChar,'VerticalAlignment','Top','HorizontalAlignment','Left','FontName','Consolas', 'Interpreter', 'none');
                if any(c(:,6)<0.05)
                    saveas(L_Fig, [savepath 'Right\Significant\' curCharTitle ' _Vs_ ' allROIs{ROIind} '.png']);
                else
                    saveas(L_Fig, [savepath 'Right\' curCharTitle ' _Vs_ ' allROIs{ROIind} '.png']);
                end
                close all
            end
        else
            for ROIind = 1:size(allROIs,2)
                %% Left Hand
                L_Fig = figure(1);
                titleTxt = ['Left Hand : ' curCharTitle ' Vs. ' allROIs{ROIind}];

                plot(leftMat(:,1,ROIind), leftMat(:,2,ROIind), 'o', 'color', [0 0.4470 0.7410],...
                    'MarkerSize', 10);
                mdl = fitlm(leftMat(:,1,ROIind),leftMat(:,2,ROIind));
                
                
                txtBox = sprintf('%s\nR^2= %0.2f,                   R^2 Adjusted= %0.02f\nMSE= %0.02f,                         \tP-val= %0.02f',...
                    titleTxt,mdl.Rsquared.Ordinary, mdl.Rsquared.Adjusted, mdl.MSE, mdl.Coefficients.pValue(2));
                %      annotation('textbox',[0.75, 0.8,0.1,0.1],'String', txtBox );
                title(txtBox, 'Interpreter', 'none');
                xlabel(curCharTitle, 'Interpreter', 'none');
                ylabel(currentAnalysis, 'Interpreter', 'none');
                if mdl.Coefficients.pValue(2)<0.05
                    saveas(L_Fig, [savepath 'Left\Significant\' curCharTitle ' _Vs_ ' allROIs{ROIind} '.png']);
                else
                    saveas(L_Fig, [savepath 'Left\' curCharTitle ' _Vs_ ' allROIs{ROIind} '.png']);
                end
                close all
                %% Right Hand
                R_Fig = figure(2);
                titleTxt = ['Right Hand : ' curCharTitle ' Vs. ' allROIs{ROIind}];
                mdl = fitlm(rightMat(:,1,ROIind),rightMat(:,2,ROIind));
                
                txtBox = sprintf('%s\nR^2= %0.2f,                   R^2 Adjusted= %0.02f\nMSE= %0.02f,                         \tP-val= %0.02f',...
                    titleTxt,mdl.Rsquared.Ordinary, mdl.Rsquared.Adjusted, mdl.MSE, mdl.Coefficients.pValue(2));
                plot(rightMat(:,1,ROIind), rightMat(:,2,ROIind), 'o', 'color', [0 0.4470 0.7410],...
                    'MarkerSize', 10);
                title(txtBox, 'Interpreter', 'none');
                xlabel(curCharTitle, 'Interpreter', 'none');
                ylabel(currentAnalysis, 'Interpreter', 'none');
                if mdl.Coefficients.pValue(2)<0.05
                    saveas( R_Fig, [savepath 'Right\Significant\' curCharTitle '_Vs_ ' allROIs{ROIind} '.png']);
                else
                    saveas( R_Fig, [savepath 'Right\' curCharTitle '_Vs_ ' allROIs{ROIind} '.png']);
                end
                close all

            end
        end
    end
else
    %% Analyze the labels in relate to the characteristics
    
    clear all
    savepath = 'G:\My Drive\Thesis\Project\Results\Heat progression analysis\Fingers dists to palm center- using ratio\';
    filesPath='C:\Projects\Hand_IRT_Auto_Ecxtraction\Feature-Analysis\featureDataFile.mat';
    load(filesPath);
    label_path='G:\My Drive\Thesis\Project\Results\Heat progression analysis\Fingers dists to palm center- using ratio\label.xlsx';%'G:\My Drive\Thesis\Project\Results\Manual labeling\labeling- gravity phase- fingers only.xlsx';%'G:\My Drive\Thesis\Data\Labels_all.xlsx';
    char_path = 'G:\My Drive\Thesis\Data\Characteristics.xlsx';
    
    label_table = readtable(label_path);
    characteristicTable = readtable(char_path);

    % Find subject that are found in label but not in the characteristic table
    s_out = [];
    labels = {'0'; '1';'2'};%{'Negative'; 'Stable'; 'Positive'};
    characteristicTable.Group = cell(size(characteristicTable,1),1);
    for s_ind =1: size(characteristicTable,1)
        current_name = characteristicTable.Ext_name_fix{s_ind,1};
        ind_in = find(cell2mat(cellfun(@(x) ~isempty(x), ...
            cellfun(@(x) strfind(x, current_name(1:4)) ,...
            table2cell(label_table(:,1)), 'UniformOutput', false),'UniformOutput',false)));
        if ~isempty(ind_in)
            characteristicTable.Group(s_ind) = labels(label_table{ind_in,'label'}+1);
        else
            % Remove subject that found characteristics table but not in
            % labels table
            s_out = [s_out; s_ind];
        end

    end
    
    characteristicTable(s_out, :)=[];

    %label_table_cat = double(categorical(label_table.label));
    
    label_table_cat = characteristicTable.Group;
    characteristicMat_cat = [characteristicTable.Gender_m_0_F_1_, characteristicTable.Is_smoking_,...
        characteristicTable.Is_formerSmoker_ ,...
        characteristicTable.PhysicalActivity_frequency_0_0_1_2_1_2_3_2_3AndUp_3 ,...
        characteristicTable.Physical_activity_intensit_light_0_Mild_1Intens_2_];
    characteristicMat_cat = double(categorical(characteristicMat_cat));
    nameOfCat = {'Gender', 'Is_smoking', 'Is_formerSmoker', 'Activ_freq', 'Activ_intens'};
    characteristicMat_cont = [characteristicTable.Age,...
        characteristicTable.High_cm_,...
        characteristicTable.Weight_kg_ ,characteristicTable.BMI, characteristicTable.PP,...
        characteristicTable.SBP, characteristicTable.DBP];
    nameOfNum = {'Age', 'High', 'Weight', 'BMI' 'PP', 'SBP', 'DBP'};
    y_label = {'Years', 'cm', 'kg', 'BMI', 'pp', 'SBP', 'DBP'};
    
    % numeric Annova comparison
    for n_i =1 : length(nameOfNum)
        
        titleTxt = [nameOfNum{n_i} ' Vs. Label' ];
        try
        [a,~,stats]=anova1(characteristicMat_cont(:,n_i), label_table_cat);
        
        [c,m,h,gnames] = multcompare(stats);
        %convert number label to label str
        c_label_txt = cell(length(labels),3);
        for c_ind = 1:size(c,1)

             c_label_txt{c_ind,1} = gnames{c(c_ind,1)};
             c_label_txt{c_ind,2} = gnames{c(c_ind,2)};
             c_label_txt{c_ind,3} = c(c_ind,6);
        end

        compTable = array2table(c_label_txt, 'VariableName', {'group 1','group 2', 'p_value'});
        close all
        L_Fig = figure(3);
        axes('position',[.1,.4,.8,.5])
        boxplot(characteristicMat_cont(:,n_i), label_table_cat, 'labels', gnames');
        ylabel(y_label{n_i});
        txtBox = sprintf('%s',titleTxt);
        title(txtBox, 'Interpreter', 'none');
        y_lim = get(gca, 'ylim');
        ylim([y_lim(1), y_lim(2)*1.2])
        catch
            x=1;
        end
        % plot N as text above the box plot
        for b = 1: length(labels)
            text(b-0.05, y_lim(2)*1.1, sprintf('N= %d',sum(cellfun(@(x) strcmp(x, gnames{b}), label_table_cat))));
        end
     
        % Convert Table to cell to char array
        tableCell = [compTable.Properties.VariableNames; table2cell(compTable)];
        tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
        tableChar = splitapply(@strjoin,pad(tableCell),[1:size(tableCell,1)]');
        % Add axes (not visible) & text (use a fixed width font)
        axes('position',[.1,.15,.8,.2], 'Visible','off');
        text(.2,.95,tableChar,'VerticalAlignment','Top','HorizontalAlignment','Left','FontName','Consolas', 'Interpreter', 'none');
        
        saveas(L_Fig, [savepath nameOfNum{n_i} ' _Vs_Label.png']);
        close all
        
    end
    
    % categorical Annova comparison
    
    %taken from chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/viewer.html?pdfurl=http%3A%2F%2Fhomepage.stat.uiowa.edu%2F~rdecook%2Fstat1010%2Fnotes%2FSection_10.2_two-way_tables.pdf&clen=691972&chunk=true
    chi_square_critical_val_mat = [4, 3.841;...%col 1- freedom lavel col 2 is the critical value for that freedom level for apha of 0.05
        6, 5.991;...
        8, 7.815;...
        9, 9.488;...
        10, 9.488]; 
    
    for n_i = 1: length(nameOfCat)
        titleTxt = [nameOfCat{n_i} ' Vs. Label' ];
        cat_names = {};
        num_cat = max(characteristicMat_cat(:, n_i));
        [cat_names{1:num_cat}] = deal(nameOfCat{n_i});
        for name_i = 1: num_cat
            cat_names{name_i} = [cat_names{name_i} '_' num2str(name_i)];
        end
        
        cat_names{name_i+1} = 'total';
        label_names = labels;
        label_names = [label_names; 'total'];
        try
            catMat = array2table(zeros(num_cat+1, size(label_names,1)), 'RowNames', cat_names,...
            'VariableNames',label_names);
        catch
            error('Line 335: problem creating catMat table');
        end
        catPerMat = catMat;
        expected_frequet = catMat;
        expected_num = catMat;
        % create the expected frequencies
        
        % create the observed frequency
        for l = labels'
            for c = 1: num_cat
                catMat{c, l} = sum(characteristicMat_cat(cell2mat(cellfun(@(x) strcmp(x, l{:}), label_table_cat, 'UniformOutput', false)), n_i) == c);
                
            end
            try
            catPerMat{:, l} = catMat{:, l}./sum(catMat{:,l});
            catch
                x=1;
            end
            catMat{c+1, l} = sum(catMat{:, l});
            catPerMat{c+1, l} = sum(catPerMat{:, l});
        end
        catMat{:, size(labels,1)+1} = sum(catMat{:,:},2);
        
        for l = 1:3
            for c = 1: num_cat
                expected_frequet{c, end} = catMat{c, end}/catMat{end, end};
                expected_frequet{end, l} = catMat{end, l}/catMat{end, end};
                expected_frequet{c, l} = expected_frequet{c, end} *...
                    expected_frequet{end, l};
                expected_num{c, l} =  (expected_frequet{c, l} *catMat{end,end});
            end
        end
        
        %Calculating Chi-Square Statistics (X2)
        x = 0;
        for l = 1:3
            for c = 1: num_cat
                x = x+ (catMat{c,l}-expected_num{c,l})^2/expected_num{c,l};
            end
        end
        
        relevalt_ch = chi_square_critical_val_mat(chi_square_critical_val_mat(:,1)==c*l,2);
        
        figure
        % Convert Table to cell to char array
        tableCell = [[{''};catMat.Properties.RowNames], [catMat.Properties.VariableNames; table2cell(catMat)]];
        tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
        tableChar = splitapply(@strjoin,pad(tableCell),[1:size(tableCell,1)]');
        text(.05,.5,tableChar,'VerticalAlignment','Top','HorizontalAlignment','Left','FontName','Consolas', 'Interpreter', 'none');
        set(gca,'visible','off');
        if x > relevalt_ch
            p_text = sprintf('The chi-square statistic is %0.4f. The p-value < 0.05', x);
        else
            p_text = sprintf('The chi-square statistic is %0.4f. The p-value > 0.05', x);
        end
        text(0.1, 0.2, p_text);
        
        saveas(gca, [savepath nameOfCat{n_i} ' _Vs_Label.png']);
        close all
    end
    
end