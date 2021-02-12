function struct = func_restruct_fs_addT3D(struct, T, Tliq, Tsol, n, m, l, active) %n,m,temp, orient, Tliq, Tsol, dx)
% *******************************************************************
%         INITIALISATION. creating matrix structure. 
% ********************************************************************
if 1
    
    %% assigning the struct
    for i=1:n
        for j=1:m
            for k=1:l
                
                
                struct.temp(i,j,k) = T(i,j,k);                      
                if T(i,j,k) >= Tliq
                    struct.fs(i,j,k) = 0;
                elseif T(i,j,k) <Tliq && T(i,j,k) > Tsol
                   struct.fs(i,j,k) = 1-(T(i,j,k)-Tsol)/(Tliq - Tsol);
                elseif T(i,j,k) <= Tsol
                    struct.fs(i,j,k) = 1;
                else                    
                    struct.fs(i,j,k) = 1;
                    fprintf('FS=%.3f temp=%3.f C. \n', struct.fs(i,j,k), struct.temp(i,j,k))
                end             
            end
        end
    end
    
    
    

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
        
        for i=1:length(ijplane(:,1))
            if ijplane(i,2)==xmax
                newactive = [newactive;ijplane(i,:)];
                
            end
        end
        newactive = [newactive;minrow;maxrow];
    end
    
%     hold on
%     func_plot_active (active)
    
%     
%     fs = [struct.fs];
%     fs = reshape(fs,n,m,l);
%     h = slice(xi, yi, zi, fs, xslice, yslice, zslice);
%     axis equal
%     
    clearvars -except struct
    
    % save('Struct_mesh.mat')
%     
    if 0
        %alpha = 1;
        plot_variable = [struct.fs];
        plot_variable = reshape (plot_variable, n,m,l);
        slice(xi, yi, zi, plot_variable, xslice, yslice, zslice);
        axis equal
        colorbar;
    end
    
    
end
