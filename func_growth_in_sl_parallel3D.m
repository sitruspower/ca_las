function struct = ...
     func_growth_in_sl_parallel3D(active, struct, timelimit, timestep, dx, xmin,ymin,zmin) % struct,active, Tliq, Tsol, A, dx,dy, n,m, timelimit)
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
bool_plot_remvoe_from_active = 0;
bool_plot_fs = 0;
bool_plot_window = 0;

% struct.fs(:,:,:) = 0.5;

%% plot parameters
alpha_plt = 0.025; %0.5
sz=500;
cube=0;
if bool_plot_window == 1
    % PREPARING FURTHER PLOT
    % f = figure('Position',[2600 100 1200 900]);
    close all;
    f = figure('Position',[2600 100 1200 900]);
    movegui(f);
    axis equal
    hold on
    view(90,90)
end
%% main loop:
while globaltime<timelimit &&~finished 
    
    clf;    
    grid on;grid minor;axis equal;view(90,90);
    tic
    
    time_ind = time_ind+1;
    fprintf('timestep No. %.d \n', time_ind)     
    globaltime = time_ind*timestep;
    
    add_to_active = [];
%% parrallel loop through workers:
     hold on;
%         scatter3(act(:,1),act(:,2),act(:,3));

    %% GRAIN LOOP:   ************
    for grain=1:length(active(:,1))
        % assign points:
        x = active(grain,1);
        y = active(grain,2);
        z = active(grain,3);
        
        % calculating length based on speed of interface advance. Add init.
        % length?
%         struct.length(x,y,z) + 
        struct.length(x,y,z) = A*struct.undercooling(x,y,z).^2 * ...
                (globaltime - struct.deltaTime(x,y,z));
        % calculating points:
        octahedron_points = func_calculate_points3D([x,y,z],...
                       xmin, ymin, zmin,dx, ...
                       struct.alpha(x,y,z),struct.beta(x,y,z),struct.gamma(x,y,z),struct.length(x,y,z));
%                             alpha beta gamma
        % plotting cubes
        if bool_plot_cube ==1 % && n_th==1                
            hold on
            colour = round([struct.alpha(x,y,z),struct.alpha(x,y,z),struct.alpha(x,y,z)]/pi*10)/10; %round([act(grain,4),act(grain,5),act(grain,6)]/pi)
            plot_octahedron(octahedron_points, colour, alpha_plt)
            pause(0.0001)
%             cube = cube+1;
            fprintf('cube No. %.d\n', cube)
        end

        %% assign neighbours
        neigh = func_assign_neighbuor(active, grain, l);
        
        neigh_fs = NaN(length(neigh),1);
        % assigning fs vaues for each neighbour:
        for p=1:length(neigh) 
            neigh_fs(p) = struct.fs(neigh(p,1),neigh(p,2),neigh(p,3));
        end
        
        % check if 6 main neighbours are solid: 
        if length(neigh(:,1)) == 26 && sum(neigh_fs(1:6))>= 6
            remove_from_active = [remove_from_active; x y z];%                     
        elseif  sum(neigh_fs(1:5))>= 5
            remove_from_active = [remove_from_active; x y z];
        end 
        
        % plotting neighbours (debugging)
        if bool_plot_neighbour == 1
            plot_coord_from_ijk(neigh, dx, xmin, ymin,zmin, sz/10, 'cyan')
            pause(1/10000)
        end
        
        %% CHECKING IF THE GRAINS ARE INSIDE:
        % check if length is bigger than min length to avoid some
        % unneccessary computations
        if struct.length(x,y,z) < dx/5  % dx % length 
            captured_ijk = 0; % skips checking of cubes that are too small
            
        else % length is perhaps sufficient: 
            % bool vector IsCaptured:
            IsCaptured = logical(func_check_inside3D(octahedron_points, func_ijk_to_xyz(neigh, dx,xmin,ymin,zmin)));
            
            % if some of the points were captured, add them to new list of
            % active cells:
            if any(IsCaptured, 'all')
%                 disp('some cells were captured!')
                % removing values that are not captured:
                captured_ijk = neigh.*(IsCaptured);
                
                % removing zero rows:
                captured_ijk( ~any(captured_ijk ,2), : ) = [];
                
                % iterating through all the captured neighbours:
                for p=1:length(captured_ijk(:,1))  
                % if the cell is also not solid or liquid:
                if neigh_fs(p) < 1 && neigh_fs(p) > 0 
                    % adding to new active cells:                    
                    add_to_active = [add_to_active; captured_ijk(p,1:3)];
                   
                    % assigning orientations:
                    struct.alpha(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                        struct.alpha(x,y,z);
                    struct.beta(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                        struct.beta(x,y,z);
                    struct.gamma(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                        struct.gamma(x,y,z);
                    struct.deltaTime(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3))=...
                        globaltime;                        
                    struct.fs(captured_ijk(p,1),captured_ijk(p,2),captured_ijk(p,3)) = 1;
                    
                end
                end
                
            end
        end       
        
                %{
        for p=1:length(neigh(:,1)) % 26  % p for neighbour                 
            bool_col(p,6) = struct.fs(neigh(p,1),neigh(p,2),neigh(p,3));                
             %fprintf('***Neigh num: %.f \n', p)
             if struct.length(x,y,z) <0  % dx % length 
                 bool = 0; % skips checking of cubes that are too small
             else
                [bool,cx, cy, cz, Lnew] = func_check_inside_vector3D(...
                    cubic_points, ... 
                    [single(neigh(p,1)-1).*dx + xmin,...
                     single(neigh(p,2)-1).*dy + ymin,...
                     single(neigh(p,3)-1).*dz + zmin],...  % neigh(p,:).*dx
                    dx);  % ,act(grain,1),act(grain,2),act(grain,3), ... % i j k 
%                     act(grain,11)length, coord-s checks if the point is within
                bool_col(p,1)=bool;
                bool_col(p,2)=cx;
                bool_col(p,3)=cy;
                bool_col(p,4)=cz;
                bool_col(p,5)=Lnew;

                    % IF SIMPLY CAPTURED: 
                if bool_col(p,1) == 1  && struct.fs(neigh(p,1),neigh(p,2),neigh(p,3)) ~=1   % && bool_col(p,6) ~= 0  % AND ! ~=0 for mushy zone
%                         disp('captured!')
                    add_to_active = [add_to_active; neigh(p,1:3)];  
                     struct.alpha(neigh(p,1),neigh(p,2),neigh(p,3))=...
                        struct.alpha(x,y,z);
                    struct.beta(neigh(p,1),neigh(p,2),neigh(p,3))=...
                        struct.beta(x,y,z);
                    struct.gamma(neigh(p,1),neigh(p,2),neigh(p,3))=...
                        struct.gamma(x,y,z);
                    struct.deltaTime(neigh(p,1),neigh(p,2),neigh(p,3))=...
                        globaltime;                        
                    struct.fs(neigh(p,1),neigh(p,2),neigh(p,3)) = 1;

                    %% CHECKER: SET ALPHA TO ZERO TO SEE IF CAPTURED

%                          struct.alpha(neigh(p,1),neigh(p,2),neigh(p,3))=...
%                             struct.alpha(x,y,z);
%                         struct.beta(neigh(p,1),neigh(p,2),neigh(p,3))=...
%                             struct.beta(x,y,z);
%                         struct.gamma(neigh(p,1),neigh(p,2),neigh(p,3))=...
%                             struct.gamma(x,y,z);
                end
             end
        end % end of neigh loop


        % working with the captured grains: 
        if any(bool_col(:,1))
            % check if 6 main neighbours are solid: 
            if length(neigh(:,1)) == 26 && sum(bool_col(1:6,6))>= 6
                remove_from_active = [remove_from_active; x y z];%                     
            elseif  sum(bool_col(1:5,1))>= 5
              remove_from_active = [remove_from_active; x y z];
            end 
        end
        %}


    end  % end of loop through active grains    
    if ~isempty(add_to_active)
        active = [active; add_to_active];
        %% ------------------------------------------------------------------------------- COMMENTED! DECOMMENT!
         add_to_active=[];
    end
    
    % removing zero rows:
    remove_from_active( ~any(remove_from_active,2), : ) = [];
    
    % removing similar rows in active and disabled active:
    if ~isempty(remove_from_active)
%         disp('removed from active.')
        active = setdiff(active, remove_from_active, 'rows'); % 
        if bool_plot_remvoe_from_active == 1
            plot_coord_from_ijk(remove_from_active, dx, xmin, ymin,zmin, sz/1, 'black')
            pause(1/10000)
        end        
        %% ------------------------------------------------------------------------------- COMMENTED! DECOMMENT!
%         remove_from_active=zeros(1,3);
    end
    
    %% plotting active
    unique(active, 'rows');
    
    % assigning fs=1 to active cells:
    for pointer=1:length(active(:,1))
        struct.fs(active(pointer,1),active(pointer,2),active(pointer,3)) = 1;
    end    
    
    % plotting fs==1 points in blue:
    if bool_plot_fs == 1
        fs_points=[];
        
        for i1=1:n
            for j1=1:m
                for k1=1:l
                    if struct.fs(i1,j1,k1) > 0.99
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
    
    % plotting active    
    if bool_plot_active == 1
        plot_coord_from_ijk(active, dx, xmin, ymin,zmin, sz/5, 'green')
        pause(1/10000)
    end
    
    % if there are no active points at this timestep => finish timeloop uj   
    if isempty(active)
        disp('no active cells. finishing timeloop...')
        finished = 1;
    end
            
    pause(1/1000);  
    toc  

end % OF TIMELOOP
end % of the function