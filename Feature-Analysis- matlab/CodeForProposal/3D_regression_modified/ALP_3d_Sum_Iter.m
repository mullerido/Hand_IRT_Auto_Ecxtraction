
% I assume that f is full. Train inds have values and test inds have values
% The error is calculated based on the train points only.

function  [fxyz_approx, fx_approx, fy_approx, fz_approx] = ALP_3d_Sum_Iter(D1, D2, D3, sigma1, sigma2, sigma3, f, train_inds)

f_Sx = size(f,1);
f_Sy = size(f,2);
f_Sz = size(f,3);


fxyz_approx = zeros(size(f));
fx_approx = zeros(size(f));
fy_approx = zeros(size(f));
fz_approx = zeros(size(f));

fx_approx_flat = zeros(f_Sx,f_Sy*f_Sz);
fy_approx_flat = zeros(f_Sy,f_Sx*f_Sz);
fz_approx_flat = zeros(f_Sz,f_Sx*f_Sy);



K1 = exp(-(D1.^2 ./ sigma1.^2));
K2 = exp(-(D2.^2 ./ sigma2.^2));
K3 = exp(-(D3.^2 ./ sigma3.^2));


for i=1:size(K1,1)
    K1(i,i) = 0;
end;

for i=1:size(K1,1)
    s1(i) = sum(K1(i,:));
    if(s1(i) > 0.000001)
        K1(i,:) = K1(i,:)./sum(K1(i,:));
    else
        K1(i,:) = zeros(size(K1(i,:),1),1);
    end;
end;

%figure; imagesc(K1);

for j=1:size(K2,1)
    K2(j,j) = 0;
end;

for j=1:size(K2,1)
    s2(j) = sum(K2(j,:));
    if(s2(j) > 0.000001)
        K2(j,:) = K2(j,:)./sum(K2(j,:));
    else
        K2(j,:) = zeros(size(K2(j,:),1),1);
    end;
end;



for j=1:size(K3,1)
    K3(j,j) = 0;
end;

for j=1:size(K3,1)
    s3(j) = sum(K3(j,:));
    if(s3(j) > 0.000001)
        K3(j,:) = K3(j,:)./sum(K3(j,:));
    else
        K3(j,:) = zeros(size(K3(j,:),1),1);
    end;
end;

nn=9;


% Use only train values

all_train_data_inds = find(train_inds == 1);
all_f_train = f(all_train_data_inds);
mean_f_val = mean(mean(all_f_train));

f_flat_for_K1 = Flat_x_direction(f);
train_inds_flat_for_K1 = Flat_x_direction(train_inds);

for i=1:size(f_flat_for_K1,1)
    for l=1:size(f_flat_for_K1,1)
        fx_l =f_flat_for_K1(l,:);
        fx_l_train_inds = train_inds_flat_for_K1(l,:);
        fx_l_test_inds = ~fx_l_train_inds;
       
        %new, some not in use
        fx_l_train_inds_n = find(train_inds_flat_for_K1(l,:)==1);
        fx_l_test_inds_n = find(train_inds_flat_for_K1(l,:)==0);
        fx_l_mean = mean(fx_l(fx_l_train_inds_n));
%
        fx_l(fx_l_test_inds_n)=fx_l_mean;
        %fx_l(fx_l_test_inds_n)=mean_f_val;
        fx_approx_flat(i,:) = fx_approx_flat(i,:) + K1(i,l)*fx_l;
        
    end;
end;

fx_approx = Cube_data_from_x_flat(fx_approx_flat, f_Sx,f_Sy,f_Sz);
nn=9;





f_flat_for_K2 = Flat_y_direction(f);
train_inds_flat_for_K2 = Flat_y_direction(train_inds); 

for i=1:size(f_flat_for_K2,1)
    for l=1:size(f_flat_for_K2,1)
        fy_l =f_flat_for_K2(l,:);
        fy_l_train_inds = train_inds_flat_for_K2(l,:);
        fy_l_test_inds = ~fy_l_train_inds;
       
        
        
        
       %new, some not in use
        fy_l_train_inds_n = find(train_inds_flat_for_K2(l,:)==1);
        fy_l_test_inds_n = find(train_inds_flat_for_K2(l,:)==0);
        fy_l_mean = mean(fy_l(fy_l_train_inds_n));
%
        fy_l(fy_l_test_inds_n)=fy_l_mean;
        %fy_l(fy_l_test_inds_n)=mean_f_val;
        fy_approx_flat(i,:) = fy_approx_flat(i,:) + K2(i,l)*fy_l; 
    end
end;

% ADD RESHAPE
fy_approx = Cube_data_from_y_flat(fy_approx_flat, f_Sx, f_Sy, f_Sz);
nn=9;





f_flat_for_K3 = Flat_z_direction(f);
train_inds_flat_for_K3 = Flat_z_direction(train_inds); 

for i=1:size(f_flat_for_K3,1)
    for l=1:size(f_flat_for_K3,1)
        fz_l =f_flat_for_K3(l,:);
        fz_l_train_inds = train_inds_flat_for_K3(l,:);
        fz_l_test_inds = ~fz_l_train_inds;
       
       %new, some not in use
        fz_l_train_inds_n = find(train_inds_flat_for_K3(l,:)==1);
        fz_l_test_inds_n = find(train_inds_flat_for_K3(l,:)==0);
        fz_l_mean = mean(fz_l(fz_l_train_inds_n));
%
        
        fz_l(fz_l_test_inds_n)=fz_l_mean;
        %fz_l(fz_l_test_inds_n)=mean_f_val;
        fz_approx_flat(i,:) = fz_approx_flat(i,:) + K3(i,l)*fz_l;
        
    end;
end;

fz_approx = Cube_data_from_z_flat(fz_approx_flat, f_Sx, f_Sy, f_Sz);


fxyz_approx = 0.4*(fx_approx)+0.3*(fy_approx)+0.3*(fz_approx);



%ERRORS

% % mean square error
% train_inds_vec = find(train_inds == 1);
% f_train = f(train_inds_vec);
% f_train_approx = fxy_approx(train_inds_vec);
% %figure; plot(f_train); hold on; plot(f_train_approx,'m');
% err_vec = f_train-f_train_approx;
% err_vec2 = err_vec.^2;
% MSE_err_iter = sum(err_vec2)./size(train_inds_vec,1);
% err_iter = MSE_err_iter;
% 

err_iter = 1000;
