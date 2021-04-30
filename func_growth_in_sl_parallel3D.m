function struct = ...
     func_growth_in_sl_parallel3D(active, struct, timelimit, timestep, dx, xmin,ymin,zmin, pos) % struct,active, Tliq, Tsol, A, dx,dy, n,m, timelimit)
% creating a struct updated with solution for current meshstep
 
%% SIMULATION PARAMETERS AND MESH
A = 10^-4;              % undercooling constant (for Ni based superalloys)
%[xi,yi, zi] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zmin:dz:zmax);s

%% Timestepping:
numberOfdx = 4;
  
length_of_capture = 1000;
x_step = dx/numberOfdx ;  % how many in steps in dx

deltaTmax =max(struct.undercooling(:)); %max of all undercooling values. governed by Tliq and Tsol
deltaTmin = min(struct.undercooling(active(:)));

growth_degree = 1;

timestep = x_step/(A*deltaTmax^growth_degree);
timelimit = length_of_capture*timestep / (x_step/dx);

%% plotting:
bool_plot_cube = 0;            % plotting cubes doesn't work in multithread
bool_plot_neighbour = 0; 
bool_plot_active =0;
bool_plot_active_midplane = 0;
bool_plot_new_octa = 0;  % plotting octahedrons around new captured cells
bool_plot_remvoe_from_active = 0;
bool_plot_fs = 0;
bool_plot_window = 0;


%% plot parameters
alpha_plt = 0.025; %0.5`
sz=500;
cube=0;
if bool_plot_window == 1
    f = figure('Position',[0 50 1200 570]);
%     ax = gca;
%     grid on;grid minor;
%     axis equal;view(90,90);
    movegui(f);
    view(90,90)
end

%% constant value matrix:
triangulation_matrix = [5     2     1     3;
    6     1     2     3;4     5     1     3;
                        4     1     6     3;];

%% main loop:
length_array = struct.length(:,:,:);
alpha_array = struct.alpha(:,:,:);
beta_array = struct.beta(:,:,:);
gamma_array = struct.gamma(:,:,:);
fs_array = single(struct.fs(:,:,:));
undercooling_array = struct.undercooling(:,:,:);
active = single(active);

n=length(length_array(:,1,1));
m=length(length_array(1,:,1));
l=length(length_array(1,1,:));

globaltime = 0;finished=0;time_ind=0;
f = figure('Position',[0 50 1200 800]);

while globaltime<timelimit &&~finished 
    tic    
    time_ind = time_ind+1;
    fprintf('timestep No. %.d \n', time_ind)     
    globaltime = globaltime + timestep;
    
    if mod(time_ind, 1000) ==0
        plot_struct_undercooling_length(undercooling_array,  length_array, fs_array, alpha_array,n,m,l, pos)
        pause(0.0001)
    end

    add_to_active = nan(length(active(:,1))*28,3);
    remove_from_active = nan(length(active(:,1))*28,3);
    %% PREPARATION FOR PARALLEL COMPUTING:

    x_ar = single(active(:,1));y_ar = single(active(:,2));z_ar = single(active(:,3));
    length_vector = single(nan(1,length(active(:,1))));
    alpha_vector = single(nan(1,length(active(:,1))));
    beta_vector = single(nan(1,length(active(:,1))));
    gamma_vector = single(nan(1,length(active(:,1))));
    
    % slicing variables:
    for grain=1:length(active(:,1))
        loc_x = x_ar(grain);
        loc_y = y_ar(grain);
        loc_z = z_ar(grain);
        length_vector(grain) = length_array(loc_x, loc_y, loc_z) + ...
            A*undercooling_array(loc_x, loc_y, loc_z).^growth_degree*timestep;
        alpha_vector(grain) = alpha_array(loc_x, loc_y, loc_z);
        beta_vector(grain) = beta_array(loc_x, loc_y, loc_z);
        gamma_vector(grain) = gamma_array(loc_x, loc_y, loc_z);
%         undercooling_vector(grain) = undercooling_array(loc_x, loc_y, loc_z);
%         fs_vector(grain) = fs_array(loc_x, loc_y, loc_z);
    end
    
    
    %% GRAIN LOOP:   ************
    number_of_grains = length(active(:,1));
    out_captured = nan(number_of_grains, 28, 3);
    out_length = nan(number_of_grains, 28, 1);
    captured_ijk = 0;
    ticBytes(gcp);
    tic
    parfor grain=1:number_of_grains
        captured_row_out = nan(28,3);
        x = x_ar(grain);
        y = y_ar(grain);
        z = z_ar(grain);
        % calculating points:
        %% CHECKING LENGTH THE GRAINS ARE INSIDE
        %% OVERRIDEN TO TEST PARFOR!
        if length_vector(grain) < dx/2  
            captured_ijk = 0; % skips checking of cubes that are too small. Saves time at the beginning.
        else % length is perhaps sufficient: 
            % bool vector IsCaptured:
            octahedron_points = func_calculate_points3D([x,y,z],...
                       xmin, ymin, zmin,dx, ...
                       alpha_vector(grain),beta_vector(grain),gamma_vector(grain),length_vector(grain));
            neigh = func_assign_neighbuor([x,y,z], n,m,l);
%             
            IsCaptured = logical(func_check_inside3D(...
                        octahedron_points, func_ijk_to_xyz(neigh, dx,xmin,ymin,zmin),...
                    triangulation_matrix));
            
            if any(IsCaptured, 'all')
%                 disp('CAPTURED!')
                % removing values that are not captured:
                captured_ijk = neigh.*(IsCaptured);
                captured_row_out = nan(28,3);
                for ii = 1: length(captured_ijk(:,1))
                    captured_row_out(ii,:) = captured_ijk(ii,:);                    
                end
                out_captured(grain,:,:) = captured_row_out(:,:);
%                 captured_row_out = nan(28,3);
                % calculating new lengths:
                out_length_grain = nan(1,28);
                for p=1:length(captured_ijk(:,1)) % through captured neighbours
                    if sum(captured_ijk(p,:))~=0 % if captured:
                        % calculate length:
%                         out_length(grain,p) =...
                        out_length_grain(p) = ...
                        func_calculate_grain_length(octahedron_points,...
                        func_ijk_to_xyz(captured_ijk(p,:), ...
                        dx,xmin,ymin,zmin), 0);
                    end
                    out_length(grain, :) = out_length_grain(:);
                end            
            end
        end
    end
    disp('time per parfor:');
    toc
%     tocBytes(gcp);
%     averageBytes = tocBytes(gcp)/number_of_grains  % tocBytes, pair 1 
    tic    
    for grain=1:length(active(:,1))
        neigh_fs = zeros(28,1);
        loc_x = x_ar(grain);
        loc_y = y_ar(grain);
        loc_z = z_ar(grain);
        length_array(loc_x, loc_y, loc_z) = length_vector(grain);
        alpha_vector(grain) = alpha_array(loc_x, loc_y, loc_z);
        beta_vector(grain) = beta_array(loc_x, loc_y, loc_z);
        gamma_vector(grain) = gamma_array(loc_x, loc_y, loc_z);
        % (GRAIN, 28, 3)
        % iterating through neighbours:
        neigh = func_assign_neighbuor([loc_x,loc_y,loc_z], n,m,l);
        for p = 1:28
            if (~isnan(out_captured(grain,p,1)))  % if not NaN
                % calculate solid fraction for the neighbours if ~NaN:
                if out_captured(grain,p,1)>0 % if not zero:

                    neigh_fs(p) = fs_array(out_captured(grain,p,1), ...
                            out_captured(grain,p,2), ...
                            out_captured(grain,p,3));        

                    if fs_array(out_captured(grain,p,1), ... % if mushy zone
                            out_captured(grain,p,2), ...
                            out_captured(grain,p,3)) < 1 ...
                            && fs_array(out_captured(grain,p,1), ...
                            out_captured(grain,p,2), ...
                            out_captured(grain,p,3)) > 0 

                        % adding this captured neighbour to active
                        add_to_active(grain*p,:) = out_captured(grain,p,:);
                        % reassigning angles:
                        alpha_array(out_captured(grain,p,1), ...
                            out_captured(grain,p,2), ...
                            out_captured(grain,p,3))=...
                            alpha_vector(grain);
                        beta_array(out_captured(grain,p,1), ...
                            out_captured(grain,p,2), ...
                            out_captured(grain,p,3))=...
                            beta_vector(grain);
                        gamma_array(out_captured(grain,p,1), ...
                            out_captured(grain,p,2), ...
                            out_captured(grain,p,3))=...
                            gamma_vector(grain);
                        % assigning this to solid:
                        fs_array(out_captured(grain,p,1), ...
                            out_captured(grain,p,2), ...
                            out_captured(grain,p,3)) = 1; 
                        % writing length to main array:
                        length_array(out_captured(grain,p,1), ...
                            out_captured(grain,p,2), ...
                            out_captured(grain,p,3))=...
                            out_length(grain,p);
                        out_length(grain,p);
                    end
                    
                end
            end % end of if ~isnan
        end % end of iteration through grains
            % removing nan neigh_fs values. 
%         neigh_fs = neigh_fs(all(~isnan(neigh_fs),2),:);

        % check if 6 main neighbours are solid: 
        % 26 for quasi 2D. 28 for 3D. Think again!!!!

         % if there are 26 neighbours solid with fs==1
        %% check sum>=6: before was neigh_fs(1:6)
        if length(neigh(:,1)) == 28 && sum(floor(neigh_fs)) >= 6
            remove_from_active(p*grain,:) = [loc_x,loc_y,loc_z];

        elseif  length(neigh(:,1)) < 28 && sum(neigh_fs(1:5))>= 5
            remove_from_active(p*grain,:) = [loc_x,loc_y,loc_z];                
        end
             
    end % end of iterations through grains
        

    disp('time to restruct:')
    toc
    
    
    %% ADDING NEW ACTIVE
    add_to_active = add_to_active(all(~isnan(add_to_active),2),:);
    add_to_active = unique(add_to_active, 'rows');
    % adding to active and removing add_to_active matrix:
    if ~isempty(add_to_active)
        % removing all nan values:
        active = [active; add_to_active];
        add_to_active=[];
    end
    
    %% REMOVING ACTIVE
    % removing zero rows:
    remove_from_active( ~any(remove_from_active,2), : ) = [];
    
        remove_from_active = remove_from_active(all(~isnan(remove_from_active),2),:);
    % removing similar rows in active and disabled active:
    if ~isempty(remove_from_active)
        % removing all nan values:
        active = setdiff(active, remove_from_active, 'rows'); % 
        remove_from_active=[];
    end    
    
    
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
            pause(0.00001)
        end
    end
    
    if bool_plot_active == 1
%         hold on
        plot_coord_from_ijk(active, dx, xmin, ymin,zmin, sz/1, 'red')
%         plot_struct_same_figure(struct,n,m,l, pos)
        pause(1/1000000)
    end
    
    % plotting active    
    if bool_plot_active_midplane == 1
%         hold on
        % kij
        new_active = active(active(:,1)==round(n/2),:);
        plot_coord_from_ijk(new_active, dx, xmin, ymin,zmin, sz/100, 'red')
        plot_struct_same_figure(struct,n,m,l, pos)
        pause(1/1000000)
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
    
%     pause(1/10000000);  
%     toc  
    % --------------------------------------------------------------------
    %% OPERATIONS WITH ACTIVE, ADD_TO_ACTIVE, AND REMOVE_FROM_ACTIVE:
%     
%     add_to_active = add_to_active(all(~isnan(add_to_active),2),:);
%     
%     % adding to active and removing add_to_active matrix:
%     if ~isempty(add_to_active)
%         % removing all nan values:
%         active = [active; add_to_active];
%         add_to_active=[];
%     end
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

% reassigning to struct:
struct.length = length_array(:,:,:);
struct.alpha = alpha_array(:,:,:);
struct.beta = beta_array(:,:,:);
struct.gamma = gamma_array(:,:,:);
struct.fs = fs_array(:,:,:);    
struct.undercooling = undercooling_array(:,:,:);
% struct.deltaTime = deltaTime_array(:,:,:);

% close;

end % of the function

    