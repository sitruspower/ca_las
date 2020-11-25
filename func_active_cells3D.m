%% Get active (boundary) cells from struct
function [active] = func_active_cells3D(struct, xslice, yslice, zslice, xi, yi, zi, xmin, ymin, zmin)
    
    s = size(struct);
    n = s(1);
    m = s(2);
    l = s(3);
%     
%     xslice = input.xslice; yslice = input.yslice; zslice = input.zslice;
%     xi = struct.xi; yi = struct.yi; zi = struct.zi;
%     xmin = input.xmin; ymin = input.ymin; zmin = input.zmin;
    dx = xi(1,2,1) - xi(1,1,1);
    
    
    dy = dx;
    dz = dx;

    %close all;
    fs = [struct.temp];
    fs = reshape(fs,n,m,l);
    active=[];
    finished=0;

    %% looking for boundary layer
    if 1
    % ijk
    if 1
        for i=1:n
            for j=1:m
            finished = 0;
                for k=1:l
                    if ~finished && struct(i,j,k).fs < 1
                        %BndCells(i,j-1) = 1;
                        active = [active; i,j,k];
                        finished = 1;
                    end
                end
            end
        end
    end

    %fprintf('started!')
    % ikj
    if 1
        for i=1:n
            for k=1:l
            finished = 0;
                for j=1:m
                    if ~finished && struct(i,j,k).fs < 1
                        %BndCells(i,j-1) = 1;
                        active = [active; i,j,k];
                        finished = 1;
                    end
                end
            end
        end
    end

    finished = 0;
    % ik-j
    if 1  % correct but wrong side
        for i=1:n            
            for k=1:l                
                finished = 0;
                for j=m:-1:1

                    if ~finished && struct(i,j,k).fs < 1
                        active = [active; i,j,k];
                        finished = 1;
                    end
                end
            end
        end
    end


    % jik
    if 1
        for j=1:m
            for i=1:n
            finished = 0;
                for k=1:l
                    if ~finished && struct(i,j,k).fs < 1
                        %BndCells(i,j-1) = 1;
                        active = [active; i,j,k];
                        finished = 1;
                    end
                end
            end
        end
    end

    % jki
    if 1
        for j=1:m
            for k=1:l
            finished = 0;
                for i=1:n
                    if ~finished && struct(i,j,k).fs < 1
                        %BndCells(i,j-1) = 1;
                        active = [active; i,j,k];
                        finished = 1;
                    end
                end
            end
        end
    end


    % jk-i
    if 1
        for j=1:m
            for k=1:l
            finished = 0;
                for i=n:-1:1
                    if ~finished && struct(i,j,k).fs < 1
                        %BndCells(i,j-1) = 1;
                        active = [active; i,j,k];
                        finished = 1;
                    end
                end
            end
        end
    end
    end

    active = unique(active, 'rows');

    %% removing front side of the layer. K plane

    zplanes=unique(active(:,3));
    newactive=[];
    for planeidx=1:length(zplanes)
        ijplane = [];
        for i=1:length(active(:,1))
            if active(i,3) == zplanes(planeidx)
                ijplane = [ijplane; active(i,:)];
            end
        end

        [ymax,idxmax]=max(ijplane(:,1));
        [ymin,idxmin]=min(ijplane(:,1));
        maxrow=ijplane(idxmax,:);
        minrow=ijplane(idxmin,:);
        xmax = ijplane(idxmax,2);
        xmin = ijplane(idxmin,2);
        
        for i=1:length(ijplane)
            if ijplane(i,2)<xmax
                newactive = [newactive;ijplane(i,:)];
                
            end
        end
        newactive = [newactive;minrow;maxrow];
    end

    %% plotting
    %% plotting slice
    if 0
        f = figure('Position',[2600 100 1000 600]);
        movegui(f);
        hold on

        if 1
            h=slice(xi, yi, zi, fs, xslice, yslice, zslice)
            set(h,'EdgeColor','none',...
            'FaceColor','interp',...
            'FaceAlpha','interp');
            alpha('color');
            cm_plasma=colormap_plasma(100);
            %alphamap('rampdown')  
            colormap(cm_plasma) %hot hsv
            colormap(hot) %hot hsv
            alphamap('increase',0.01)
            colorbar
        end
        %% plotting active
        if 0   
            x = active(:,1);y = active(:,2);z = active(:,3);
            scatter3(x,y,z,50,'filled', 'green');
        end
        %% plotting plane
        if 0    
            x = ijplane(:,1);y = ijplane(:,2);z = ijplane(:,3);
            scatter3(x,y,z,50,'filled', 'red');
        end

        %% plotting newactive
        if 0    
            x = newactive(:,1);y = newactive(:,2);z = newactive(:,3);
            scatter3(x,y,z,100, 'blue');
        end

        axis equal

        hold off
    end
    active=newactive;
    active(:,:) = active(:,:) - ones(length(active(:,1)), 1)*[0,1,0];
    
    
    save('active.mat','active')
end
