function struct = ...
     func_growth_in_sl3D(active, struct, timelimit) % struct,active, Tliq, Tsol, A, dx,dy, n,m, timelimit)


% **********************************************************************
%%                      GROWTH IN ONE s-l 
%  **********************************************************************


%% reading. COMMENT FOR THE SPEED ONCE READ

% active=open('active.mat').active;
% struct=open('Struct_mesh.mat').struct;
inputs=open('InterpolatedTemperatureGrid.mat');  % only for grid values (No T) 
xi = inputs.xi;
yi = inputs.yi;
zi = inputs.zi;
T = inputs.vq;
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

%}


% end of temprorary comment

%% SIMULATION PARAMETERS AND MESH

A = 10^-4;              % undercooling constant (for Ni based superalloys)
dx = 25e-3; % mm    
dy = dx;     % uniform array
dz = dx;     % uniform array
%[xi,yi, zi] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zmin:dz:zmax);
s = size(struct);
n=s(1);
m=s(2);
l=s(3);
globaltime = 0;
time_ind=0;
vmax = max(vertcat(struct.undercooling)).^2*A;
add_to_active=[];
remove_from_active = [];
finished = 0;
%%  step 1: (Not Necceccary???)  set upper surface to solid and remove active cells from the
% surface
if 0
    for i=1:n
        for j=1:m
            for k=l
                %struct(i,j,k).fs=1;
            end
        end
    end
end

%% TIMESTEP PARAMETER AND INITIALISATION

NUMBER_OF_TIMESTEPS =100;
NUMBER_OF_GRAINS = 1;

bool_plot_window = 0;    % plotting the figure window (with active grains)
bool_plot_cubes = 0;   % plotting cubes
bool_plot_struct = 0;  % reforming struct and plotting
bool_plot_initial = 0;   % plotting initial points
bool_plot_neighbour = 0; % plotting neighbours
plot_new_captured = 0;   % plotting captured grains in green

bool_plot_checker = 0;

% plot parameters
alpha_plt = 0.75; %0.5
sz=500;

%timestepping
timestep = dx/(2*sqrt(2)* vmax); % 10 timesteps per square % CHANGE COEFFICIENT TO >=2
%timelimit = timestep*NUMBER_OF_TIMESTEPS; %0.04;  % nnow that is an input

GRAIN_NUMBER = 100;
%active = active(GRAIN_NUMBER:NUMBER_OF_GRAINS+GRAIN_NUMBER-1,:); % working with first grain only


%% Plotting an ampty figure
if bool_plot_window == 1
    % PREPARING FURTHER PLOT
    f = figure('Position',[2600 100 1000 600]);
    movegui(f);
    axis equal
    hold on
    view(80,10)
end


%% MAIN TIME LOOP
while globaltime<timelimit &&~finished 

    cube = 0;
    hold on
    % preparation
    init_point_index = 1; 
    time_ind = time_ind+1;
    fprintf('\ntimestep No. %.d: \n\n', time_ind)
    tic
    globaltime = time_ind*timestep;  
    %disp('time per timestep calc:')
    
    %plotting actove grains
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%        GRAIN LOOP INSIDE THE TIME LOOP:               %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for grain=1:length(active(:,1))
              
        % initialisation of the grain, position length, and cubic points
        i = active(grain, 1);
        j = active(grain, 2);
        k = active(grain, 3);
        
        if k == 0
            error('k=0!')
        end
        
        
        % fprintf('\n***\n Grain number: %.f\n', grain)
        
        vtip = A*struct(i,j,k).undercooling.^2;
        
        % loading initial coordinates of the cube [x,y,z]
        % initial_coordinates = struct(i,j,k).init_point;     
        %% PLOTTING
        % WHY MESSED UP 2 AND 1 WHEN PLOTTING?
        %plot_cube_init_coordinates(grain,:)=[initial_coordinates(1), initial_coordinates(2), initial_coordinates(3)];
            
        
        % undercooling of the cell is constant here
        initial_coordinates = [(active(grain,2)-1)*dy+xmin,(active(grain,1)-1)*dy+ymin,(active(grain,3)-1)*dz+zmin];
        
        % initial_coordinates = [initial_coordinates(2), initial_coordinates(1), initial_coordinates(3)];
        struct(i,j,k).length = (vtip*(globaltime - struct(i,j,k).deltaTime));      
        
        % Calculating cubic points
        cubic_points = func_calculate_cubic_points3D(initial_coordinates,...
                                       struct(i,j,k).alpha,...
                                       struct(i,j,k).beta,...
                                       struct(i,j,k).gamma,...
                                       struct(i,j,k).length);
        
        % %%%%%%%%%%*******************************************************
        %% ASSIGNING THE NEIGHBOURS!           ***************************
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if k == 1 % bottom plane
            neigh = [
             [i+1,j,  k+1]; [i,  j-1,k+1]; [i-1,j,  k+1]; [i,  j+1,k+1]; [i,j,k+1];       %higher z plane
             [i+1,j+1,k+1]; [i+1,j-1,k+1]; [i-1,j-1,k+1]; [i-1,j+1,k+1];
             [i+1,j,  k];   [i,  j-1,k];   [i-1,j,  k];   [i,  j+1,k];  %middle z plane
             [i+1,j+1,k];   [i+1,j-1,k];   [i-1,j-1,k];   [i-1,j+1,k];                 
             %[i+1,j,  k-1]; [i,  j-1,k-1]; [i-1,j,  k-1]; [i,  j+1,k-1]; [i,j,k-1];       %higher z plane
             %[i+1,j+1,k-1]; [i+1,j-1,k-1]; [i-1,j-1,k-1]; [i-1,j+1,k-1];
                     ];   %(x,y, z)
                 
        elseif k == l % K = EL, top plane
            
            neigh = [
            [i+1,j,  k];   [i,  j-1,k];   [i-1,j,  k];   [i,  j+1,k];  %middle z plane
            [i+1,j+1,k];   [i+1,j-1,k];   [i-1,j-1,k];   [i-1,j+1,k];                 
            [i+1,j,  k-1]; [i,  j-1,k-1]; [i-1,j,  k-1]; [i,  j+1,k-1]; [i,j,k-1];       %higher z plane
            [i+1,j+1,k-1]; [i+1,j-1,k-1]; [i-1,j-1,k-1]; [i-1,j+1,k-1];
                 ];   %(x,y, z)
            
        else 
            neigh = [
             [i+1,j,  k+1]; [i,  j-1,k+1]; [i-1,j,  k+1]; [i,  j+1,k+1]; [i,j,k+1];       %higher z plane
             [i+1,j+1,k+1]; [i+1,j-1,k+1]; [i-1,j-1,k+1]; [i-1,j+1,k+1];
             [i+1,j,  k];   [i,  j-1,k];   [i-1,j,  k];   [i,  j+1,k];  %middle z plane
             [i+1,j+1,k];   [i+1,j-1,k];   [i-1,j-1,k];   [i-1,j+1,k];                 
             [i+1,j,  k-1]; [i,  j-1,k-1]; [i-1,j,  k-1]; [i,  j+1,k-1]; [i,j,k-1];       %higher z plane
             [i+1,j+1,k-1]; [i+1,j-1,k-1]; [i-1,j-1,k-1]; [i-1,j+1,k-1];
                     ];   %(x,y, z)

        end
        
        % fprintf('i= %.1f, j=%.1f, k=%.1f \n', i, j, k)
        
        initial_coordinates = [(active(grain,2)-1)*dy+xmin,(active(grain,1)-1)*dy+ymin,(active(grain,3)-1)*dz+zmin];
        if bool_plot_neighbour == 1
            scatter3((neigh(:,2)-1).*dx+xmin, (neigh(:,1)-1).*dy + ymin, (neigh(:,3)-1).*dz+zmin, sz/10, 'filled', 'black')
            pause(1/10000)
        end
        
        % checking each neighbour and reassigning the values if inside
        
        number_of_neighbours = length(neigh(:,1));
        
        for p=1:length(neigh(:,1)) % 26  % p for neighbour
            
            
             %fprintf('***Neigh num: %.f \n', p)
            [bool,cx,cy,cz, Lnew] = func_check_inside3D(cubic_points, ... 
                [(neigh(p,2)-1).*dx+xmin, (neigh(p,1)-1).*dy + ymin, (neigh(p,3)-1).*dz+zmin],dx,dy,dz,i,j,k,...  % neigh(p,:).*dx
                struct(i,j,k).length, ...
                struct(i,j,k).alpha, ... 
                struct(i,j,k).beta, ...
                struct(i,j,k).gamma, initial_coordinates);  % checks if the point is within
           
            
            %% CAPTURED!!! REASSIGNING THE GRAIN
            % if within the recangle, not solid, and different grain:
                        
            if bool ==1 
                %fprintf('Lnew = %.4f \n', Lnew)
                if struct(neigh(p,1),neigh(p,2),neigh(p,3)).fs ~= 1  % if not solid
                    %fprintf('NEIGHBOUR IS NOT SOLID!\n')
                    if 1 %struct(neigh(p,1),neigh(p,2),neigh(p,3)).grain ~= struct(i,j,k).grain  % if not this grain already
                        %% assigning values: grain indetification, orientation
                        
                        struct(neigh(p,1),neigh(p,2),neigh(p,3)).grain =...
                            struct(i,j,k).grain;
                        struct(neigh(p,1),neigh(p,2),neigh(p,3)).alpha=...
                            struct(i,j,k).alpha;
                        struct(neigh(p,1),neigh(p,2),neigh(p,3)).beta=...
                            struct(i,j,k).beta;
                        struct(neigh(p,1),neigh(p,2),neigh(p,3)).gamma=...
                            struct(i,j,k).gamma;
                        
                        
                        struct(neigh(p,1),neigh(p,2),neigh(p,3)).deltaTime=...
                            globaltime;
                        struct(neigh(p,1),neigh(p,2),neigh(p,3)).fs = 1;
                        struct(neigh(p,1),neigh(p,2),neigh(p,3)).init_point = [cx,cy,cz];
                        struct(neigh(p,1),neigh(p,2),neigh(p,3)).length = Lnew/10;
                        
                        % assigning the point to solid
                        struct(i,j,k).fs = 1;
                        
                        % adding a point to active point
                        % disp('added to active.')
                        add_to_active = [add_to_active; neigh(p,1),neigh(p,2),neigh(p,3)];
                        
                        if plot_new_captured==1
                            scatter3((neigh(p,2)-1).*dx+xmin, (neigh(p,1)-1).*dy + ymin, (neigh(p,3)-1).*dz+zmin, sz, 'filled', 'green')
                            
                        end
                        % scatter3(neigh(:,2).*dx+xmin, neigh(:,1).*dy + ymin, neigh(:,3).*dz+zmin, sz/10, 'filled', 'green', 'MarkerEdgeAlpha',0.5)
                    end
                end
            end % end of if 
        end  % end of neighbour loop
        
        %% CHECKING THE NEIGHBOURS AND REMOVING THE INACTIVE GRAINS.
        % if 6 chosen Moore neighbours are solid (1 top, 4 sides, 1 bottom):   
        total = 0;
        if length(neigh(:,1)) == 17
            for p=[5, 10:13]
                %scatter3(neigh(p,2).*dx+xmin, neigh(p,1).*dy + ymin, neigh(p,3).*dz+zmin, sz, 'filled', 'red')                 
                if struct(neigh(p,1),neigh(p,2),neigh(p,3)).fs == 1
                    total = total + 1;
                end
            end
            
            if total == 5
                remove_from_active = [remove_from_active; i,j,k];
            end       
        
        else
            for p=[5, 10:13,22]
                %scatter3(neigh(p,2).*dx+xmin, neigh(p,1).*dy + ymin, neigh(p,3).*dz+zmin, sz, 'filled', 'red')                 
                if struct(neigh(p,1),neigh(p,2),neigh(p,3)).fs == 1
                    total = total + 1;
                end
            end
            if total == 6
                remove_from_active = [remove_from_active; i,j,k];
            end       
        
        end
        
        if 0 % struct(neigh(1,2),neigh(1,1)).fs == 1
            if struct(neigh(2,2),neigh(2,1)).fs == 1
                if struct(neigh(3,2),neigh(3,1)).fs == 1
                    if struct(neigh(4,2),neigh(4,1)).fs == 1 
                        if struct(neigh(5,2),neigh(5,1)).fs == 1 
                            if struct(neigh(6,2),neigh(6,1)).fs == 1 
                                if struct(neigh(7,2),neigh(7,1)).fs == 1
                                    if struct(neigh(8,2),neigh(8,1)).fs == 1    
                                        fprintf('item removed!\n')
                                        remove_from_active = [remove_from_active; j,i];
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end % end of neighbours
        
        
        
        
        %% PLOTTING THE CUBES ON THE SAME PLOT 
        if bool_plot_cubes ==1 
            cube = cube+1            
            %% plot the cube 
            % cubic points             
            x1 = cubic_points(1:4,1).'; % front wall
            y1 = cubic_points(1:4,2).'; 
            z1 = cubic_points(1:4,3).'; 
            x2 = cubic_points(5:8,1).'; % back wall
            y2 = cubic_points(5:8,2).'; 
            z2 = cubic_points(5:8,3).'; 
            x3 = [cubic_points(1:2,1).' cubic_points(6,1) cubic_points(5,1)]; % right wall
            y3 = [cubic_points(1:2,2).' cubic_points(6,2) cubic_points(5,2)]; 
            z3 = [cubic_points(1:2,3).' cubic_points(6,3) cubic_points(5,3)]; 
            x4 = [cubic_points(3:4,1).' cubic_points(8,1) cubic_points(7,1)]; % left wall
            y4 = [cubic_points(3:4,2).' cubic_points(8,2) cubic_points(7,2)]; 
            z4 = [cubic_points(3:4,3).' cubic_points(8,3) cubic_points(7,3)]; 
            x5 = [cubic_points(1,1) cubic_points(4,1) cubic_points(8,1) cubic_points(5,1)]; % top wall
            y5 = [cubic_points(1,2) cubic_points(4,2) cubic_points(8,2) cubic_points(5,2)]; 
            z5 = [cubic_points(1,3) cubic_points(4,3) cubic_points(8,3) cubic_points(5,3)]; 
            x6 = [cubic_points(2,1) cubic_points(3,1) cubic_points(7,1) cubic_points(6,1)]; % top wall
            y6 = [cubic_points(2,2) cubic_points(3,2) cubic_points(7,2) cubic_points(6,2)]; 
            z6 = [cubic_points(2,3) cubic_points(3,3) cubic_points(7,3) cubic_points(6,3)]; 

            
            % assign the color of the cube based on the orientation
            colour = [struct(i,j,k).alpha struct(i,j,k).beta struct(i,j,k).gamma]/pi*4;
            
            hold on
            %DRAWING THE CUBE
            fill3(x1, y1, z1, colour, 'FaceAlpha',alpha_plt)
            fill3(x2, y2, z2, colour, 'FaceAlpha',alpha_plt)
            fill3(x3, y3, z3, colour, 'FaceAlpha',alpha_plt)
            fill3(x4, y4, z4, colour, 'FaceAlpha',alpha_plt)
            fill3(x5, y5, z5, colour, 'FaceAlpha',alpha_plt)
            fill3(x6, y6, z6, colour, 'FaceAlpha',alpha_plt)
            
            pause(1/10000)
            %% plot the rest! ***************** PLOT COORDINATES HERE! ***
            % initial point of the cube:        
        end
        
        
        
    end   % *****************end of iteration through grains***************
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%      OPERATIONS IN CURRENT TIMESTEP             %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    active = [active; add_to_active];
    active = unique(active,'rows');
    add_to_active=[];
    
    if ~isempty(remove_from_active)
        active = setdiff(active, remove_from_active, 'rows', 'stable');
        remove_from_active=[];
    end
    
    
    
    
    
    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                    PLOTTING EACH TIMESTEP              %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    %% PLOTTING STRUCT !!!
     if bool_plot_struct == 1        
        fs = [struct.alpha];
        fs = reshape(fs,n,m,l);
        h = slice(xi, yi, zi, fs, xslice, yslice, zslice);
        
%         set(h,'EdgeColor','none',...
%         'FaceColor','interp',...
%         'FaceAlpha','interp');
%         alpha('color');
% 
%         cm_plasma=colormap_plasma(100);
%     %         alphamap('rampdown')  
%         colormap(cm_plasma) %hot hsv
%         colormap(hot) %hot hsv
%         alphamap('increase',0.001)
%         colorbar;
%         pause(1/1000)
        
        
        
        
     end
    
    if bool_plot_initial == 1    
        orient_active = zeros(length(active(:,1)),3);
        
        for p =1:length(active(:,1))
            orient_active(p,:) = [struct(active(p,1),active(p,2),active(p,3)).alpha...
                             struct(active(p,1),active(p,2),active(p,3)).beta ...
                             struct(active(p,1),active(p,2),active(p,3)).gamma]*0.784;
            
                         
                     
        end
        
        scatter3((active(:,2)-1)*dy+xmin,(active(:,1)-1)*dy+ymin,(active(:,3)-1)*dz+zmin,sz,orient_active(:,:),'filled')
       
    end
%     
%      axis equal
%     grid on
%     pause(1/1000)
%     pause(1/1000)
    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                      FINISHING OPERATIONS - CHECKS      %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   
    
    if isempty(active)
        fprintf('no active cells found. Finishing the growth loop...')
        finished=1;
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         OLD VERSION     %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0    
    
    toc  
    % adding new active cells to active: 
    
    if ~isempty(remove_from_active)
        % remove_from_active= ue(remove_from_active, 'rows');
        % scatter(remove_from_active(:,1),remove_from_active(:,2), 10, 'd', 'yellow', 'filled');
        
        pause(0.00001);
%          active = setdiff(active, remove_from_active, 'rows', 'stable');
        remove_from_active = [];
    end
    
    %% PLOTTING
    % change to "if 1" when needed
    while 0         
        xmin = 1;
        xmax = 400;

        if rem(time_ind, 100) == 0 % PLOTTING EVERY _num_ STEP

            % rewriting values
            for u=1:n
                for p=xmin:xmax
                    temp(u,p) = struct(u,p).temp;
                    cooling(u,p) = struct(u,p).undercooling;
                    grain(u,p) = struct(u,p).grain;
                    orientation(u,p) = struct(u,p).orientation;
                    fs(u,p) = struct(u,p).fs;
                    length_p(u,p) = struct(u,p).length;
                    deltaTime(u,p) = struct(u,p).deltaTime;
                end
            end

            act_x = zeros(1,length(active(:,1)));
            act_y = zeros(1,length(active(:,1)));
            for gamma = 1:length(active(:,1))
                act_x(gamma) = active(gamma,2);
                act_y(gamma) = active(gamma,1);
            end

    %         
    %         ax(1)=subplot(2,1,1);
    %         hold on
    %         imagesc(fs);
    %         scatter(act_y,act_x, 'g')
    %         colorbar;
    %         pause (0.001);   
    %         hold off


            ax(2)=subplot(2,1,2);    
            hold on
            scatter(cubic_points(:,1)/dx, cubic_points(:,2)/dy,'r')  % shows growing rectangle 
            pause (0.00001);

            imagesc(orientation);
            fprintf('time=%2.2f s; active_cells=%3f.\n', globaltime, length(active(:,1)));

            disp('time per plot each timestep:')

            xlim([xmin xmax])
            %imagesc(fs);
            colormap gray
            colorbar;
            scatter(act_y,act_x, 'g')
            %scatter(initial_points_plot(:,1),initial_points_plot(:,2),'m')


            % input('press any key')

            pause(0.00000001) 

            hold off
            disp('')
        end  % end of plotting    
        

    end  
    
    %% FINISHING THE LOOP IF THERE IS NO ACTIVE CELLS.
    if isempty(active)
        fprintf('no active cells found. Finishing the growth loop...')
        finished=1;
    end
    
end %% end of timeloop
       
%end
