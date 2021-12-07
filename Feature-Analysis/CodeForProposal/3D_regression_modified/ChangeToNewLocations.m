function [Hand_data_new] = ChangeToNewLocations(Hand_data_old)


Hand_data_new(:,1,:) = Hand_data_old(:,1,:);
Hand_data_new(:,2,:) = Hand_data_old(:,4,:);
Hand_data_new(:,3,:) = Hand_data_old(:,2,:);
Hand_data_new(:,4,:) = Hand_data_old(:,3,:);
Hand_data_new(:,5,:) = Hand_data_old(:,5,:);
Hand_data_new(:,6,:) = Hand_data_old(:,6,:);
Hand_data_new(:,7,:) = Hand_data_old(:,8,:);
Hand_data_new(:,8,:) = Hand_data_old(:,10,:);
Hand_data_new(:,9,:) = Hand_data_old(:,12,:);
Hand_data_new(:,10,:) = Hand_data_old(:,14,:);
Hand_data_new(:,11,:) = Hand_data_old(:,7,:);
Hand_data_new(:,12,:) = Hand_data_old(:,9,:);
Hand_data_new(:,13,:) = Hand_data_old(:,11,:);
Hand_data_new(:,14,:) = Hand_data_old(:,13,:);
Hand_data_new(:,15,:) = Hand_data_old(:,15,:);