clear all

%%
allFeatures = {'Palm_Center_Intence', 'Thumbs_proxy_Intence' 'Index_proxy_Intence', 'Middle_proxy_Intence',...
    'Ring_proxy_Intence', 'Pinky_proxy_Intence'};
normaFlag = false;
hand = 'both';
smoothFlag=true;
%try
%    load('C:\Projects\Hand_IRT_Auto_Ecxtraction\Feature-Analysis- matlab\CodeForProposal\2D_time_regression\data.m');

%catch
[N_Hands_3D_T, names] = GetHandCubeData(allFeatures, normaFlag, hand, smoothFlag);
%save('C:\Projects\Hand_IRT_Auto_Ecxtraction\Feature-Analysis- matlab\CodeForProposal\2D_time_regression\all_data.mat','N_Hands_3D_T', 'names');
% load('C:\Projects\Hand_IRT_Auto_Ecxtraction\Feature-Analysis- matlab\CodeForProposal\2D_time_regression\all_data.mat');
leftHandData_i = cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(x, 'left'),names, 'UniformOutput', false));
leftHandData = N_Hands_3D_T(leftHandData_i, :, :);
rightHandData = N_Hands_3D_T(~leftHandData_i, :, :);


%    save('C:\Projects\Hand_IRT_Auto_Ecxtraction\Feature-Analysis- matlab\CodeForProposal\2D_time_regression\data.m','N_Hands_3D_T', 'names');
%end
train_subs = 1:29;
test_sub=3;
train_subs(test_sub)=[];
startInds = 1:size(N_Hands_3D_T,3);%19;
endInds = startInds;%20:size(N_Hands_3D_T,3);

alpha = 5;
dim_ratio = [0.5, 0.5];
dim_ratio_for_smooth = [0.5, 0.5];
per_subject = false;

if ~per_subject
    
    X_cube = [rightHandData(train_subs,:,:)];%,N_Hands_3D_C(train_subs,:,1:6)];
    f_cube = [leftHandData(train_subs,:,:)];%,N_Hands_3D_C(train_subs,:,7:26)];
    
    
    X_Sx = size(X_cube,1);
    X_Sy = size(X_cube,2);
    X_Sz = size(X_cube,3);
    
    f_Sx = size(f_cube,1);
    f_Sy = size(f_cube,2);
    f_Sz = size(f_cube,3);
    
    ALP_model.f = f_cube;
    ALP_model.X = X_cube;
    
    
    Size_of_f = f_Sx*f_Sy*f_Sz;
    
    f_flat_x = Flat_x_direction(f_cube);
    f_flat = reshape(f_flat_x,Size_of_f,1);
    
    X_flat_x = Flat_x_direction(X_cube);
    X_flat_y = Flat_y_direction(X_cube);
    
    ALP_model.X_flat_x = X_flat_x;
    ALP_model.X_flat_y = X_flat_y;
    
    
    D1 = squareform(pdist(X_flat_x,'cityblock'));
    D2 = squareform(pdist(X_flat_y,'cityblock'));
    
    ALP_model.D1 = D1;
    ALP_model.D2 = D2;
    
    ALP_model.sigma1{1}= FindEpsilon(D1)*alpha;
    ALP_model.sigma2{1}= FindEpsilon(D2)*alpha;
    
    ALP_model.K1 = [];
    ALP_model.K2 = [];
    
    ALP_model.fx_approx = [];
    ALP_model.fy_approx = [];
    ALP_model.fxy_approx = [];
    ALP_model.f_multiscale = [];
    
    f= f_cube;
    for kk = 1:10
        
        [ALP_model] = ALP_2d_Sum_Iter_Train(ALP_model, f, kk, dim_ratio);
        
        if(kk==1)
            ALP_model.f_multiscale{kk} = ALP_model.fxy_approx{kk};
        else
            ALP_model.f_multiscale{kk} = ALP_model.f_multiscale{kk-1}+ALP_model.fxy_approx{kk};
        end
        
        %errors
        f_multiscale_flat_x = Flat_x_direction(ALP_model.f_multiscale{kk});
        f_multiscale_flat = reshape(f_multiscale_flat_x,Size_of_f,1);
        %% #$@$! LEFT HERE_ WAITING TO SEE IF THE ERR CALC IS CORRECT
        
        err_vecB = f_flat-f_multiscale_flat;
        err_vecB2 = err_vecB.^2;
        MSE_err_iterB = sum(err_vecB2)./Size_of_f;
        
        ALP_model.err_iterB(kk) = MSE_err_iterB;
        
        ALP_model.Root_err_iterB(kk) = sqrt(MSE_err_iterB);
        
        
        ALP_model.d{kk} =  f_cube - ALP_model.f_multiscale{kk};
        
        f = ALP_model.d{kk};
        ALP_model.sigma1{kk+1} = ALP_model.sigma1{kk}./2;
        ALP_model.sigma2{kk+1} = ALP_model.sigma2{kk}./2;
        
        
    end
    
    
    [ kk_val, kk_ind]= min(ALP_model.err_iterB);
    
    f_train_smooth = ALP_model.f_multiscale{kk_ind};
    
    
    %test
    
    % X_test = [N_Hands_3D_T(test_sub,:,1:6)];%,N_Hands_3D_C(test_sub,:,1:6)];
    % F_test_true = [N_Hands_3D_T(test_sub,:,7:26)];%,N_Hands_3D_C(test_sub,:,7:26)];
    
    X_test = [N_Hands_3D_T(test_sub,:,1:6)];%,N_Hands_3D_C(train_subs,:,1:6)];
    F_test_true = [N_Hands_3D_T(test_sub,:,7:end)];%,N_Hands_3D_C(train_subs,:,7:26)];
    
    
    F_test_true_flat = reshape(F_test_true, 1, f_Sy*f_Sz);
    
    f_test = f_cube;
    
    %f_train_smooth = ALP_model.f_multiscale{kk_ind};
    % f_test = f_train_smooth;
    
    
    
    
    for kk_t = 1:kk_ind
        
        [f_test_approx{kk_t}] = ALP_2d_Sum_Iter_Test(ALP_model, X_test, f_test, kk_t);
        if(kk_t==1)
            f_test_multiscale{kk_t} = f_test_approx{kk_t};
        else
            f_test_multiscale{kk_t} = f_test_multiscale{kk_t-1} + f_test_approx{kk_t};
        end
        f_test = ALP_model.d{kk_t};
        
        
        f_test_multiscale_flat = reshape(f_test_multiscale{kk_t},1, f_Sy*f_Sz);
        err_vecB_test = F_test_true_flat-f_test_multiscale_flat;
        err_vecB2_test = err_vecB_test.^2;
        MSE_err_iterB_test = sum(err_vecB2_test)./(f_Sy*f_Sz);
        
        ALP_model.err_iterB_test(kk_t) = MSE_err_iterB_test;
        
        ALP_model.Root_err_iterB_test(kk_t) = sqrt(MSE_err_iterB_test);
        
    end
    
    
    %f_test_approxB = ALP_2d_Sum_Iter_Test(ALP_model, X_test, f_train_smooth, kk_t);
    
    
    % plot by color and region
    
    F_test_true_for_plot = reshape(F_test_true, 5,size(F_test_true,3), []); %5-->15/ 13-->20
    F_test_approx_for_plot = f_test_multiscale{kk_ind};
    
    figure;
    for RIOi = 1:size(F_test_true_for_plot,1)
        subplot(size(F_test_true_for_plot,1), 1, RIOi);
        plot(endInds ,F_test_true_for_plot (RIOi, :), 'LineWidth',1);
        hold on
        plot(endInds ,F_test_approx_for_plot (RIOi, :),'--', 'LineWidth',1);
    end
    
    
else
    
    %%
    for s_i = 1: 1
        
        X_cube_t = rightHandData(s_i,:,:);%,N_Hands_3D_C(train_subs,:,1:6)];
        X_cube = reshape(X_cube_t, size(X_cube_t,2),size(X_cube_t,3), 1)';
        f_cube_t = leftHandData(s_i,:,:);%,N_Hands_3D_C(train_subs,:,7:26)];
        f_cube = reshape(f_cube_t, size(f_cube_t,2),size(f_cube_t,3), 1)';
        
        X_Sx = size(X_cube,1);
        X_Sy = size(X_cube,2);
        X_Sz = size(X_cube,3);
        
        f_Sx = size(f_cube,1);
        f_Sy = size(f_cube,2);
        f_Sz = size(f_cube,3);
        
        ALP_model.f = f_cube;
        ALP_model.X = X_cube;
        
        Size_of_f = f_Sx*f_Sy*f_Sz;
        
        f_flat_x = f_cube;%Flat_x_direction(f_cube);
        f_flat = reshape(f_flat_x,Size_of_f,1);
        
        X_flat_x = X_cube;%Flat_x_direction(X_cube);
        X_flat_y = X_cube';%Flat_y_direction(X_cube);
        
        ALP_model.X_flat_x = X_flat_x;
        ALP_model.X_flat_y = X_flat_y;
        
        D1 = squareform(pdist(X_flat_x));%,'cityblock'));
        D2 = squareform(pdist(X_flat_y));%,'cityblock'));
        
        ALP_model.D1 = D1;
        ALP_model.D2 = D2;
        
        ALP_model.sigma1{1}= FindEpsilon(D1)*2;
        ALP_model.sigma2{1}= FindEpsilon(D2)*2;
        
        ALP_model.K1 = [];
        ALP_model.K2 = [];
        
        ALP_model.fx_approx = [];
        ALP_model.fy_approx = [];
        ALP_model.fxy_approx = [];
        ALP_model.f_multiscale = [];
        
        f= X_cube;
        for kk = 1:2
            
            [ALP_model] = ALP_2d_Sum_Iter_Train(ALP_model, f, kk, dim_ratio_for_smooth);
            
            if(kk==1)
                ALP_model.f_multiscale{kk} = ALP_model.fxy_approx{kk};
            else
                ALP_model.f_multiscale{kk} = ALP_model.f_multiscale{kk-1}+ALP_model.fxy_approx{kk};
            end
            
            %errors
            f_multiscale_flat_x = Flat_x_direction(ALP_model.f_multiscale{kk});
            f_multiscale_flat = reshape(f_multiscale_flat_x,Size_of_f,1);
            %% #$@$! LEFT HERE_ WAITING TO SEE IF THE ERR CALC IS CORRECT
            
            err_vecB = f_flat-f_multiscale_flat;
            err_vecB2 = err_vecB.^2;
            MSE_err_iterB = sum(err_vecB2)./Size_of_f;
            
            ALP_model.err_iterB(kk) = MSE_err_iterB;
            
            ALP_model.Root_err_iterB(kk) = sqrt(MSE_err_iterB);
            
            
            ALP_model.d{kk} =  X_cube - ALP_model.f_multiscale{kk};
            
            f = ALP_model.d{kk};
            ALP_model.sigma1{kk+1} = ALP_model.sigma1{kk}./2;
            ALP_model.sigma2{kk+1} = ALP_model.sigma2{kk}./2;
            
            
        end
        [ kk_val, kk_ind]= min(ALP_model.err_iterB);
        
        f_train_smooth = ALP_model.f_multiscale{kk_ind};
        
        %% %%%%%%%%%%%%%%%%%%
        ALP_model.f = f_cube;
        ALP_model.X = f_train_smooth;
        
        Size_of_f = f_Sx*f_Sy*f_Sz;
        
        f_flat_x = f_cube;%Flat_x_direction(f_cube);
        f_flat = reshape(f_flat_x,Size_of_f,1);
        
        X_flat_x = f_train_smooth;%Flat_x_direction(X_cube);
        X_flat_y = f_train_smooth';%Flat_y_direction(X_cube);
        
        ALP_model.X_flat_x = X_flat_x;
        ALP_model.X_flat_y = X_flat_y;
        
        D1 = squareform(pdist(X_flat_x));%,'cityblock'));
        D2 = squareform(pdist(X_flat_y));%,'cityblock'));
        
        ALP_model.D1 = D1;
        ALP_model.D2 = D2;
        
        ALP_model.sigma1{1}= FindEpsilon(D1)*2;
        ALP_model.sigma2{1}= FindEpsilon(D2)*2;
        
        ALP_model.K1 = [];
        ALP_model.K2 = [];
        
        ALP_model.fx_approx = [];
        ALP_model.fy_approx = [];
        ALP_model.fxy_approx = [];
        ALP_model.f_multiscale = [];
        
        f= X_cube;
        for kk = 1:10
            
            [ALP_model] = ALP_2d_Sum_Iter_Train(ALP_model, f, kk);
            
            if(kk==1)
                ALP_model.f_multiscale{kk} = ALP_model.fxy_approx{kk};
            else
                ALP_model.f_multiscale{kk} = ALP_model.f_multiscale{kk-1}+ALP_model.fxy_approx{kk};
            end
            
            %errors
            f_multiscale_flat_x = Flat_x_direction(ALP_model.f_multiscale{kk});
            f_multiscale_flat = reshape(f_multiscale_flat_x,Size_of_f,1);
            %% #$@$! LEFT HERE_ WAITING TO SEE IF THE ERR CALC IS CORRECT
            
            err_vecB = f_flat-f_multiscale_flat;
            err_vecB2 = err_vecB.^2;
            MSE_err_iterB = sum(err_vecB2)./Size_of_f;
            
            ALP_model.err_iterB(kk) = MSE_err_iterB;
            
            ALP_model.Root_err_iterB(kk) = sqrt(MSE_err_iterB);
            
            
            ALP_model.d{kk} =  f_cube - ALP_model.f_multiscale{kk};
            
            f = ALP_model.d{kk};
            ALP_model.sigma1{kk+1} = ALP_model.sigma1{kk}./2;
            ALP_model.sigma2{kk+1} = ALP_model.sigma2{kk}./2;
            
            
        end
        [ kk_val, kk_ind]= min(ALP_model.err_iterB);
        
    end
end


%test

% X_test = [N_Hands_3D_T(test_sub,:,1:6)];%,N_Hands_3D_C(test_sub,:,1:6)];
% F_test_true = [N_Hands_3D_T(test_sub,:,7:26)];%,N_Hands_3D_C(test_sub,:,7:26)];

X_test = [N_Hands_3D_T(test_sub,:,1:6)];%,N_Hands_3D_C(train_subs,:,1:6)];
F_test_true = [N_Hands_3D_T(test_sub,:,7:end)];%,N_Hands_3D_C(train_subs,:,7:26)];


F_test_true_flat = reshape(F_test_true, 1, f_Sy*f_Sz);

f_test = f_cube;

%f_train_smooth = ALP_model.f_multiscale{kk_ind};
% f_test = f_train_smooth;




for kk_t = 1:kk_ind
    
    [f_test_approx{kk_t}] = ALP_2d_Sum_Iter_Test(ALP_model, X_test, f_test, kk_t);
    if(kk_t==1)
        f_test_multiscale{kk_t} = f_test_approx{kk_t};
    else
        f_test_multiscale{kk_t} = f_test_multiscale{kk_t-1} + f_test_approx{kk_t};
    end
    f_test = ALP_model.d{kk_t};
    
    
    f_test_multiscale_flat = reshape(f_test_multiscale{kk_t},1, f_Sy*f_Sz);
    err_vecB_test = F_test_true_flat-f_test_multiscale_flat;
    err_vecB2_test = err_vecB_test.^2;
    MSE_err_iterB_test = sum(err_vecB2_test)./(f_Sy*f_Sz);
    
    ALP_model.err_iterB_test(kk_t) = MSE_err_iterB_test;
    
    ALP_model.Root_err_iterB_test(kk_t) = sqrt(MSE_err_iterB_test);
    
end


%f_test_approxB = ALP_2d_Sum_Iter_Test(ALP_model, X_test, f_train_smooth, kk_t);


% plot by color and region

F_test_true_for_plot = reshape(F_test_true, 5,size(F_test_true,3), []); %5-->15/ 13-->20
F_test_approx_for_plot = f_test_multiscale{kk_ind};

figure;
for RIOi = 1:size(F_test_true_for_plot,1)
    subplot(size(F_test_true_for_plot,1), 1, RIOi);
    plot(endInds ,F_test_true_for_plot (RIOi, :), 'LineWidth',1);
    hold on
    plot(endInds ,F_test_approx_for_plot (RIOi, :),'--', 'LineWidth',1);
end


plot(endInds, mean(F_test_true_for_plot(6:10,:)), 'b', 'LineWidth',2);
hold on;
plot(endInds, mean(F_test_true_for_plot(11:15,:)), 'k', 'LineWidth',2);
hold on; axis([6 27 -5 10])

figure;
plot(endInds,F_test_approx_for_plot(1,:), 'r', 'LineWidth',2);
hold on;
plot(endInds, F_test_approx_for_plot(2,:), 'm', 'LineWidth',2);
hold on;
plot(endInds, mean(F_test_approx_for_plot(3:5,:)), 'g', 'LineWidth',2);
hold on;
plot(endInds, mean(F_test_approx_for_plot(6:10,:)), 'b', 'LineWidth',2);
hold on;
plot(endInds, mean(F_test_approx_for_plot(11:15,:)), 'k', 'LineWidth',2);
hold on; axis([6 27 -5 10])
