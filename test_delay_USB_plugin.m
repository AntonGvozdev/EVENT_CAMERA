clc; close all; clear
%% Load data
load('data_A_100.mat')
% load('data_3_2.mat') % "data_usb" use desktop to capture

t_min = floor(min(data_fpga(end,4)));
dt = 1/30;   % Plot interval (0.1)
d = 1.0e5;  % Time window (old: 1.0e5)
st = 0;     % Start time (old: 3) (data_4: 2) (data_5: 2)
diff_t = 0.5; %(data_3: 0.42) (data_4: 1.3) (data_5: 1.4) (data_50: 2.09) (data_A_100: 0.5)

% Video
outputVideo = VideoWriter('video_out_100.avi');
outputVideo.FrameRate = 30;
open(outputVideo)

event_per_sec = zeros(2,61); count=0;

for t=st:dt:t_min-diff_t
    % Synchronisation (USB slower than FPGA)
%     mask_fpga_p = (data_fpga(:,4)>t*1e6 & data_fpga(:,4)<(t*1e6+d) & data_fpga(:,3)>0);
%     mask_fpga_n = (data_fpga(:,4)>t*1e6 & data_fpga(:,4)<(t*1e6+d) & data_fpga(:,3)==0);
%     mask_usb_p = (data_usb(:,4)>(t+diff_t)*1e6 & data_usb(:,4)<((t+diff_t)*1e6+d) & data_usb(:,3)>0);
%     mask_usb_n = (data_usb(:,4)>(t+diff_t)*1e6 & data_usb(:,4)<((t+diff_t)*1e6+d) & data_usb(:,3)==0);
    
    % Synchronisation (FPGA slower than USB)
    mask_fpga_p = (data_fpga(:,4)>(t+diff_t)*1e6 & data_fpga(:,4)<((t+diff_t)*1e6+d) & data_fpga(:,3)>0);
    mask_fpga_n = (data_fpga(:,4)>(t+diff_t)*1e6 & data_fpga(:,4)<((t+diff_t)*1e6+d) & data_fpga(:,3)==0);
    %mask_usb_p = (data_usb(:,4)>(t)*1e6 & data_usb(:,4)<((t)*1e6+d) & data_usb(:,3)>0);
    %mask_usb_n = (data_usb(:,4)>(t)*1e6 & data_usb(:,4)<((t)*1e6+d) & data_usb(:,3)==0);
    
    gcf=figure(1); set(gcf,'position',[1,41,1920,963])
    subplot(1,2,1); hold off
    plot(data_fpga(mask_fpga_p,1),data_fpga(mask_fpga_p,2),'r+', data_fpga(mask_fpga_n,1),data_fpga(mask_fpga_n,2),'bx')
    axis equal; title('FPGA'); drawnow
    %subplot(1,2,2); hold off
    %plot(data_usb(mask_usb_p,1),180-data_usb(mask_usb_p,2),'r+', data_usb(mask_usb_n,1),180-data_usb(mask_usb_n,2),'bx')
    %axis equal; title('USB (with ROS)'); drawnow %sprintf('USB (t:%.1f)',t) % 'USB (with ROS)'
    drawnow
    
    % Compute events per second
    count = count+1;
    event_per_sec(:,count) = [sum(mask_fpga_p)+sum(mask_fpga_n)]/(d/1e6);
    
    % Write to video
    F = getframe(gcf);
    writeVideo(outputVideo,F.cdata);
    %pause(0.2)
end
close(outputVideo)

%% Plot events per seconds
figure; plot(([1:size(event_per_sec,2)]-1)/33, event_per_sec)
legend('FPGA')