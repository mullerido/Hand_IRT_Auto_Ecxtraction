function [Flat_data_y] = Flat_y_direction(cube_data)


Sx = size(cube_data,1);
Sy = size(cube_data,2);
Sz = size(cube_data,3);

Flat_data_y = [];

for k=1:Sz
    Flat_data_y = [Flat_data_y;reshape(cube_data(:,:,k),Sx,Sy)];
end;

Flat_data_y = Flat_data_y';

    