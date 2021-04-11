function struct = ...
     func_growth_in_sl_parallel3D(active, struct, timelimit, timestep, dx, xmin,ymin,zmin, pos) % struct,active, Tliq, Tsol, A, dx,dy, n,m, timelimit)
% creating a struct updated with solution for current meshstep
 
%% SIMULATION PARAMETERS AND MESH
A = 10^-4;              % undercooling constant (for Ni based superalloys)
%[xi,yi, zi] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zmin:dz:zmax);
s = size(struct.temp);
n=s(1);m=s(2);l=s(3);
dy=dx;dz=dx;
globaltime = 0;time_ind=0;
add_to_active=single([]);
remove_from_active = single([]);
finished = 0;

bool_plot_cube = 0;            % plotting cubes doesn't work in multithread
bool_plot_neighbour = 0; 
bool_plot_active = 0;
bool_plot_active_midplane = 0;
bool_plot_new_octa = 0;  % plotting octahedrons around new captured cells
bool_plot_remvoe_from_active = 0;
bool_plot_fs = 0;
bool_plot_window = 0;


%% plot parameters
alpha_plt = 0.025; %0.5
sz=500;
cube=0;
if bool_plot_window == 1
    % PREPARING FURTHER PLOT
    % f = figure('Position',[2600 100 1200 900]);
%     close all;    
%     hold on;
    f = figure('Position',[0 50 1200 570]);
%     ax = gca;
%     grid on;grid minor;
%     axis equal;view(90,90);
    movegui(f);
    view(90,90)
end
%% main loop:
while globaltime<timelimit &&~finished 
       
%     clf;
    
    tic    
    time_ind = time_ind+1;
    fprintf('timestep No. %.d \n', time_ind)     
    globaltime = time_ind*timestep;
    
    add_to_active = [];
    remove_from_active = [];

    add_to_active = nan(length(active(:,1))*26,3);
    remove_from_active = nan(length(active(:,1))*26,3);
    
    %% GRAIN LOOP:   ************
    length_array = struct.length(:,:,:);
    alpha_array = struct.alpha(:,:,:);
    beta_array = struct.beta(:,:,:);
    gamma_array = struct.gamma(:,:,:);
    fs_array = struct.fs(:,:,:);
    undercooling_array = struct.undercooling(:,:,:);
    
    for grain=1:length(active(:,1))
        % assign points:
        x = active(grain,1);
        y = active(grain,2);
        z = active(grain,3);
        
        % calculating length based on speed of interface advance. Add init.
        % length? 
        
        length_array(x,y,z) = length_array(x,y,z) + A*undercooling_array(x,y,z).^2*timestep;
        
        % calculating points:
        octahedron_points = func_calculate_points3D([x,y,z],...
                       xmin, ymin, zmin,dx, ...
                       alpha_array(x,y,z),beta_array(x,y,z),gamma_array(x,y,z),length_array(x,y,z));
%                             alpha beta gamma
        

        %% assign neighbours
        neigh = func_assign_neighbuor(active, grain, n,m,l);
        
        neigh_fs = NaN(length(neigh),1);
        % assigning fs vaues for each neighbour:
        for p=1:length(neigh) 
            neigh_fs(p) = fs_array(neigh(p,1),neigh(p,2),neigh(p,3));
        end
        
        % check if 6 main neighbours are solid: 
        if length(neigh(:,1)) == 26 && sum(neigh_fs(1:6))>= 6
            remove_from_active = [remove_from_active; x y z];%                     
        elseif  sum(neigh_fs(1:5))>= 5
            remove_from_active = [remove_from_active; x y z];
        end 
        
        %% CHECKING IF THE GRAINS ARE INSIDE:
        % check if length is bigger than min length to avoid some
        % unneccessary computations
        if length_array(x,y,z) < dx/2  % dx % length 
            captured_ijk = 0; % skips checking of cubes that are too small. Saves time at the beginning.
        else % length is perhaps sufficient: 
            % bool vector IsCaptured:
            IsCaptured = logical(func_check_inside3D(octahedron_points, func_ijk_to_xyz(neigh, dx,xmin,ymin,zmin)));
            
            % if some of the points were captured, add them to new list of
            % active cells:
            if any(IsCaptured, 'all')
                % removing values that are not captured:
                captured_ijk = neigh.*(IsCaptured);
                % removing zero rows:
                captured_ijk( ~any(captured_ijk ,2), : ) = [];
                
                % iterating through all the captured neighbours:
                for p=1:length(captured_ijk(:,1))  
                % if the cell is also not solid or liquid:
                    if neigh_fs(p) < 1 && neigh_fs(p) > 0 
                        % adding to new active cells:            
                        
%                         add_to_active = [add_to_active; captured_ijk(p,1:3)];
                        add_to_active(p*grain,:) = captured_ijk(p,1:3);
                        
                        
                        % assigning new length of the octahedron:
                        length_array(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                        func_calculate_grain_length(octahedron_points,func_ijk_to_xyz(captured_ijk(p,:), dx,xmin,ymin,zmin), 0);
                        
                        % assigning orientations:
                        alpha_array(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                            alpha_array(x,y,z);
                        beta_array(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                            beta_array(x,y,z);
                        gamma_array(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                            gamma_array(x,y,z);
                        % assigning time when captured: (optional?)
                        struct.deltaTime(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                            globaltime;                        
                        % assigning solid fraction to unity:
                        fs_array(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3)) = 1;                        
                    end
                end                
            end
        end       
        
        %% plotting operations for each grain:
        % plotting cubes
        if bool_plot_cube ==1 % && n_th==1                
%             hold on
            colour = round([alpha_array(x,y,z)/pi*2,...
                            beta_array(x,y,z)/pi*2,...
                            gamma_array(x,y,z)/pi]*10)/10; %round([act(grain,4),act(grain,5),act(grain,6)]/pi)
            plot_octahedron(octahedron_points, colour, alpha_plt)
            axis equal
            view(90,0)
            pause(0.0001)
        end
        
        % plotting neighbours (debugging)
        if bool_plot_neighbour == 1
%             hold on
            plot_coord_from_ijk(neigh, dx, xmin, ymin,zmin, sz/10, 'cyan')
%             axis equal
%             grid minor
            pause(1/10000)
        end

    end  % end of loop through active grains    
    
    % reassigning to struct:
    
     struct.length = length_array(:,:,:);
    struct.alpha = alpha_array(:,:,:);
    struct.beta = beta_array(:,:,:);
    struct.gamma = gamma_array(:,:,:);
    struct.fs = fs_array(:,:,:);    
    struct.undercooling = undercooling_array(:,:,:);
    % --------------------------------------------------------------------    
    %% PLOTTING BLOCK
    % assigning fs=1 to active cells:
    for pointer=1:length(active(:,1))
        fs_array(active(pointer,1),active(pointer,2),active(pointer,3)) = 1;
    end
    
    % plotting fs==1 points in blue:
    if bool_plot_fs == 1
        fs_points=[];
        for i1=1:n
            for j1=1:m
                for k1=1:l
                    if fs_array(i1,j1,k1) > 0.99
                        fs_points = [fs_points; i1 j1 k1];
                    end
                end
            end
        end
        
        if ~isempty(fs_points)
            plot_coord_from_ijk(fs_points, dx, xmin, ymin,zmin, sz/2, 'blue')
            pause(0.001)
        end
    end
    
    if bool_plot_active == 1
%         hold on
        plot_coord_from_ijk(active, dx, xmin, ymin,zmin, sz/100, 'red')
%         plot_struct_same_figure(struct,n,m,l, pos)
        pause(1/10000)
    end
    
    % plotting active    
    if bool_plot_active_midplane == 1
%         hold on
        % kij
        new_active = active(active(:,1)==round(n/2),:);
        plot_coord_from_ijk(new_active, dx, xmin, ymin,zmin, sz/100, 'red')
        plot_struct_same_figure(struct,n,m,l, pos)
        pause(1/10000)
    end
 
    
    if bool_plot_remvoe_from_active == 1
%         hold on
        if ~isempty(remove_from_active)
            plot_coord_from_ijk(remove_from_active, dx, xmin, ymin,zmin, sz/1, 'black')
            pause(1/10000)
            
        end
    end
    % plotting OCTAHEDRONS OF NEWLY CAPTURED CELLS
    if bool_plot_new_octa == 1
        hold on
        if ~isempty(add_to_active)
            for plot_Var=1:length(add_to_active(:,1))
                xp = add_to_active(plot_Var,1);
                yp = add_to_active(plot_Var,2);
                zp = add_to_active(plot_Var,3);
                hold on
                if length_array(xp,yp,zp)>0
                    
                    octahedron_points = func_calculate_points3D([xp,yp,zp],...
                                   xmin, ymin, zmin,dx, ...
                                   alpha_array(xp,yp,zp),beta_array(xp,yp,zp),gamma_array(xp,yp,zp),length_array(xp,yp,zp));
            %                             alpha beta gamma
                    % plotting cubes
                    colour = [1, 0, 0]; %round([alpha_array(xp,yp,zp),alpha_array(xp,yp,zp),alpha_array(xp,yp,zp)]/pi*10)/10; 
                    plot_octahedron(octahedron_points, colour, alpha_plt)
%                     axis equal
                    pause(0.0001)
                end
            end
        end
    end
    
    pause(1/1000);  
    toc  
    % --------------------------------------------------------------------
    %% OPERATIONS WITH ACTIVE, ADD_TO_ACTIVE, AND REMOVE_FROM_ACTIVE:
    
    add_to_active = add_to_active(all(~isnan(add_to_active),2),:);
    % adding to active and removing add_to_active matrix:
    if ~isempty(add_to_active)
        % removing all nan values:
        active = [active; add_to_active];
        add_to_active=[];
    end
    
    % removing zero rows:
    remove_from_active( ~any(remove_from_active,2), : ) = [];
    
        remove_from_active = remove_from_active(all(~isnan(remove_from_active),2),:);
    % removing similar rows in active and disabled active:
    if ~isempty(remove_from_active)
        % removing all nan values:
        active = setdiff(active, remove_from_active, 'rows'); % 
        remove_from_active=[];
    end    
    
    if bool_plot_active==1
    end
    
    unique(active, 'rows');
    % if there are no active points at this timestep => finish timeloop uj   
    if isempty(active)
        disp('no active cells. finishing timeloop...')
        finished = 1;
    end
%     
end % OF TIMELOOP
close;
end % of the function
