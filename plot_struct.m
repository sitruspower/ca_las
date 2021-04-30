function plot_struct(struct,n,m,l)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % Euler Angles output:


%     close all;
    f = figure('Position',[600 10 700 350]);
    alpha = [struct.alpha];
    beta = [struct.beta];
    gamma = [struct.gamma];
    fs = [struct.temp];

    % reshaping inputs into 3D:
    alpha = reshape(alpha,n,m,l);
    beta = reshape(beta,n,m,l);
    gamma = reshape(gamma,n,m,l);
    fs = reshape(fs,n,m,l);

    % looking at the top projection

    if 1
        alpha_mid_XZ = zeros(l,m);
        beta_mid_XZ = zeros(l,m);
        gamma_mid_XZ = zeros(l,m);
        fs_XZ = zeros(l,m);
        for i=1:m % X loop
            for j = 1:l  % Z loop        
                alpha_mid_XZ(j,i) = alpha(round(n/2),i,j);
                beta_mid_XZ(j,i) =   beta(round(n/2),i,j);
                gamma_mid_XZ(j,i) = gamma(round(n/2),i,j);
                if 1 % fs(round(n/2),i,j) < 1
                    fs_XZ(j,i) = fs(round(n/2),i,j);
                end                        
            end
        end

        alpha_top_XY = zeros(n,m);
        beta_top_XY = zeros(n,m);
        gamma_top_XY = zeros(n,m);
        fs_XY = zeros(n,m);
        for i=1:n % X loop
            for j = 1:m  % Y loop        
                alpha_top_XY(i,j) = alpha(i,j,round(l));
                beta_top_XY(i,j) = beta(i,j,round(l));
                gamma_top_XY(i,j) = gamma(i,j,round(l));    
                fs_XY(i,j) = fs(i,j,round(l));        
            end
        end
    end


    %% plotting

    hold on
    tiledlayout(2,1)
    nexttile
    hold on
    h = pcolor(alpha_mid_XZ);
    title('Middle Cut Alpha')  
    set(h, 'EdgeColor', 'none');  
    axis equal
    hold off

    nexttile
    hold on
    axis equal
    hold off
    h = pcolor(alpha_top_XY);
    title('Top View Alpha');
    set(h, 'EdgeColor', 'none');
    axis equal
    hold off
    
    colorbar
    
    pause(1/1000)

end

