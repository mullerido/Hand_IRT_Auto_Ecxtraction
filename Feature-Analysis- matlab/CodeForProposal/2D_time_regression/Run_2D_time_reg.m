
load Hands_3D_T.mat;
load Hands_3D_C.mat;


[Hands_3D_T_new] = ChangeToNewLocations(Hands_3D_T);
[Hands_3D_C_new] = ChangeToNewLocations(Hands_3D_C);

train_subs = [1:16,18:20];
test_sub = 17;

%Just keep the temp changes from t=0

for n=1:20
    T_cur = Hands_3D_T_new(n,:,:);
    C_cur = Hands_3D_C_new(n,:,:);
    for a=1:15
        curr_T_area = T_cur(1,a,:); 
        curr_C_area = C_cur(1,a,:); 
        a_T_t0_curr = T_cur(1,a,1);
        a_C_t0_curr = C_cur(1,a,1);
        Ncurr_T_area = curr_T_area - a_T_t0_curr;
        Ncurr_C_area = curr_C_area - a_C_t0_curr;
        T_curN(1,a,:) = Ncurr_T_area;
        C_curN(1,a,:) = Ncurr_C_area;
    end;
    N_Hands_3D_T(n,:,:) = T_curN;
    N_Hands_3D_C(n,:,:) = C_curN;
end;


X_cube = [N_Hands_3D_T(train_subs,:,1:6)];%,N_Hands_3D_C(train_subs,:,1:6)];
f_cube = [N_Hands_3D_T(train_subs,:,7:26)];%,N_Hands_3D_C(train_subs,:,7:26)];


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


D1 = squareform(pdist(X_flat_x));
D2 = squareform(pdist(X_flat_y));

ALP_model.D1 = D1;
ALP_model.D2 = D2;

ALP_model.sigma1{1}= FindEpsilon(D1)*0.5; 
ALP_model.sigma2{1}= FindEpsilon(D2)*0.5; 

ALP_model.K1 = [];
ALP_model.K2 = [];

ALP_model.fx_approx = [];
ALP_model.fy_approx = [];
ALP_model.fxy_approx = [];
ALP_model.f_multiscale = []

f= f_cube;
for kk = 1:10

    [ALP_model] = ALP_2d_Sum_Iter_Train(ALP_model, f, kk)

    if(kk==1)
        ALP_model.f_multiscale{kk} = ALP_model.fxy_approx{kk};
    else
        ALP_model.f_multiscale{kk} = ALP_model.f_multiscale{kk-1}+ALP_model.fxy_approx{kk};
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
    

end;


[ kk_val, kk_ind]= min(ALP_model.err_iterB);

f_train_smooth = ALP_model.f_multiscale{kk_ind};


%test

X_test = [N_Hands_3D_T(test_sub,:,1:6)];%,N_Hands_3D_C(test_sub,:,1:6)];
F_test_true = [N_Hands_3D_T(test_sub,:,7:26)];%,N_Hands_3D_C(test_sub,:,7:26)];

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
     end;
     f_test = ALP_model.d{kk_t};
     
     
     f_test_multiscale_flat = reshape(f_test_multiscale{kk_t},1, f_Sy*f_Sz);
     err_vecB_test = F_test_true_flat-f_test_multiscale_flat;
     err_vecB2_test = err_vecB_test.^2;
     MSE_err_iterB_test = sum(err_vecB2_test)./(f_Sy*f_Sz);
     
     ALP_model.err_iterB_test(kk_t) = MSE_err_iterB_test;
 
     ALP_model.Root_err_iterB_test(kk_t) = sqrt(MSE_err_iterB_test);
 
 end;


     f_test_approxB = ALP_2d_Sum_Iter_Test(ALP_model, X_test, f_train_smooth, kk_t);
 
     
  % plot by color and region
  
  F_test_true_for_plot = reshape(F_test_true, 15,20);
  F_test_approx_for_plot = f_test_multiscale{kk_ind};
  
  figure; plot([7:26],F_test_true_for_plot(1,:), 'r', 'LineWidth',2);
  hold on;
  plot([7:26],F_test_true_for_plot(2,:), 'm', 'LineWidth',2);
  hold on;
  plot([7:26],mean(F_test_true_for_plot(3:5,:)), 'g', 'LineWidth',2);
  hold on;
 
  plot([7:26],mean(F_test_true_for_plot(6:10,:)), 'b', 'LineWidth',2);
  hold on;
  plot([7:26],mean(F_test_true_for_plot(11:15,:)), 'k', 'LineWidth',2);
  hold on; axis([6 27 -5 10])
  
  figure; plot([7:26],F_test_approx_for_plot(1,:), 'r', 'LineWidth',2);
  hold on;
  plot([7:26],F_test_approx_for_plot(2,:), 'm', 'LineWidth',2);
  hold on;
  plot([7:26],mean(F_test_approx_for_plot(3:5,:)), 'g', 'LineWidth',2);
  hold on;
  plot([7:26], mean(F_test_approx_for_plot(6:10,:)), 'b', 'LineWidth',2);
  hold on;
  plot([7:26],mean(F_test_approx_for_plot(11:15,:)), 'k', 'LineWidth',2);
  hold on; axis([6 27 -5 10])
  