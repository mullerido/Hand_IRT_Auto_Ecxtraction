

function  [ALP_model] = ALP_3d_Sum_Iter_Train(ALP_model, f, iter_num)

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


K1 = exp(-(ALP_model.D1.^2 ./ ALP_model.sigma1{iter_num}.^2));
K2 = exp(-(ALP_model.D2.^2 ./ ALP_model.sigma2{iter_num}.^2));
K3 = exp(-(ALP_model.D3.^2 ./ ALP_model.sigma3{iter_num}.^2));

%K1 = 2*K1 - K1.^2;
%K2 = 2*K2 - K2.^2;
%K3 = 2*K3 - K3.^2;


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


ALP_model.K1{iter_num} = K1;
ALP_model.K2{iter_num} = K2;
ALP_model.K3{iter_num} = K3;





f_flat_for_K1 = Flat_x_direction(f);

for i=1:size(f_flat_for_K1,1)
    for l=1:size(f_flat_for_K1,1)
        fx_l =f_flat_for_K1(l,:);
        fx_approx_flat(i,:) = fx_approx_flat(i,:) + K1(i,l)*fx_l;
    end;
end;

fx_approx = Cube_data_from_x_flat(fx_approx_flat, f_Sx,f_Sy,f_Sz);


ALP_model.fx_approx{iter_num} = fx_approx;

nn=9;





f_flat_for_K2 = Flat_y_direction(f);

for i=1:size(f_flat_for_K2,1)
    for l=1:size(f_flat_for_K2,1)
        fy_l =f_flat_for_K2(l,:);
        fy_approx_flat(i,:) = fy_approx_flat(i,:) + K2(i,l)*fy_l; 
    end
end;

% ADD RESHAPE
fy_approx = Cube_data_from_y_flat(fy_approx_flat, f_Sx, f_Sy, f_Sz);
ALP_model.fy_approx{iter_num} = fy_approx;


nn=9;





f_flat_for_K3 = Flat_z_direction(f);

for i=1:size(f_flat_for_K3,1)
    for l=1:size(f_flat_for_K3,1)
        fz_l =f_flat_for_K3(l,:);
        fz_approx_flat(i,:) = fz_approx_flat(i,:) + K3(i,l)*fz_l;
    end;
end;


fz_approx = Cube_data_from_z_flat(fz_approx_flat, f_Sx, f_Sy, f_Sz);
ALP_model.fz_approx{iter_num} = fz_approx;

nn=9;

fxyz_approx = 0.34*(fx_approx)+0.33*(fy_approx)+0.33*(fz_approx);
ALP_model.fxyz_approx{iter_num} = fxyz_approx;


nn=9;