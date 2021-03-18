
load Data_Cortex_Nuclear_data.csv

Data_Cortex_Nuclear_data = zscore(Data_Cortex_Nuclear_data);

% Sort the data axis based on DM values



train_inds_B = ones(1077,66);

Train_sz = size(train_inds_B,1)*size(train_inds_B,2);
rand_inds = ones(Train_sz,1);
b = randperm(Train_sz);
test_rand_inds = b(1:(Train_sz./10)*2);
rand_inds(test_rand_inds)=0;
train_inds_B = reshape(rand_inds, size(train_inds_B,1),size(train_inds_B,2));
figure; imagesc(train_inds_B);


%figure; surf(Data_Cortex_Nuclear_data_2)
%figure; mesh(Data_Cortex_Nuclear_data_2)

%load Data_Cortex_Nuclear_data_2;
%load Ten_percent_train_inds;
%train_inds_B = Ten_percent_train_inds;

f_sq_B = Data_Cortex_Nuclear_data;

save f_sq_B.mat f_sq_B;
save train_inds_B.mat train_inds_B;



[D1] = Build_dist_from_Sparse_Data(f_sq_B, train_inds_B);
[D2] = Build_dist_from_Sparse_Data(f_sq_B', train_inds_B');

save D1.mat D1;
save D2.mat D2;


sigma1 = FindEpsilon(D1)*2; 
sigma2 = FindEpsilon(D2)*2; 

save sigma1.mat sigma1;
save sigma2.mat sigma2;
%sigma1 = 20; 
%sigma2 = 50; 

f_to_approx = f_sq_B;

train_inds_vec = find(train_inds_B == 1);
f_train = f_sq_B(train_inds_vec);


test_inds_vec = find(train_inds_B == 0);
f_test = f_sq_B(test_inds_vec);

% plot f_train
F_train_plot = f_sq_B;
F_train_plot(test_inds_vec) = 0;
%figure; surf(F_train_plot);


for kk = 1:10

[fxy_approx{kk}, fx_approx{kk}] = ALP_2d_Iter(D1, D2, sigma1, sigma2, f_to_approx, train_inds_B)

if(kk==1)
    f_multiscale{kk} = fxy_approx{kk};
else
    f_multiscale{kk} = f_multiscale{kk-1}+fxy_approx{kk};
end;

%errors
f_train_multiscale_approx = f_multiscale{kk}(train_inds_vec);
err_vecB = f_train-f_train_multiscale_approx;
err_vecB2 = err_vecB.^2;
MSE_err_iterB = sum(err_vecB2)./size(train_inds_vec,1);
err_iterB(kk) = MSE_err_iterB;

Root_err_iterB(kk) = sqrt(MSE_err_iterB);

%test error - just for this examples
f_test_multiscale_approx = f_multiscale{kk}(test_inds_vec);
err_vecB_test = f_test-f_test_multiscale_approx;
err_vecB2_test = err_vecB_test.^2;
MSE_err_iterB_test = sum(err_vecB2_test)./size(test_inds_vec,1);
err_iterB_test(kk) = MSE_err_iterB_test;

Root_err_iterB_test(kk) = sqrt(MSE_err_iterB_test);

%figure; surf(f_multiscale{kk}); title('f-multi'); axis([0 120 0 60 -1 1]);


d{kk} = f_sq_B - f_multiscale{kk};
%figure; surf(d{kk}); title('d'); axis([0 120 0 60 -1 1]);


f_to_approx = d{kk};
sigma1 = sigma1./2;
sigma2 = sigma2./2;


end;


%figure; plot(err_iterB, 'k', 'linewidth', 2);
%hold on; plot(err_iterB_test, 'm', 'linewidth', 1);
[ kk_val, kk_ind]= min(err_iterB);

for k_i =1 : kk_ind

    f_flat_k_i = reshape(f_multiscale{k_i}, 1077*66,1);
 %   figure; plot(f_train, 'k')
 %   hold on;
 %   plot(f_flat_k_i(train_inds_vec), 'b', 'linewidth', 3);
    
   % figure; plot(f_test, 'k')
  %  hold on;
   % plot(f_flat_k_i(test_inds_vec), 'y', 'linewidth', 3);
    
 %   %figure; surf(f_multiscale{k_i}); title('f-multi'); axis([0 120 0 60 -1 1]);
    
  %  %figure; surf(d{k_i}); title('d'); axis([0 120 0 60 -1 1]);

end;

kk_ind

%figure; bar([Root_err_iterB(1:kk_ind); Root_err_iterB_test(1:kk_ind)]')

%%figure; bar([0:9],[Root_err_iterB(1:kk_ind); Root_err_iterB_test(1:kk_ind)]'); hold on; axis([-1 10 0 1]);




for k_i =1 : kk_ind
   % figure; surf(f_multiscale{k_i}); title('f-multi'); axis([0 66 0 1077 -1 10]);
    
   %% figure; surf(d{k_i}); title('d'); axis([0 120 0 60 -1 1]);

end;


% Mean imputation

Mean_impute = zeros(size(f_sq_B,1),size(f_sq_B,2));
Median_impute = zeros(size(f_sq_B,1),size(f_sq_B,2));
Freq_impute = zeros(size(f_sq_B,1),size(f_sq_B,2));

for c=1:size(f_sq_B,2)
    curr_col = f_sq_B(:,c);
    curr_col_train_inds = find(train_inds_B(:,c)==1);
    curr_col_test_inds = find(train_inds_B(:,c)==0);
    curr_col_train = f_sq_B(curr_col_train_inds, c);
    mean_c = mean(curr_col_train);
    median_c = median(curr_col_train);
    freq_c = mode(curr_col_train);
    
    curr_col(curr_col_test_inds)=-1000;
    
    curr_col_mean_imp = curr_col;
    curr_col_mean_imp(curr_col_test_inds)=mean_c;
    Mean_impute(:,c) = curr_col_mean_imp;
    
    curr_col_median_imp = curr_col;
    curr_col_median_imp(curr_col_test_inds)=median_c;
    Median_impute(:,c) = curr_col_median_imp;
    
    
    curr_col_freq_imp = curr_col;
    curr_col_freq_imp(curr_col_test_inds)=freq_c;
    Freq_impute(:,c) = curr_col_freq_imp;
    
end;

Mean_impute_test = Mean_impute(test_inds_vec);
err_mean = f_test - Mean_impute_test;
err_mean = err_mean.^2;
MSE_err_mean = sum(err_mean)./size(test_inds_vec,1)
RMSE_err_mean = sqrt(MSE_err_mean)

Median_impute_test = Median_impute(test_inds_vec);
err_median = f_test - Median_impute_test;
err_median = err_median.^2;
MSE_err_median = sum(err_median)./size(test_inds_vec,1)
RMSE_err_median = sqrt(MSE_err_median)


Freq_impute_test = Freq_impute(test_inds_vec);
err_freq = f_test - Freq_impute_test;
err_freq = err_freq.^2;
MSE_err_freq = sum(err_freq)./size(test_inds_vec,1)
RMSE_err_freq = sqrt(MSE_err_freq)

err_iterB_test(kk_ind)
sqrt(err_iterB_test(kk_ind))

% row 1 MSE:  2D_ALP, MeanErr, MedErr FreqErr
% row 2 RMSE:  2D_ALP, MeanErr, MedErr FreqErr

ALL_ERRS(1,1) = err_iterB_test(kk_ind);
ALL_ERRS(2,1) = sqrt(err_iterB_test(kk_ind));

ALL_ERRS(1,2) = err_iterB_test(kk_ind-1);
ALL_ERRS(2,2) = sqrt(err_iterB_test(kk_ind-1));


ALL_ERRS(1,3) = MSE_err_mean;
ALL_ERRS(2,3) = RMSE_err_mean;

ALL_ERRS(1,4) = MSE_err_median;
ALL_ERRS(2,4) = RMSE_err_median;

ALL_ERRS(1,5) = MSE_err_freq;
ALL_ERRS(2,5) = RMSE_err_freq;

ALL_ERRS
