load Housing_13_cols.csv

house_dt = Housing_13_cols(:,[1:3,5:8,10:13]);
% 
house_c_1 = Housing_13_cols(:,1);
house_c_2 = Housing_13_cols(:,2);
house_c_3 = Housing_13_cols(:,3);
house_c_4 = Housing_13_cols(:,4);
house_c_5 = Housing_13_cols(:,5);
house_c_6 = Housing_13_cols(:,6);
house_c_7 = Housing_13_cols(:,7);
house_c_8 = Housing_13_cols(:,8);
house_c_9 = Housing_13_cols(:,9);
house_c_10 = Housing_13_cols(:,10);
house_c_11 = Housing_13_cols(:,11);
% 
%
 house_dt(:,1) = house_c_2;
 house_dt(:,2) = house_c_6;
 house_dt(:,3) = house_c_8;
 house_dt(:,4) = house_c_1;
 house_dt(:,5) = house_c_11;
 house_dt(:,6) = house_c_9;
 house_dt(:,7) = house_c_3;
 house_dt(:,8) = house_c_10;
 house_dt(:,9) = house_c_5;
 house_dt(:,10) = house_c_7;
 house_dt(:,11) = house_c_4;
% 

[Z_house_dt, mu_house_dt, sig_house_dt] = (zscore(house_dt));

train_inds_B = ones(506,11);


Train_sz = size(train_inds_B,1)*size(train_inds_B,2);
rand_inds = ones(Train_sz,1);
b = randperm(Train_sz);
test_rand_inds = b(1:(Train_sz./10)*0.5);
rand_inds(test_rand_inds)=0;
train_inds_B = reshape(rand_inds, size(train_inds_B,1),size(train_inds_B,2));
%figure; imagesc(train_inds_B);

%figure; surf(Z_wine)

f_sq_B = Z_house_dt;


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


%sigma1 = 12; 
%sigma2 = 150; 

f_to_approx = f_sq_B;

train_inds_vec = find(train_inds_B == 1);
f_train = f_sq_B(train_inds_vec);


test_inds_vec = find(train_inds_B == 0);
f_test = f_sq_B(test_inds_vec);

% plot f_train
F_train_plot = f_sq_B;
F_train_plot(test_inds_vec) = 0;
figure; surf(F_train_plot);


for kk = 1:12

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

 %   f_flat_k_i = reshape(f_multiscale{k_i}, 506*11,1);
 %   figure; plot(f_train)
 %   hold on;
 %   plot(f_flat_k_i(train_inds_vec), 'k', 'linewidth', 2);
    
  % figure; plot(f_test)
  % hold on;
  % plot(f_flat_k_i(test_inds_vec), 'm', 'linewidth', 2);
    
  %%  %figure; surf(f_multiscale{k_i}); title('f-multi'); axis([0 120 0 60 -1 1]);
    
  % % %figure; surf(d{k_i}); title('d'); axis([0 120 0 60 -1 1]);

end;


figure; bar([Root_err_iterB(1:kk_ind); Root_err_iterB_test(1:kk_ind)]')




for k_i =1 : kk_ind
    %figure; surf(f_multiscale{k_i}); title('f-multi'); axis([0 11 0 506 -5 20]);
    
  % % figure; surf(d{k_i}); title('d'); axis([0 120 0 60 -1 1]);

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

