function [f_test_approx] = ALP_3d_Sum_Iter_Test_6th(ALP_model, X_test, f, iter_num)


f_Sx = size(f,1);
f_Sy = size(f,2);
f_Sz = size(f,3);


X_test_flat_x = reshape(X_test,1,f_Sy*f_Sz);
D1_test = pdist2(ALP_model.X_flat_x,X_test_flat_x);

K1_test = exp(-(D1_test.^2 ./ ALP_model.sigma1{iter_num}.^2));
K1_test = (8*K1_test - 6*K1_test.^2+K1_test.^4)./3;
K1_test = K1_test./sum(K1_test);


%f_flat_for_K1 = Flat_x_direction(ALP_model.f_multiscale{iter_num});
f_flat_for_K1 = Flat_x_direction(f);
fx_test_approx_flat = zeros(1,f_Sy*f_Sz);

for l=1:size(K1_test,1)
    fx_l = f_flat_for_K1(l,:);
    fx_test_approx_flat = fx_test_approx_flat + K1_test(l)*fx_l;
end;


fx_test_approx = Cube_data_from_x_flat(fx_test_approx_flat, 1,f_Sy,f_Sz);
fx_test_approx = reshape(fx_test_approx,f_Sy,f_Sz);


fy_test_approx = zeros(f_Sy,f_Sz);

K2_test = ALP_model.K2{iter_num};
for i=1:size(K2_test,1)
    for l=1:size(K2_test,1)
        fy_l = fx_test_approx(l,:);
        fy_test_approx(i,:) = fy_test_approx(i,:) + K2_test(i,l)*fy_l; 
    end;
end;



fz_test_approx = zeros(f_Sy,f_Sz);

K3_test = ALP_model.K3{iter_num};
for i=1:size(K3_test,1)
    for l=1:size(K3_test,1)
        fz_l = fx_test_approx(:,l);
        fz_test_approx(:,i) = fz_test_approx(:,i) + K3_test(i,l)*fz_l; 
    end;
end;

fz_test_approx = fz_test_approx;
f_test_approx = 0.34*fx_test_approx+0.33*fy_test_approx+0.33*fz_test_approx;


% % now apply K2 and K3 to this
% % fx_test_approx is 15X26
% fy_test_approx = zeros(f_Sy,f_Sz);
% K2_test = ALP_model.K2{iter_num};
% 
% f_flat_for_K2 = Flat_y_direction(ALP_model.f);
% 
% for i=1:size(fy_test_approx,1)
%     for l=1:size(fy_test_approx,1)
%         %fy_l =fx_test_approx(l,:);
%         fy_l = f_flat_for_K2(l,:);
%         fy_test_approx(i,:) = fy_test_approx(i,:) + K2_test(i,l)*fy_l; 
%     end
% end;
% 
% 
% %%%
% 
% fz_test_approx = zeros(f_Sz,f_Sy);
% K3_test = ALP_model.K3{iter_num};
% 
% for i=1:size(fz_test_approx,1)
%     for l=1:size(fz_test_approx,1)
%         fz_l =fx_test_approx(:,l)';
%         fz_test_approx(i,:) = fz_test_approx(i,:) + K3_test(i,l)*fz_l; 
%     end
% end;
% 
% fz_test_approx = fz_test_approx';
% 
% fxyz_test_approx = 0.34*(fx_test_approx)+0.33*(fy_test_approx)+0.33*(fz_test_approx);
%  f_test_approx = fxyz_test_approx;
% nn=9;

