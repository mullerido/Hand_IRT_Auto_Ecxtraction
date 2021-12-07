function [D] = Build_dist_from_Sparse_Data(in_data, train_inds)


s1 = size(in_data,1);

for i=1:s1
    d_i = train_inds(i,:);
    for j=1:s1
        d_j = train_inds(j,:);
        common_inds = find((d_i-d_j)==0);
        
        r_i = in_data(i,common_inds);
        r_j = in_data(j,common_inds);
        D(i,j) = pdist([r_i;r_j]); 
    end;
end;
