function [f_test_approx] = test_approx1(ALP_model, X_test, f, iter_num)

f_train_approx = ALP_model.f_multiscale{iter_num};
train_data = ALP_model.X;


f_Sx = size(f,1);
f_Sy = size(f,2);
f_Sz = size(f,3);



% Find dists for each area
f_test_approx_area = zeros(f_Sy,f_Sz);

for j=1:f_Sy
    A_train_temp = reshape(train_data(:,j,:),f_Sx,f_Sz);
    A_test_temp = reshape(X_test(:,j,:),1,f_Sz);
    
    D2_test = pdist2(A_train_temp,A_test_temp);

    K2_test = exp(-(D2_test.^2 ./ ALP_model.sigma2{iter_num}.^2));
  %  K2_test = 2*K2_test - K2_test.^2;
    K2_test = K2_test./sum(K2_test);

   f_train_approx_Area_j = reshape(f(:,j,:),f_Sx,f_Sz);
    
    for k=1:size(K2_test,1)
        f_test_approx_area(j,:) = f_test_approx_area(j,:) + K2_test(k)*f_train_approx_Area_j(k,:);
    end;
end


nnn=9;




% Find dists for each area
f_test_approx_time = zeros(f_Sy,f_Sz);

for j=1:f_Sz
    T_train_temp = reshape(train_data(:,:,j),f_Sx,f_Sy);
    T_test_temp = reshape(X_test(:,:,j),1,f_Sy);
    
    D3_test = pdist2(T_train_temp,T_test_temp);

    K3_test = exp(-(D3_test.^2 ./ ALP_model.sigma3{iter_num}.^2));
 %   K3_test = 2*K3_test - K3_test.^2;
    K3_test = K3_test./sum(K3_test);

   f_train_approx_Time_j = reshape(f(:,:,j),f_Sx,f_Sy);
    
    for k=1:size(K3_test,1)
        f_test_approx_time(:,j) = f_test_approx_time(:,j) + K3_test(k)*f_train_approx_Time_j(k,:)';
    end;
end

nnn=9;



% Find dists by subject similarity
f_test_approx_sub = zeros(f_Sy,f_Sz);

X_test_flat_x = reshape(X_test,1,f_Sy*f_Sz);
D1_test = pdist2(ALP_model.X_flat_x,X_test_flat_x);

K1_test = exp(-(D1_test.^2 ./ ALP_model.sigma1{iter_num}.^2));
%K1_test = 2*K1_test - K1_test.^2;
K1_test = K1_test./sum(K1_test);


%f_flat_for_K1 = Flat_x_direction(ALP_model.f_multiscale{iter_num});
f_flat_for_K1 = Flat_x_direction(f);
fx_test_approx_flat = zeros(1,f_Sy*f_Sz);

for l=1:size(K1_test,1)
    fx_l = f_flat_for_K1(l,:);
    fx_test_approx_flat = fx_test_approx_flat + K1_test(l)*fx_l;
end;


f_test_approx_sub = Cube_data_from_x_flat(fx_test_approx_flat, 1,f_Sy,f_Sz);
f_test_approx_sub = reshape(f_test_approx_sub,f_Sy,f_Sz);


nnn=9;


f_test_approx = 0.34*f_test_approx_sub +0.33*f_test_approx_area +0.33*f_test_approx_time;