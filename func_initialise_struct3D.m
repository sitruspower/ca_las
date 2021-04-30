function struct = func_initialise_struct3D(T, Tliq, Tsol) %n,m,temp, orient, Tliq, Tsol, dx)
% *******************************************************************
%         INITIALISATION. creating matrix structure. 
% ********************************************************************

if 1
    % clear all
    Tsol = 2900;
    Tliq = 2800;
    
    %% reading
    input_euler=open('RandomOrientation.mat');
    
    alpha = input_euler.alpha;
    beta  = input_euler.beta;
    gamma = input_euler.gamma;
    
    
    inputs=open('InterpolatedTemperatureGrid.mat'); % opening just for the slice, to be removed...
    xi = inputs.xi;
    yi = inputs.yi;
    zi = inputs.zi;    

    %T(:,:,:) = Temperature_HighInput(;    
    
    xslice = inputs.xslice;
    yslice = inputs.yslice;
    zslice = inputs.zslice;
    xmin = inputs.xmin;
    ymin = inputs.ymin;
    zmin = inputs.zmin;
        
    
    n=length(xi(:,1,1));
    m=length(yi(1,:,1));
    l=length(zi(1,1,:));
    
    dx = xi(1,2,1)-xi(1,1,1);  % mm
    dy = dx;  % mm
    dz = dx;  % mm
    %% assigning the struct
    for i=1:n
        for j=1:m
            for k=1:l
                cell.temp = T(i,j,k);                
                if T(i,j,k) >= Tliq
                    cell.fs = 0;
                elseif T(i,j,k) >Tliq && T(i,j,k) < Tsol
                   cell.fs = 1-(T(i,j,k)-Tsol)/(Tliq - Tsol);
                else
                    cell.fs = 1;
                end
                
                % remove this! for testing only
                % cell.fs = 0;
                
                cell.alpha = alpha(i,j,k);
                cell.beta = beta(i,j,k);
                cell.gamma= gamma(i,j,k);              
                cell.grain = j + (i-1)*n + (k-1)*n*m;            
%                 cell.undercooling = 0; %Tliq-temp(i,j);
                cell.length = 0;
                cell.active = 0;       % is 1 if active
                cell.deltaTime = 0;
                cell.init_point = [(i-1)*dx+xmin,(j-1)*dx+ymin, (k-1)*dz+zmin];  % was j, i in 2D case. Can be an issue in 3D.
                
                struct(i,j,k) = cell;
            end
        end
    end
    
    % clearvars -except vq xi yi zi xslice yslice zslice struct n m l xmin ymin zmin
    
    % save('Struct_mesh.mat')
    
    if 1
        %alpha = 1;
        plot_variable = [struct.fs];
        plot_variable = reshape (plot_variable, n,m,l);
        slice(xi, yi, zi, plot_variable, xslice, yslice, zslice);
        axis equal
        colorbar;
    end
    
    
end
