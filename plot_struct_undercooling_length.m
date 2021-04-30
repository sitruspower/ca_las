function plot_struct_undercooling_length(var1, var2,var3,var4,n,m,l, pos)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % Euler Angles output:


%     close all;
%     alpha = [struct.alpha];
%     beta = [struct.beta];
%     gamma = [struct.gamma];
%     undercooling = [struct.undercooling];
%     length_cell = [struct.length];
%     fs = [struct.fs];
%     alpha = [struct.alpha];


    %% plotting

    plotting_variable1(:,:) = var1(round(n/2),:,:); % undercooling
    plotting_variable2(:,:) = var2(round(n/2),:,:); % length_cell
    plotting_variable3(:,:) = var3(round(n/2),:,:); %fs
    plotting_variable4(:,:) = var4(round(n/2),:,:); %alpha
    
    % initial shift from the left:
    shift_x = 0; % cells
    
    hold on
    tiledlayout(4,1)
    nexttile
%     hold on
    h = pcolor(plotting_variable1');
    colorbar
    cooling_max = num2str(max(var1(:)));
    cooling_min = num2str(min(var1(:)));
    title1 = strcat('Undercooling. Max. =', cooling_max,...
                               'K; Min.:',cooling_min, 'K');
    title(title1)
    set(h, 'EdgeColor', 'none');  
    axis equal
    % moving axis:
    ax = gca;
    ax.XLim = [shift_x+pos, round(m/3) + pos+shift_x];  % vertical
    ax.YLim = [0,l];  % horozintal
%     hold off

    nexttile
    hold on
    axis equal
    hold off
    h = pcolor(plotting_variable2');
    colorbar
    title('length of the cell');
    set(h, 'EdgeColor', 'none');
    axis equal
    hold off
    % moving axis:
    ax = gca;
    ax.XLim = [pos+shift_x,round(m/3) + pos+shift_x];  % vertical
    ax.YLim = [0,l];  % horozintal
    
    

    nexttile
    hold on
    axis equal
    hold off
    h = pcolor(plotting_variable3');
    colorbar
    title('fs');
    set(h, 'EdgeColor', 'none');
    axis equal
    hold off
    % moving axis:
    ax = gca;
    ax.XLim = [pos+shift_x,round(m/3) + pos+shift_x];  % vertical
    ax.YLim = [0,l];  % horozintal
    
    
    

    nexttile
    hold on
    axis equal
    hold off
    h = pcolor(plotting_variable4');
    colorbar
    title('alpha');
    set(h, 'EdgeColor', 'none');
    axis equal
    hold off
    
    % moving axis:
    ax = gca;
    ax.XLim = [pos+shift_x,round(m/3) + pos+shift_x];  % vertical
    ax.YLim = [0,l];  % horozintal
    
    pause(1/1000)

end

