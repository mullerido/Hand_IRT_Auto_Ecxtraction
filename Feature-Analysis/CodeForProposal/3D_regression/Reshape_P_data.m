function [T_resh, C_resh] = Reshape_P_data(P_data)

T_inds = find(P_data(:,2) == 1);
C_inds = find(P_data(:,2) == 0);

P_T_data = P_data(T_inds,5);
P_C_data = P_data(C_inds,5);

T_resh = reshape(P_T_data,15,26);
C_resh = reshape(P_C_data,15,26);
