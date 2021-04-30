% tic
% ffunc_initialise_struct_portions3D(temperature, Tliq, Tsol) 
% toc

function structure = func_initialise_struct_portions3D(T, Tliq, Tsol, checker) %n,m,temp, orient, Tliq, Tsol, dx)
% *******************************************************************
%         INITIALISATION. creating matrix structure. 
% ********************************************************************

    % clear all
    divide_by = 1;
    
    
    %% reading
    input_euler=open('RandomOrientation.mat');
    
    alpha = input_euler.alpha;
    beta  = input_euler.beta;
    gamma = input_euler.gamma;
        
    inputs=open('InterpolatedTemperatureGrid.mat'); % opening just for the slice, to be removed...

    presicion = 3;
    digits(presicion);
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
    if Tliq<Tsol
        error('Tliq<Tsol! error in inputs. Raised from func_initialise_struct3D.m')
    end
        
    for a = 1:divide_by % old version for parallelisation
        if a>1
            % structure = open('Struct_portion.mat')
        else
            
            
            s_temp = ones(n,m,l, 'single');
            s_alpha = zeros(n,m,l, 'single');
            s_beta = zeros(n,m,l, 'single');
            s_gamma = zeros(n,m,l, 'single');
            s_undercooling = zeros(n,m,l, 'single');
            s_length = zeros(n,m,l, 'single');
            s_deltaTime = zeros(n,m,l, 'single');
            
        end
        
        s_temp(:,:,:) = T(:,:,:);
        s_fs = ones(n,m,l, 'single');     
        s_alpha(:,:,:) = alpha(:,:,:);
        s_beta(:,:,:) = beta(:,:,:);
        s_gamma(:,:,:) = gamma(:,:,:);              
%         s_undercooling(:,:,:)= (T(:,:,:) - Tsol); % old = 100; %
        s_undercooling(:,:,:) = nan; 

        
        % ADDING REAL UNDERCOOLING VALUE:
%         s_undercooling(:,:,:) = (T(:,:,:) - Tsol); % old = 100; %
        s_length(:,:,:) = 0;
        s_deltaTime(:,:,:) = 0;
    %                 cell.grain = j + (i-1)*n + (k-1)*n*m;            

        % IF 1: ALL IN MUSHY ZOME.
        % IF 0: FS ASSIGNED AS NORMAL.
        
        if checker == 1
            s_fs=s_fs*0.5;
        else
            
%         undercooling_add_value = 50; % [K] adding on top 
        for i=1:n
            for j=1:m
                for k=1:l
                    s_temp(i,j,k) = T(i,j,k);                
                    if T(i,j,k) >= Tliq
                        s_fs(i,j,k) = 0;
                        
%                         s_undercooling(i,j,k) = undercooling_add_value;
                        
                    elseif T(i,j,k) <Tliq && T(i,j,k) > Tsol
                       s_fs(i,j,k) = 1-(T(i,j,k)-Tsol)/(Tliq - Tsol);
                       
%                         s_undercooling(i,j,k) = T(i,j,k)-Tsol+undercooling_add_value;
                    elseif T(i,j,k) <= Tsol
                        s_fs(i,j,k) = 1;
                        
%                         s_undercooling(i,j,k) = undercooling_add_value;
                    else                    
                        s_fs(i,j,k) = 1;
                    end
                    
                end
            end
        end
        end
        
        
%         disp('in function "FUNC_INITIALISE_STRUCT_PORTIONS3D.m  solid fraction assigned to 0.5!!!!!')
%             s_fs(:,:,:)=0.5;
        
        structure = struct;
        structure.temp = s_temp;
        structure.fs = s_fs;
        structure.alpha = s_alpha;
        structure.beta = s_beta;
        structure.gamma = s_gamma;
        structure.deltaTime = s_deltaTime;
        structure.length = s_length;
        structure.undercooling = s_undercooling;
        
        save('initialised.mat')
        


        % plotting
        if 0
            alpha = 0.1;
            plot_variable = structure.fs;
%             plot_variable = reshape (plot_variable, n,m,l);
            
            slice(xi, yi, zi, plot_variable, xslice, yslice, zslice);
            axis equal
            colorbar;
        end

    end
end

