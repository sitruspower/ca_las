function struct = func_restruct_fs_addT3D(struct, T, Tliq, Tsol, n, m, l) %n,m,temp, orient, Tliq, Tsol, dx)
% *******************************************************************
%         INITIALISATION. creating matrix structure. 
% ********************************************************************
if 1
    % clear all
    Tsol = 2900;
    Tliq = 2800;
    
    %% assigning the struct
    for i=1:n
        for j=1:m
            for k=1:l
                struct(i,j,k).temp = T(i,j,k);                
                if T(i,j,k) >= Tliq
                    struct(i,j,k).fs = 0;
                elseif T(i,j,k) >Tliq && T(i,j,k) < Tsol
                   struct(i,j,k).fs = 1-(T(i,j,k)-Tsol)/(Tliq - Tsol);
                else
                    struct(i,j,k).fs = 1;
                end
                
%                 
%                 cell.alpha = alpha(i,j,k);
%                 cell.beta = beta(i,j,k);
%                 cell.gamma= gamma(i,j,k);              
%                 cell.grain = j + (i-1)*n + (k-1)*n*m;            
                cell.undercooling = 100; %Tliq-temp(i,j);
%                 cell.length = 0;
%                 cell.active = 0;       % is 1 if active
%                 cell.deltaTime = 0;
%                 cell.init_point = [(i-1)*dx+xmin,(j-1)*dx+ymin, (k-1)*dz+zmin];  % was j, i in 2D case. Can be an issue in 3D.
%                 
%                 struct(i,j,k) = cell;
            end
        end
    end
    
    % clearvars -except vq xi yi zi xslice yslice zslice struct n m l xmin ymin zmin
    
    % save('Struct_mesh.mat')
%     
%     if 0
%         %alpha = 1;
%         plot_variable = [struct.fs];
%         plot_variable = reshape (plot_variable, n,m,l);
%         slice(xi, yi, zi, plot_variable, xslice, yslice, zslice);
%         axis equal
%         colorbar;
%     end
    
    
end
