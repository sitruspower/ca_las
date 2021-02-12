% for unconstrained: comment fs=0.5 in func_initialise

close all;


clear all;
% change presicion:
presicion = 3;
digits(presicion);

precalc = 1; % slicing, initialisation

if precalc
    tic
    disp('extending the slice....')    
    run sliceExtension3D.m  % inputfile = 'MeltPool.csv'; --> MeltPoolExtended.csv
    toc
    tic
    disp('interpolating....')
    run slice2grid3D.m  % 'MeltPoolExtended.csv' -> 'InterpolatedTemperatureGrid.mat. Assigns "Filling temperature, which is 2200oC; Controls 'dx'
    toc
    tic
    disp('assigning orientation....')
    run assignRandomOrientation3D.m % InterpolatedTemperatureGrid.mat -> RandomOrientation.mat 
    toc
end


% then run:

%% initialisation
Tliq = 3800;
Tsol = 2800;
velocity = 2.5; % [mm/s], laser speed
%dx = 2.5e-3;     % [mm] mesh size
A=1.e-4;         % growth velocity coefficient
Tfilling = 2200; % oc. Change slice2grid3D.m when assigned different
inputs=open('InterpolatedTemperatureGrid.mat'); % opening just for the slice, to be removed...
%% opening grid values
xi = inputs.xi;
yi = inputs.yi;
zi = inputs.zi;
Initial_temperature = inputs.vq;
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

%% active grains decision
%%%%%%%%%%%
checker = 0; % fs = 0.5, active = some chosen grains, no "putMoltenPool"

%% computations
if 1
    tic
    disp('initialising_struct...')
    struct = func_initialise_struct_portions3D(Initial_temperature, Tliq, Tsol, checker);
    toc
end

%CORRECT MAIN FUNCTION
active = func_active_cells3D(struct, dx); % xslice, yslice, zslice, xi, yi, zi, xmin, ymin, zmin);

% vmax = max(vertcat(struct.undercooling)).^2*A;
v_mushy = struct.temp(struct.temp<Tliq);
v_mushy = v_mushy(v_mushy>Tsol);
% vmax = single(max(Tliq-v_mushy, [], 'all')); 
vmax = 100.^2*A;

%% timestepping
% length of capture: defined as number of timesteps(N_TSTEP)/(DX_ADV)timestep dx advance
% CAREFUL!!! MESH-DEPENDENT PARAMETER!!!
length_of_capture = 10; % how many dx/2 will be advanced during captire. ~30 is great. 

%  how many (dx) advances can be in a single timestep
DX_ADV = 2; % set to 1 for fastest growth.
N_TSTEP= length_of_capture*DX_ADV; % 80=17; 40=9, 60=13
timestep = dx/(DX_ADV*sqrt(3)* vmax); % 10 timesteps per square % CHANGE COEFFICIENT TO >=2
timelimit = timestep*N_TSTEP; %0.04;

%Tliqhigh = Tliq + max_grad*delta_pos; % deg C, where it won't attach new point. second number
Tliqhigh = Tliq;  % overriding Tliqhigh, thus growth only in mushy zone

%% s-l interface moveme
delta_pos = 5;

for pos=1:delta_pos :round(3*m/5) %10:10:600
    tic        
    presicion = 5;
    digits(presicion);
    fprintf('POS= %.f;', pos);
    time = (pos+5)/velocity*dx; % s     
    temperature = func_move_molten_pool3D...
              (Initial_temperature, xi, yi,zi, Tfilling, velocity, time, dx);  % no plotting 
          
    %% checking. Moving active on pos instead of moving the pool:
    struct = func_restruct_fs_addT3D(struct, temperature, Tliq, Tsol,n,m,l, active);  % no plotting
    active = func_active_cells3D(struct, dx);
    
    if pos == 1
        % removing every 2nd active cell several times.
%         active(2:2:end,:) = [];
%         active(2:2:end,:) = [];
%         active(2:2:end,:) = [];
    end
    
    pause(0.5)
    tic
    struct = func_growth_in_sl_parallel3D(active, struct, timelimit, timestep, dx, xmin,ymin,zmin);
    disp('time per growth:')
    toc
    
    %% plotting 
    plotting = 1; 
    if plotting ==1 
        plot_struct(struct, n,m,l)
        pause(1/100)
    end
end
disp('saving struct..............')
%     savefig(strcat('Alpha. pos=', string(pos),'.fig'))
save('mystruct.mat', 'struct')
%save('mystruct.mat', 'struct', '-v7.3')
strcat('pos=', string(pos),'.fig');
%     savefig(strcat('Alpha. pos=', string(pos),'.fig'))
pause(1/1000)
