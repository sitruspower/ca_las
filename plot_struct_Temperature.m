% function plot_struct_Temperature()
%     extention:

    clf;
    xplus = 1.; %1.1;%2.5;
    xminus = 0.1;
    inputfile = 'Temperature_100mms.csv';
    rows = csvread(inputfile); rows = single(rows);
    x = rows(:,1); y = rows(:,2); z = rows(:,3); v = rows(:,4);

    % adding desirable minimum and maximum y 
    xmin = min(x) - xminus;
    x = [x; xmin]; y = [y; y(1,1)]; z = [z; z(1,1)]; v = [v; NaN];
    
    xmax = max(x)+xplus;
    x = [x; xmax]; y = [y; y(1,1)]; z = [z; z(1,1)]; v = [v; NaN];

    xflip = x; yflip = -1*flip(y); zflip = z;
    vflip = flip(v);
    hold on
%     scatter3(x,y,z,10,v, 'filled')
    scatter3(xflip,yflip,zflip,10,vflip, 'filled')

    
    colorbar;
    title('Temperature')            
    colorbar;
    axis equal
    pause(1/1000)
    

%     f = figure('Position',[2600 100 1200 900]);
%     temp = [struct.temp];
% 
%     % reshaping inputs into 3D:
%     temp = reshape(temp,n,m,l)
% 
%     % looking at the top projection
% 
%     if 1
%         alpha_mid_XZ = zeros(l,m);
%         for i=1:m % X loop
%             for j = 1:l  % Z loop        
%                 alpha_mid_XZ(j,i) = temp(round(n/2),i,j);
%             end
%         end
% 
%         alpha_top_XY = zeros(n,m);
%         beta_top_XY = zeros(n,m);
%         gamma_top_XY = zeros(n,m);
%         fs_XY = zeros(n,m);
%         for i=1:n % X loop
%             for j = 1:m  % Y loop        
%                 alpha_top_XY(i,j) = temp(i,j,round(l));
%             end
%         end
%     end
% 
% 
%     %% plotting
% 
%     f = figure('Position',[2600 100 1200 900]);
%     hold on
% %     figure('units','normalized','outerposition',[0 0 1 1])
%     
%     tiledlayout(2,1)
%     nexttile
% %     nexttile ([1:2])
% 
%     hold on
%     h = pcolor(alpha_mid_XZ);
%     title('Middle Cut Alpha')  
%     set(h, 'EdgeColor', 'none');  
% %             plot_ijk(active, dx, xmin, ymin, zmin)
% 
%     axis equal
%     hold off
% 
%     nexttile
%     hold on
%     axis equal
%     hold off
%     h = pcolor(alpha_top_XY);
%     title('Top View Alpha');
%     set(h, 'EdgeColor', 'none');
% 
% %             plot_ijk(active, dx, xmin, ymin, zmin)
% 
%     axis equal
%     hold off
% %             
% %             nexttile
% %             hold on            
% %             contour(fs_XZ, 5)
% %             title('Middle Cut solid fraction')            
% %             colorbar;
% %             axis equal
% %             hold off
% 
% 
% 
% %     strcat('pos=', string(pos),'.fig');
% %             savefig(strcat('Alpha. pos=', string(pos),'.fig'))
%     pause(1/1000)


% end

