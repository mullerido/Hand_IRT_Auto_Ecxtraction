
Hands_3D_T = zeros(20,15,26);
Hands_3D_C = zeros(20,15,26);

load P1.csv;
[T1_resh, C1_resh] = Reshape_P_data(P1);
Hands_3D_T(1,:,:) = T1_resh;
Hands_3D_C(1,:,:) = C1_resh;

load P2.csv;
[T2_resh, C2_resh] = Reshape_P_data(P2);
Hands_3D_T(2,:,:) = T2_resh;
Hands_3D_C(2,:,:) = C2_resh;

load P3.csv;
[T3_resh, C3_resh] = Reshape_P_data(P3);
Hands_3D_T(3,:,:) = T3_resh;
Hands_3D_C(3,:,:) = C3_resh;


load P4.csv;
[T4_resh, C4_resh] = Reshape_P_data(P4);
Hands_3D_T(4,:,:) = T4_resh;
Hands_3D_C(4,:,:) = C4_resh;


load P5.csv;
[T5_resh, C5_resh] = Reshape_P_data(P5);
Hands_3D_T(5,:,:) = T5_resh;
Hands_3D_C(5,:,:) = C5_resh;


load P6.csv;
[T6_resh, C6_resh] = Reshape_P_data(P6);
Hands_3D_T(6,:,:) = T6_resh;
Hands_3D_C(6,:,:) = C6_resh;


load P7.csv;
[T7_resh, C7_resh] = Reshape_P_data(P7);
Hands_3D_T(7,:,:) = T7_resh;
Hands_3D_C(7,:,:) = C7_resh;


load P8.csv;
[T8_resh, C8_resh] = Reshape_P_data(P8);
Hands_3D_T(8,:,:) = T8_resh;
Hands_3D_C(8,:,:) = C8_resh;


load P9.csv;
[T9_resh, C9_resh] = Reshape_P_data(P9);
Hands_3D_T(9,:,:) = T9_resh;
Hands_3D_C(9,:,:) = C9_resh;

load P10.csv;
[T10_resh, C10_resh] = Reshape_P_data(P10);
Hands_3D_T(10,:,:) = T10_resh;
Hands_3D_C(10,:,:) = C10_resh;

load P11.csv;
[T11_resh, C11_resh] = Reshape_P_data(P11);
Hands_3D_T(11,:,:) = T11_resh;
Hands_3D_C(11,:,:) = C11_resh;

load P12.csv;
[T12_resh, C12_resh] = Reshape_P_data(P12);
Hands_3D_T(12,:,:) = T12_resh;
Hands_3D_C(12,:,:) = C12_resh;


load P13.csv;
[T13_resh, C13_resh] = Reshape_P_data(P13);
Hands_3D_T(13,:,:) = T13_resh;
Hands_3D_C(13,:,:) = C13_resh;


load P14.csv;
[T14_resh, C14_resh] = Reshape_P_data(P14);
Hands_3D_T(14,:,:) = T14_resh;
Hands_3D_C(14,:,:) = C14_resh;


load P15.csv;
[T15_resh, C15_resh] = Reshape_P_data(P15);
Hands_3D_T(15,:,:) = T15_resh;
Hands_3D_C(15,:,:) = C15_resh;


load P16.csv;
[T16_resh, C16_resh] = Reshape_P_data(P16);
Hands_3D_T(16,:,:) = T16_resh;
Hands_3D_C(16,:,:) = C16_resh;


load P17.csv;
[T17_resh, C17_resh] = Reshape_P_data(P17);
Hands_3D_T(17,:,:) = T17_resh;
Hands_3D_C(17,:,:) = C17_resh;


load P18.csv;
[T18_resh, C18_resh] = Reshape_P_data(P18);
Hands_3D_T(18,:,:) = T18_resh;
Hands_3D_C(18,:,:) = C18_resh;


load P19.csv;
[T19_resh, C19_resh] = Reshape_P_data(P19);
Hands_3D_T(19,:,:) = T19_resh;
Hands_3D_C(19,:,:) = C19_resh;


load P20.csv;
[T20_resh, C20_resh] = Reshape_P_data(P20);
Hands_3D_T(20,:,:) = T20_resh;
Hands_3D_C(20,:,:) = C20_resh;

save Hands_3D_T.mat Hands_3D_T;
save Hands_3D_C.mat Hands_3D_C;