
% I assume that f is full. Train inds have values and test inds have values
% The error is calculated based on the train points only.

function  [fxy_approx, fx_approx] = ALP_2d_Iter_6th_order_kernel_test(D1, D2, sigma1, sigma2, f, train_inds)


fxy_approx = zeros(size(f));
fx_approx = zeros(size(f));


K1 = exp(-(D1.^2 ./ sigma1.^2));
K2 = exp(-(D2.^2 ./ sigma2.^2));


%% NEW

K1 = (8.*K1 - 6.*K1.^2 + K1.^4)./3;
K2 = (8.*K2 - 6.*K2.^2 + K2.^4)./3;

nn=9;
%%


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
    %K2(j,j) = 0;
end;

for j=1:size(K2,1)
    s2(j) = sum(K2(j,:));
    if(s2(j) > 0.000001)
        K2(j,:) = K2(j,:)./sum(K2(j,:));
    else
        K2(j,:) = zeros(size(K2(j,:),1),1);
    end;
end;

%K2 = eye(size(D2));


%figure; imagesc(K2);
nn=9;


% Use only train values

all_train_data_inds = find(train_inds == 1);
all_f_train = f(all_train_data_inds);
mean_f_val = mean(mean(all_f_train));



for i=1:size(f,1)
    for l=1:size(f,1)
        f_l =f(l,:);
        f_l_train_inds = train_inds(l,:);
        f_l_test_inds = ~f_l_train_inds;
       
        %new
        
        f_l_train_inds_n = find(train_inds(l,:)==1);
        f_l_test_inds_n = find(train_inds(l,:)==0);
        f_l_mean = mean(f_l(f_l_train_inds_n));


       % f_l(f_l_test_inds_n)=f_l_mean;
 f_l(f_l_test_inds_n)=mean_f_val;
      %  f_l(f_l_test_inds)=0;
        fx_approx(i,:) = fx_approx(i,:) + K1(i,l)*f_l;
        
        
        %fx_approx(i,:) = fx_approx(i,:) + K1(i,l)*f(l,:);
    end
end;
% Now fx_approx is full, so for fxy_approx all values can be used

nn=9;

for j=1:size(f,2)
    for k=1:size(f,2) 
        fxy_approx(:,j) = fxy_approx(:,j) + K2(j,k)*(fx_approx(:,k));
    end
end;

nn=9;


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
