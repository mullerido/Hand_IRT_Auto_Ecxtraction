function [f_test_approx] = ALP_2d_Sum_Iter_Test(ALP_model, X_test, f, iter_num)


f_Sx = size(f,1);
f_Sy = size(f,2);
f_Sz = size(f,3);

X_Sx = size(X_test,1);
X_Sy = size(X_test,2);
X_Sz = size(X_test,3);


X_test_flat_x = reshape(X_test,1,X_Sy*X_Sz);
D1_test = pdist2(ALP_model.X_flat_x,X_test_flat_x);% Replace with DTW to check distance with some shifting

K1_test = exp(-(D1_test.^2 ./ ALP_model.sigma1{iter_num}.^2));

K1_test = K1_test./sum(K1_test);



%f_flat_for_K1 = Flat_x_direction(ALP_model.f_multiscale{iter_num});
f_flat_for_K1 = Flat_x_direction(f);
fx_test_approx_flat = zeros(1,f_Sy*f_Sz);

for l=1:size(K1_test,1)
    fx_l = f_flat_for_K1(l,:);
    fx_test_approx_flat = fx_test_approx_flat + K1_test(l)*fx_l;
end

fx_test_approx = Cube_data_from_x_flat(fx_test_approx_flat, 1,f_Sy,f_Sz);
fx_test_approx = reshape(fx_test_approx,f_Sy,f_Sz);
%###- Try to use up to this step first!
% f_test_approx = fx_test_approx 
% Instead of using row 75


% %%
% X_test_flat_y = reshape(X_test,X_Sy,X_Sz);
% for kk2=1:f_Sy
%     X_test_flat_y_Area_curr = repmat(X_test_flat_y(kk2,:),1,19);
%     D2_test(kk2,:) = pdist2(ALP_model.X_flat_y,X_test_flat_y_Area_curr);
%     K2_test(kk2,:) = exp(-(D2_test(kk2,:).^2 ./ ALP_model.sigma2{iter_num}.^2));
%     K2_test(kk2,:) = K2_test(kk2,:)./sum(K2_test(kk2,:));
%     
% end
% %%
% 
% % maybe i can use the train K2
% f_flat_for_K2 = Flat_y_direction(f);
% 
% f_test_flat_y_BIG=zeros(f_Sy,f_Sx*f_Sz);
% K2 = ALP_model.K2{iter_num};
% for j=1:f_Sy
%     for kk_22 = 1:f_Sy
%         f_test_flat_y_BIG(j,:) = f_test_flat_y_BIG(j,:) + K2(j,kk_22)*f_flat_for_K2(kk_22,:);
%   %      f_test_flat_y_BIG(j,:) = f_test_flat_y_BIG(j,:) + K2_test(j,kk_22)*f_flat_for_K2(kk_22,:);
%     end
% end
% 
% f_test_flat_y=zeros(f_Sy,f_Sz);
% for j=1:f_Sy
%     curr_j_row_rect = reshape(f_test_flat_y_BIG(j,:), f_Sx, f_Sz);
%     for i=1:f_Sx
%         f_test_flat_y(j,:) = f_test_flat_y(j,:)+K1_test(i)*curr_j_row_rect(i,:);
% %        f_test_flat_y(j,:) = f_test_flat_y(j,:)+(1./19)*curr_j_row_rect(i,:);
%     end
% end
% 
% 
% nn=9
% 
% fy_test_approx = f_test_flat_y;
f_test_approx = fx_test_approx;
% f_test_approx = (0.5)*fx_test_approx+(0.5)*fy_test_approx;

%f_test_approx = (0.5+(0.1*(1./iter_num)))*fx_test_approx+(0.5+(0.1*(1./iter_num)))*fy_test_approx;
