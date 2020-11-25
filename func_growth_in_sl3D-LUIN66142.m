% function struct = ...
%     func_growth_in_sl(struct,active, Tliq, Tsol, A, dx,dy, n,m, timelimit)


% **********************************************************************
%%                      GROWTH IN ONE s-l 
%  **********************************************************************

close all;
%% reading 
%TEMPRORARILY COMMENTED!! UNCOMMENT WHEN FINISHED

clear all;

active=open('active.mat').active;
struct=open('struct.mat').struct;
inputfile = 'MeltPoolExtended.csv';
rows = csvread(inputfile);
x = rows(:,1);y = rows(:,2);z = rows(:,3);v = rows(:,4);
xmin = min(x);xmax = max(x);
ymin = min(y);ymax = max(y);
zmin = min(z);zmax = max(z);    

%}

% end of temprorary comment

%% SIMULATION PARAMETERS AND MESH
A = 10^-4;              % undercooling constant (for Ni based superalloys)
dx = 25e-3; % mm    
dy = dx;     % uniform array
dz = dx;     % uniform array
[xi,yi, zi] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zmin:dz:zmax);
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
active = active(1:3,:); % working with first grain only

%%  step 1: (Not Necceccary???)  set upper surface to solid and remove active cells from the
% surface
for i=1:n
    for j=1:m
        for k=l
            %struct(i,j,k).fs=1;
        end
    end
end

%% TIMESTEP PARAMETER AND INITIALISATION

NUMBER_OF_TIMESTEPS = 2;
bool_plot_window = 1;    % plotting the figure window (with active grains)
bool_plot_cubes = 1  ;   % plotting cubes
bool_plot_struct = 1  ;  % reforming struct and plotting

timestep = dx/(0.2*sqrt(2)* vmax); % 10 timesteps per square % CHANGE COEFFICIENT TO >=2
timelimit = timestep*NUMBER_OF_TIMESTEPS; %0.04;

%% Plotting an ampty figure
if bool_plot_window == 1
    % PREPARING FURTHER PLOT
    f = figure('Position',[2600 100 1000 600]);
    movegui(f);
    % plot parameters
    alpha = 0.5;
    sz=500;
end

%% MAIN TIME LOOP
while globaltime<timelimit &&~finished 
    init_point_index = 1; 
    time_ind = time_ind+1;
    
    fprintf('\ntimestep No. %.d: \n\n', time_ind)
    
    globaltime = time_ind*timestep;  
    
    %disp('time per timestep calc:')
    %tic
    
    %plotting actove grains
    if bool_plot_window == 1
        scatter3(active(:,1)*dx,active(:,2)*dy,active(:,3)*dz,'red','filled')
        axis equal
        grid on
        view([15 15])
        pause(1/1000)
    end
    
    %% grain loop.
    for grain=1:length(active(:,1))
        
        % initialisation of the grain, position length, and cubic points
        i = active(grain, 1);
        j = active(grain, 2);
        k = active(grain, 3);
        vtip = A*struct(i,j,k).undercooling.^2;
        
        % loading initial coordinates of the cube [x,y,z]
        initial_coordinates = struct(i,j,k).init_point;
        
        % undercooling of the cell is constant here
        struct(i,j,k).length = (vtip*(globaltime - struct(i,j,k).deltaTime));      
        
        % Calculating cubic points
        cubic_points = func_calculate_cubic_points3D(initial_coordinates,...
                                       struct(i,j,k).alpha,...
                                       struct(i,j,k).beta,...
                                       struct(i,j,k).gamma,...
                                       struct(i,j,k).length);
         
        % assigning neighbours
        if k<l % if not the top
             %      X  Y Z. neighbouring cells. ORDER MIGHT BE WRONG!
            neigh = [
             [i+1,j,  k+1]; [i,  j-1,k+1]; [i-1,j,  k+1]; [i,  j+1,k+1]; [i,j,k+1];       %higher z plane
             [i+1,j+1,k+1]; [i+1,j-1,k+1]; [i-1,j-1,k+1]; [i-1,j+1,k+1];
             [i+1,j,  k];   [i,  j-1,k];   [i-1,j,  k];   [i,  j+1,k];  %middle z plane
             [i+1,j+1,k];   [i+1,j-1,k];   [i-1,j-1,k];   [i-1,j+1,k];                 
             [i+1,j,  k-1]; [i,  j-1,k-1]; [i-1,j,  k-1]; [i,  j+1,k-1]; [i,j,k-1];       %higher z plane
             [i+1,j+1,k-1]; [i+1,j-1,k-1]; [i-1,j-1,k-1]; [i-1,j+1,k-1];
                     ];   %(x,y, z)
        else 
             neigh = [

             [i+1,j,  k];   [i,  j-1,k];   [i-1,j,  k];   [i,  j+1,k];  %middle z plane
             [i+1,j+1,k];   [i+1,j-1,k];   [i-1,j-1,k];   [i-1,j+1,k];                 
             [i+1,j,  k-1]; [i,  j-1,k-1]; [i-1,j,  k-1]; [i,  j+1,k-1]; [i,j,k-1];       %higher z plane
             [i+1,j+1,k-1]; [i+1,j-1,k-1]; [i-1,j-1,k-1]; [i-1,j+1,k-1];
                     ];   %(x,y, z)
        end
                                  
        %% PLOTTING THE CUBES ON THE SAME PLOT 
        if bool_plot_cubes ==1 
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
            color = [struct(i,j,k).alpha struct(i,j,k).beta struct(i,j,k).gamma]/3.14;
            
            hold on
            %DRAWING THE CUBE
            fill3(x1, y1, z1, color, 'FaceAlpha',alpha)
            fill3(x2, y2, z2, color, 'FaceAlpha',alpha)
            fill3(x3, y3, z3, color, 'FaceAlpha',alpha)
            fill3(x4, y4, z4, color, 'FaceAlpha',alpha)
            fill3(x5, y5, z5, color, 'FaceAlpha',alpha)
            fill3(x6, y6, z6, color, 'FaceAlpha',alpha)
            
            
            %% plot the rest! ***************** PLOT COORDINATES HERE! ***
            % initial point of the cube:        
            scatter3(initial_coordinates(1), initial_coordinates(2), initial_coordinates(3), sz/100, 'red')
            
            % plotting all neighbours
            scatter3(neigh(:,1).*dx, neigh(:,2).*dy, neigh(:,3).*dz, sz/10, 'filled', 'cyan')
            
            pause(1/10000)
        end
        
        % checking each neighbour and reassigning the values if inside
        for p=1:length(neigh(:,1)) % 26  % p for neighbour
            
            [bool,cx,cy,xz Lnew] = func_check_inside3D(cubic_points, ... 
                neigh(p,:).*dx,dx,dy,dz,i,j,k,...
                struct(i,j,k).length, ...
                struct(i,j,k).alpha, ... 
                struct(i,j,k).beta, ...
                struct(i,j,k).gamma, initial_coordinates);  % checks if the point is within
            
            
            % if within the recangle, not solid, and different grain:
            if bool ==1 
                if struct(neigh(p,1),neigh(p,3),neigh(p,3)).fs ~= 1  % if not solid
                    if struct(neigh(p,2),neigh(p,1)).grain ~= struct(i,j).grain  % if not this grain already
                        %% assigning values: grain indetification, orientation
                        struct(neigh(p,2),neigh(p,1)).grain=...
                            struct(i,j).grain;
                        struct(neigh(p,2),neigh(p,1)).orientation=...
                            struct(i,j).orientation;
                        struct(neigh(p,2),neigh(p,1)).deltaTime=...
                            globaltime;
                        struct(neigh(p,2),neigh(p,1)).fs = 1;
                        struct(neigh(p,2),neigh(p,1)).init_point = [cx,cy];
                        struct(neigh(p,2),neigh(p,1)).length = Lnew;
                        
                        % assigning the point to solid
                        struct(i,j,k).fs = 1;
                        
                        % adding a point to active point
                        add_to_active = [add_to_active; neigh(p,1),neigh(p,2)];
                    end
                end
            end % end of if 
        end  % end of neighbour loop
        
        % if Moore neighbours are solid:
        
        if struct(neigh(1,2),neigh(1,1)).fs == 1
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
        
        
        
        
        
        
    end   % end of iteration through grains
    
    % adding new active cells to active: 
    active = [active; add_to_active];
    add_to_active=[];
    
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
