function [Flat_data_z] = Flat_z_direction(cube_data)


Sx = size(cube_data,1);
Sy = size(cube_data,2);
Sz = size(cube_data,3);

Flat_data_z = [];

for k=1:Sz
    Flat_data_z(k,:) = reshape(cube_data(:,:,k),1,Sx*Sy);
end;

