function [Flat_data_x] = Flat_x_direction(cube_data)

Sx = size(cube_data,1);
Sy = size(cube_data,2);
Sz = size(cube_data,3);

Flat_data_x = [];

for k=1:Sz
    Flat_data_x = [Flat_data_x,reshape(cube_data(:,:,k),Sx,Sy)];
end;

    