

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

X_cube = Hands_3D_T_new;
f_cube = Hands_3D_C_new;


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

%err per subject:

err_pixels_kk1 = abs(f_cube - ALP_model.f_multiscale{1});
err_pixels_kk2 = abs(f_cube - ALP_model.f_multiscale{2});
err_pixels_kk3 = abs(f_cube - ALP_model.f_multiscale{3});
err_pixels_kk4 = abs(f_cube - ALP_model.f_multiscale{4});

for p=1:20
err_per_sub_kk1(p) = sum(sum(abs(err_pixels_kk1(p,:,:))))./(15*26);
err_per_sub_kk2(p) = sum(sum(abs(err_pixels_kk2(p,:,:))))./(15*26);
err_per_sub_kk3(p) = sum(sum(abs(err_pixels_kk3(p,:,:))))./(15*26);
err_per_sub_kk4(p) = sum(sum(abs(err_pixels_kk4(p,:,:))))./(15*26);

sub_temp_base(p) = mean(Hands_3D_T_new(p,:,1));
end;
figure; bar([err_per_sub_kk1',err_per_sub_kk2',err_per_sub_kk3',err_per_sub_kk4'])
figure; plot(sub_temp_base, err_per_sub_kk4, '.k', 'MarkerSize', 30);

[ss, ii] = sort(sub_temp_base);
cold_hands = ii(1:4);
reg_hands = ii(5:15);
hot_hands = ii(16:20);

for a=1:15
err_per_area_kk1(a) = sum(sum(abs(err_pixels_kk1(:,a,:))))./(20*26);
err_per_area_kk2(a) = sum(sum(abs(err_pixels_kk2(:,a,:))))./(20*26);
err_per_area_kk3(a) = sum(sum(abs(err_pixels_kk3(:,a,:))))./(20*26);
err_per_area_kk4(a) = sum(sum(abs(err_pixels_kk4(:,a,:))))./(20*26);

err_per_area_cold_kk1(a) = sum(sum(abs(err_pixels_kk1(cold_hands,a,:))))./(4*26);
err_per_area_cold_kk2(a) = sum(sum(abs(err_pixels_kk2(cold_hands,a,:))))./(4*26);
err_per_area_cold_kk3(a) = sum(sum(abs(err_pixels_kk3(cold_hands,a,:))))./(4*26);
err_per_area_cold_kk4(a) = sum(sum(abs(err_pixels_kk4(cold_hands,a,:))))./(4*26);

err_per_area_reg_kk1(a) = sum(sum(abs(err_pixels_kk1(reg_hands,a,:))))./(11*26);
err_per_area_reg_kk2(a) = sum(sum(abs(err_pixels_kk2(reg_hands,a,:))))./(11*26);
err_per_area_reg_kk3(a) = sum(sum(abs(err_pixels_kk3(reg_hands,a,:))))./(11*26);
err_per_area_reg_kk4(a) = sum(sum(abs(err_pixels_kk4(reg_hands,a,:))))./(11*26);

err_per_area_hot_kk1(a) = sum(sum(abs(err_pixels_kk1(hot_hands,a,:))))./(5*26);
err_per_area_hot_kk2(a) = sum(sum(abs(err_pixels_kk2(hot_hands,a,:))))./(5*26);
err_per_area_hot_kk3(a) = sum(sum(abs(err_pixels_kk3(hot_hands,a,:))))./(5*26);
err_per_area_hot_kk4(a) = sum(sum(abs(err_pixels_kk4(hot_hands,a,:))))./(5*26);

end;


%figure; bar([err_per_area_kk1',err_per_area_kk2',err_per_area_kk3',err_per_area_kk4'])
figure; bar(err_per_area_kk4); hold on; axis([0 16 0 0.5]);
figure; subplot(1,3,1); bar(err_per_area_cold_kk4, 'b'); hold on; axis([0 16 0 0.5]);
hold on; subplot(1,3,2);  bar(err_per_area_reg_kk4, 'g'); hold on; axis([0 16 0 0.5]);
hold on; subplot(1,3,3); bar(err_per_area_hot_kk4, 'r'); hold on; axis([0 16 0 0.5]);


for t=1:26
err_per_time_kk1(t) = sum(sum(abs(err_pixels_kk1(:,:,t))))./(20*15);
err_per_time_kk2(t) = sum(sum(abs(err_pixels_kk2(:,:,t))))./(20*15);
err_per_time_kk3(t) = sum(sum(abs(err_pixels_kk3(:,:,t))))./(20*15);
err_per_time_kk4(t) = sum(sum(abs(err_pixels_kk4(:,:,t))))./(20*15);

err_per_time_cold_kk1(t) = sum(sum(abs(err_pixels_kk1(cold_hands,:,t))))./(4*15);
err_per_time_cold_kk2(t) = sum(sum(abs(err_pixels_kk2(cold_hands,:,t))))./(4*15);
err_per_time_cold_kk3(t) = sum(sum(abs(err_pixels_kk3(cold_hands,:,t))))./(4*15);
err_per_time_cold_kk4(t) = sum(sum(abs(err_pixels_kk4(cold_hands,:,t))))./(4*15);




err_per_time_reg_kk1(t) = sum(sum(abs(err_pixels_kk1(reg_hands,:,t))))./(11*15);
err_per_time_reg_kk2(t) = sum(sum(abs(err_pixels_kk2(reg_hands,:,t))))./(11*15);
err_per_time_reg_kk3(t) = sum(sum(abs(err_pixels_kk3(reg_hands,:,t))))./(11*15);
err_per_time_reg_kk4(t) = sum(sum(abs(err_pixels_kk4(reg_hands,:,t))))./(11*15);

err_per_time_hot_kk1(t) = sum(sum(abs(err_pixels_kk1(hot_hands,:,t))))./(5*15);
err_per_time_hot_kk2(t) = sum(sum(abs(err_pixels_kk2(hot_hands,:,t))))./(5*15);
err_per_time_hot_kk3(t) = sum(sum(abs(err_pixels_kk3(hot_hands,:,t))))./(5*15);
err_per_time_hot_kk4(t) = sum(sum(abs(err_pixels_kk4(hot_hands,:,t))))./(5*15);

end;

figure; bar([err_per_time_kk1',err_per_time_kk2',err_per_time_kk3',err_per_time_kk4'])
figure; bar(err_per_time_kk4); hold on; axis([0 27 0 0.5]);
figure; subplot(1,3,1); bar(err_per_time_cold_kk4, 'b'); hold on; axis([0 27 0 0.5]);
hold on; subplot(1,3,2); bar(err_per_time_reg_kk4, 'g'); hold on; axis([0 27 0 0.5]);
hold on; subplot(1,3,3); bar(err_per_time_hot_kk4, 'r'); hold on; axis([0 27 0 0.5]);


% some plots:


%hot hands
P4_t_true = reshape(Hands_3D_T_new(4,:,:),15,26);

P4_c_true = reshape(Hands_3D_C_new(4,:,:),15,26);
P4_c_approx_tmp_kk4 = ALP_model.f_multiscale{4}(4,:,:);
P4_approx_kk4 = reshape(P4_c_approx_tmp_kk4,15,26);
%figure; plot(P4_c_true', 'linewidth', 2); hold on; axis([0 27 26 40]);
%figure; plot(P4_approx_kk4', 'linewidth', 1.2); hold on; axis([0 27 26 40]);
%figure; subplot(2,1,1); plot(P4_t_true', 'Color',[0.7,0.7, 0.7],'linewidth', 1.5); hold on; axis([0 27 26 40]);
figure; subplot(2,1,1); plot(P4_t_true', 'y','linewidth', 1.5); hold on; axis([0 27 26 40]);

hold on;
plot(P4_c_true', 'k', 'linewidth', 1.5); hold on; axis([0 27 26 40]);
hold on;
plot(22,28, '.k', 'markersize', 30); hold on; 
%plot(22,30, '.', 'Color',[0.7,0.7, 0.7],'markersize', 30); hold on; 
plot(22,30, '.y','markersize', 30); hold on; 

subplot(2,1,2);  plot(P4_c_true', 'k','linewidth', 1.5); hold on; axis([0 27 26 40]);
hold on; plot(P4_approx_kk4', 'r','linewidth', 1); hold on; axis([0 27 26 40]);
hold on;
plot(22,30, '.k', 'markersize', 30); hold on; 
plot(22,28, '.r', 'markersize', 30); hold on; 

%reg hands
P20_t_true = reshape(Hands_3D_T_new(20,:,:),15,26);

P20_c_true = reshape(Hands_3D_C_new(20,:,:),15,26);
P20_c_approx_tmp_kk4 = ALP_model.f_multiscale{4}(20,:,:);
P20_approx_kk4 = reshape(P20_c_approx_tmp_kk4,15,26);
%figure; plot(P20_c_true', 'linewidth', 2); hold on; axis([0 27 26 40]);
%figure; plot(P20_approx_kk4', 'linewidth', 1.2); hold on; axis([0 27 26 40]);

%figure; subplot(2,1,1);  plot(P20_t_true', 'Color',[0.7,0.7, 0.7],'linewidth', 1.5); hold on; axis([0 27 26 40]);
figure; subplot(2,1,1);  plot(P20_t_true', 'y','linewidth', 1.5); hold on; axis([0 27 26 40]);
hold on;
plot(P20_c_true',  'k', 'linewidth', 1.5); hold on; axis([0 27 26 40]);
hold on;
plot(22,28, '.k', 'markersize', 30); hold on; 
%plot(22,30, '.', 'Color',[0.7,0.7, 0.7],'markersize', 30); hold on; 
plot(22,30, '.y','markersize', 30); hold on; 

subplot(2,1,2); plot(P20_c_true','k', 'linewidth', 1.5); hold on; axis([0 27 26 40]);
hold on; plot(P20_approx_kk4','g', 'linewidth', 1); hold on; axis([0 27 26 40]);
plot(22,30, '.k', 'markersize', 30); hold on; 
plot(22,28, '.g', 'markersize', 30); hold on; 

%cold hands
P12_t_true = reshape(Hands_3D_T_new(12,:,:),15,26);
P12_c_true = reshape(Hands_3D_C_new(12,:,:),15,26);
P12_c_approx_tmp_kk4 = ALP_model.f_multiscale{4}(12,:,:);
P12_approx_kk4 = reshape(P12_c_approx_tmp_kk4,15,26);
%figure; plot(P12_t_true', 'linewidth', 2); hold on; axis([0 27 26 40]);
%figure; plot(P12_c_true', 'linewidth', 2); hold on; axis([0 27 26 40]);
%figure; plot(P12_approx_kk4', 'linewidth', 1.2); hold on; axis([0 27 26 40]);

%figure; subplot(2,1,1);  plot(P12_t_true', 'Color',[0.7,0.7, 0.7],'linewidth', 1.5); hold on; axis([0 27 26 40]);
figure; subplot(2,1,1);  plot(P12_t_true', 'y','linewidth', 1.5); hold on; axis([0 27 26 40]);
hold on;
plot(P12_c_true', 'k' ,'linewidth', 1.5); hold on; axis([0 27 26 40]);
hold on;
plot(22,28, '.k', 'markersize', 30); hold on; 
plot(22,30, '.y','markersize', 30); hold on; 
%plot(22,30, '.', 'Color',[0.7,0.7, 0.7],'markersize', 30); hold on; 
 subplot(2,1,2);  plot(P12_c_true','k', 'linewidth', 1.5); hold on; axis([0 27 26 40]);
hold on; plot(P12_approx_kk4','b', 'linewidth', 1); hold on; axis([0 27 26 40]);
plot(22,30, '.k', 'markersize', 30); hold on; 
plot(22,28, '.b', 'markersize', 30); hold on; 

f_train_smooth = ALP_model.f_multiscale{kk_ind};

%% test


% 
%  X_test = Hands_3D_T_new(1,:,:);
%  F_test_true = Hands_3D_C_new(1,:,:);
% 
% F_test_true_flat =  reshape(F_test_true, 1, f_Sy*f_Sz);
% 
% f_kk_ind = ALP_model.f_multiscale{kk_ind};
% [f_test_approx] = ALP_3d_Sum_Iter_Test(ALP_model, X_test, f_kk_ind, kk_ind);


%f_test = f_cube;

% f_test = f_train_smooth;
% 
%     
% 
% for kk_t = 1:kk_ind
%     
%     [f_test_approx{kk_t}] = ALP_3d_Sum_Iter_Test(ALP_model, X_test, f_test, kk_t)
%      if(kk_t==1)
%         f_test_multiscale{kk_t} = f_test_approx{kk_t};
%     else
%         f_test_multiscale{kk_t} = f_test_multiscale{kk_t-1} + f_test_approx{kk_t};
%     end;
%     f_test = ALP_model.d{kk_t};
%     
%     
%     f_test_multiscale_flat = reshape(f_test_multiscale{kk_t},1, f_Sy*f_Sz);
%     err_vecB_test = F_test_true_flat-f_test_multiscale_flat;
%     err_vecB2_test = err_vecB_test.^2;
%     MSE_err_iterB_test = sum(err_vecB2_test)./(f_Sy*f_Sz);
%     
%     ALP_model.err_iterB_test(kk_t) = MSE_err_iterB_test;
% 
%     ALP_model.Root_err_iterB_test(kk_t) = sqrt(MSE_err_iterB_test);
% 
% end;



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
