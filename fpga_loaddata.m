clc; close all; clear
%% ============ From FPGA ============ 
% import data
id = 100;
%data_fpga = importdata(sprintf('data_fpga_%d.csv',id),',');
data_fpga = importdata(sprintf('data_NOT_FSM.csv',id),',');

% Remove rows without info
data_fpga(data_fpga(:,1)==0,:)=[];

% For some reason the column is flipped
data_fpga = [data_fpga(:,2),data_fpga(:,1)];

tmp = zeros(size(data_fpga,1),4);
for r=1:size(data_fpga,1)
    tmp(r,:) = [ bi2de(bitget(data_fpga(r,2),10:17)), ...   % x
        bi2de(bitget(data_fpga(r,2),1:8)), ...              % y
        bi2de(bitget(data_fpga(r,2),9)),...                 % p
        data_fpga(r,1)-data_fpga(1,1)];
%     xpy(r,:) = [ bi2de(bitget(data_fpga(r,2),10:17)), ...
%         bi2de(bitget(data_fpga(r,2),9)), ...
%         bi2de(bitget(data_fpga(r,2),1:8))];
end
%%
% 
% Remove spurious data (x>240, y>180)
tmp(tmp(:,2)>179 | tmp(:,1)>239,:)=[];
max(tmp)
data_fpga = tmp; clear tmp;
% 
% Sort timestamp
%[~,ind] = sort(data_fpga(:,4));
%data_fpga = data_fpga(ind,:);

% Remove repeated events
data_fpga([false;all(diff(data_fpga)==0,2)],:)=[];

%% Save as MAT file
save('data_A_100.mat', 'data_fpga');