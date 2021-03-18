function [cube_data] = Cube_data_from_y_flat(Flat_y_data, Sx,Sy,Sz)

Flat_y_data = Flat_y_data';
i=1;
for k=1:Sz
    t=Flat_y_data((i-1)*Sx+1:i*Sx,:);
    cube_data(:,:,k) = t;
    i = i+1;
end;