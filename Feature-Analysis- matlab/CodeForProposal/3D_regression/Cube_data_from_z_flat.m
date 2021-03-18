function [cube_data] = Cube_data_from_z_flat(Flat_z_data, Sx,Sy,Sz)



for k=1:Sz
    t=reshape(Flat_z_data(k,:),Sx,Sy);
    cube_data(:,:,k) = t;
end;