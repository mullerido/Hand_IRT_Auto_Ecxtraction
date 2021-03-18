function [cube_data] = Cube_data_from_x_flat(Flat_x_data, Sx,Sy,Sz)

j=1;
for k=1:Sz
    t=Flat_x_data(:,(j-1)*Sy+1:j*Sy);
    cube_data(:,:,k) = t;
    j = j+1;
end;