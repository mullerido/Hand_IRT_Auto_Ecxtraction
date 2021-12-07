

load Hands_3D_T.mat;
load Hands_3D_C.mat;

% make each hand of each subject mean zero

for n=1:20
    T_cur = Hands_3D_T(n,:,:);
    C_cur = Hands_3D_C(n,:,:);
    m_T_cur = mean(mean(T_cur)); 
    m_C_cur = mean(mean(C_cur));
    z_T_cur = T_cur - m_T_cur;
    z_C_cur = C_cur - m_C_cur;
    zHands_3D_T(n,:,:) = z_T_cur;
    zHands_3D_C(n,:,:) = z_C_cur;
end;

zHands_3D_data = [zHands_3D_T;zHands_3D_C];
Sx = size(zHands_3D_data,1);
Sy = size(zHands_3D_data,2);
Sz = size(zHands_3D_data,3);

% lets take P1 control hand to be test, from time 6 to time 20

train_inds = ones(Sx,Sy,Sz);
train_inds(21,:,21:26)=0;

f_sq_B = zHands_3D_data;

f_flat_x = Flat_x_direction(f_sq_B);
inds_flat_x = Flat_x_direction(train_inds);

D1 = Build_dist_from_Sparse_Data(f_flat_x, inds_flat_x);

%

f_flat_y = Flat_y_direction(f_sq_B);
inds_flat_y = Flat_y_direction(train_inds);

D2 = Build_dist_from_Sparse_Data(f_flat_y, inds_flat_y);

%

f_flat_z = Flat_z_direction(f_sq_B);
inds_flat_z = Flat_z_direction(train_inds);

D3 = Build_dist_from_Sparse_Data(f_flat_z, inds_flat_z);

sigma1 = FindEpsilon(D1)*20; 
sigma2 = FindEpsilon(D2)*20; 
sigma3 = FindEpsilon(D3)*20; 


f_to_approx = f_sq_B;

train_inds_vec = find(train_inds == 1);
f_train = zHands_3D_data(train_inds_vec);


test_inds_vec = find(train_inds == 0);
f_test = zHands_3D_data(test_inds_vec);


for kk = 1:10

[fxyz_approx{kk}, fx_approx{kk}, fy_approx{kk}, fz_approx{kk}] = ALP_3d_Sum_Iter(D1, D2, D3, sigma1, sigma2, sigma3, f_to_approx, train_inds)

if(kk==1)
    f_multiscale{kk} = fxyz_approx{kk};
else
    f_multiscale{kk} = f_multiscale{kk-1}+fxyz_approx{kk};
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


d{kk} =  f_sq_B - f_multiscale{kk};
%figure; surf(d{kk}); title('d'); axis([0 120 0 60 -1 1]);


f_to_approx = d{kk};
sigma1 = sigma1./2;
sigma2 = sigma2./2;
sigma3 = sigma3./2;


end;

[ kk_val, kk_ind]= min(err_iterB);

