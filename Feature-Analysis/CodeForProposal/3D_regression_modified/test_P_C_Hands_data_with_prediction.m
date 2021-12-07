

load Hands_3D_T.mat;
load Hands_3D_C.mat;


[Hands_3D_T_new] = ChangeToNewLocations(Hands_3D_T);
[Hands_3D_C_new] = ChangeToNewLocations(Hands_3D_C);

% make each hand of each subject mean zero
% 
% for n=1:20
%     T_cur = Hands_3D_T_new(n,:,:);
%     C_cur = Hands_3D_C_new(n,:,:);
%     m_T_cur = mean(mean(T_cur)); 
%     m_C_cur = mean(mean(C_cur));
%     z_T_cur = T_cur - m_T_cur;
%     z_C_cur = C_cur - m_C_cur;
%     zHands_3D_T(n,:,:) = z_T_cur;
%     zHands_3D_C(n,:,:) = z_C_cur;
% end;

X_cube = Hands_3D_T_new([1:3,5:20],:,:);
f_cube = Hands_3D_C_new([1:3,5:20],:,:);


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
X_flat_z = Flat_z_direction(X_cube);

ALP_model.X_flat_x = X_flat_x;
ALP_model.X_flat_y = X_flat_y;
ALP_model.X_flat_z = X_flat_z;


D1 = squareform(pdist(X_flat_x));
D2 = squareform(pdist(X_flat_y));
D3 = squareform(pdist(X_flat_z));

ALP_model.D1 = D1;
ALP_model.D2 = D2;
ALP_model.D3 = D3;

ALP_model.sigma1{1}= FindEpsilon(D1)*2; 
ALP_model.sigma2{1}= FindEpsilon(D2)*2; 
ALP_model.sigma3{1}= FindEpsilon(D3)*2; 

ALP_model.K1 = [];
ALP_model.K2 = [];
ALP_model.K3 = [];

ALP_model.fx_approx = [];
ALP_model.fy_approx = [];
ALP_model.fz_approx = [];
ALP_model.fxyz_approx = [];
ALP_model.f_multiscale = []

f= f_cube;
for kk = 1:10

    [ALP_model] = ALP_3d_Sum_Iter_Train(ALP_model, f, kk)

    if(kk==1)
        ALP_model.f_multiscale{kk} = ALP_model.fxyz_approx{kk};
    else
        ALP_model.f_multiscale{kk} = ALP_model.f_multiscale{kk-1}+ALP_model.fxyz_approx{kk};
    end;

    %errors
    f_multiscale_flat_x = Flat_x_direction(ALP_model.f_multiscale{kk});
    f_multiscale_flat = reshape(f_multiscale_flat_x,Size_of_f,1);

    
    err_vecB = f_flat-f_multiscale_flat;
    err_vecB2 = err_vecB.^2;
    MSE_err_iterB = sum(err_vecB2)./Size_of_f;
    
    ALP_model.err_iterB(kk) = MSE_err_iterB;

    ALP_model.Root_err_iterB(kk) = sqrt(MSE_err_iterB);

    
    ALP_model.d{kk} =  f_cube - ALP_model.f_multiscale{kk};

    f = ALP_model.d{kk};
    ALP_model.sigma1{kk+1} = ALP_model.sigma1{kk}./2;
    ALP_model.sigma2{kk+1} = ALP_model.sigma2{kk}./2;
    ALP_model.sigma3{kk+1} = ALP_model.sigma3{kk}./2;
    

end;


[ kk_val, kk_ind]= min(ALP_model.err_iterB);

f_train_smooth = ALP_model.f_multiscale{kk_ind};

%% test



 X_test = reshape(Hands_3D_T_new(4,:,:),15,26);
 F_test_true = reshape(Hands_3D_C_new(4,:,:),15,26);

F_test_true_flat =  reshape(F_test_true, 1, f_Sy*f_Sz);



f_test = f_cube;

% f_test = f_train_smooth;
% 
%     
% 
 for kk_t = 1:kk_ind
     
     [f_test_approx{kk_t}] = ALP_3d_Sum_Iter_Test(ALP_model, X_test, f_test, kk_t)
      if(kk_t==1)
         f_test_multiscale{kk_t} = f_test_approx{kk_t};
     else
         f_test_multiscale{kk_t} = f_test_multiscale{kk_t-1} + f_test_approx{kk_t};
     end;
     f_test = ALP_model.d{kk_t};
     
     
     f_test_multiscale_flat = reshape(f_test_multiscale{kk_t},1, f_Sy*f_Sz);
     err_vecB_test = F_test_true_flat-f_test_multiscale_flat;
     err_vecB2_test = err_vecB_test.^2;
     MSE_err_iterB_test = sum(err_vecB2_test)./(f_Sy*f_Sz);
     
     ALP_model.err_iterB_test(kk_t) = MSE_err_iterB_test;
 
     ALP_model.Root_err_iterB_test(kk_t) = sqrt(MSE_err_iterB_test);
 
 end;


f_kk_ind = ALP_model.f_multiscale{kk_ind};
[f_test_approxB] = ALP_3d_Sum_Iter_Test(ALP_model, X_test, f_kk_ind, kk_ind);
err_vecB_testB = F_test_true_flat- reshape(f_test_approxB,1,15*26);
err_vecB2_testB = err_vecB_testB.^2;
MSE_err_iterB_testB = sum(err_vecB2_testB)./(f_Sy*f_Sz)
     

[f_test_approxC] = ALP_3d_Sum_Iter_Test(ALP_model, X_test, f_cube, kk_ind);
err_vecB_testC = F_test_true_flat- reshape(f_test_approxC,1,15*26);
err_vecB2_testC = err_vecB_testC.^2;
MSE_err_iterB_testC = sum(err_vecB2_testC)./(f_Sy*f_Sz)


 F_test_treated_true = reshape(Hands_3D_T_new(4,:,:),15,26);


% 
% [f_test_approx_2nd] = test_approx1(ALP_model, X_test, ALP_model.f_multiscale{kk_ind}, kk_ind);
% 
% f_test_approx_2nd_flat = reshape(f_test_approx_2nd,1,f_Sy*f_Sz);
% err_vecB_test1 = F_test_true_flat-f_test_approx_2nd_flat;
%     err_vecB2_test1 = err_vecB_test1.^2;
%     MSE_err_iterB_test1 = sum(err_vecB2_test1)./(f_Sy*f_Sz);
%     
% [f_test_approx_2nd_from_f] = test_approx1(ALP_model, X_test, ALP_model.f, kk_ind);
% 
% f_test_approx_2nd_from_f_flat = reshape(f_test_approx_2nd_from_f,1,f_Sy*f_Sz);
% err_vecB_test1_from_f = F_test_true_flat-f_test_approx_2nd_from_f_flat;
%     err_vecB2_test1_from_f = err_vecB_test1_from_f.^2;
%     MSE_err_iterB_test1_from_f = sum(err_vecB2_test1_from_f)./(f_Sy*f_Sz);
%     
