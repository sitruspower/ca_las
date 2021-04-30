function struct = func_restruct_fs_addT3D(struct, T, Tliq, Tsol, n, m, l, active) %n,m,temp, orient, Tliq, Tsol, dx)
% *******************************************************************
%         INITIALISATION. creating matrix structure. 
% ********************************************************************
if 1
    undercool_max = max(struct.undercooling(:));
    undercooling_add_value = 25; %undercool_max/5; % [K] adding on top 
    %% assigning the struct
    for i=1:n
        for j=1:m
            for k=1:l
                
                struct.temp(i,j,k) = T(i,j,k);
                if T(i,j,k) >= Tliq
                    %% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! changed!!!!!
%                     struct.fs(i,j,k) = 0;
                    struct.fs(i,j,k) = 1;
                    
                    struct.undercooling(i,j,k) = undercooling_add_value;
                        
                elseif T(i,j,k) <Tliq && T(i,j,k) > Tsol
                    struct.fs(i,j,k) = 1-(T(i,j,k)-Tsol)/(Tliq - Tsol);
                   
                    struct.undercooling(i,j,k) = T(i,j,k)-Tsol + undercooling_add_value;
                elseif T(i,j,k) <= Tsol
                    struct.fs(i,j,k) = 1;
                    struct.undercooling(i,j,k) = undercooling_add_value;
                    
                else                    
                    struct.fs(i,j,k) = 1;
                    fprintf('FS=%.3f temp=%3.f C. \n', struct.fs(i,j,k), struct.temp(i,j,k))
                end             
            end
        end
    end
    
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! changed!!!!!
    struct.length(:,:,:) = 0;
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
