% for unconstrained: comment fs=0.5 in func_initialise
%% started at around 14.00 14.02.21
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
    run slice2grid3D_Symmetry.m  % 'MeltPoolExtended.csv' -> 'InterpolatedTemperatureGrid.mat. Assigns "Filling temperature, which is 2200oC; Controls 'dx'
    toc
    tic
    disp('assigning orientation....')
    run assignRandomOrientation3D.m % InterpolatedTemperatureGrid.mat -> RandomOrientation.mat 
    toc
end


% then run:

%% initialisation
% Tliq = 3700; % [oC]
Tliq = 3200; % [oC]
Tsol = 2690; % [oC]
A=1.e-4;         % growth velocity coefficient
Tfilling = 2200; % oc. Change slice2grid3D.m when assigned different
inputs=open('InterpolatedTemperatureGrid.mat'); % op ening just for the slice, to be removed...
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


disp('TIME TO MOVE STRUCT AND FIND ACTIVE:')   
tic
disp('___________________________________')
%CORRECT MAIN FUNCTION
active = func_active_cells3D(struct, dx); % xslice, yslice, zslice, xi, yi, zi, xmin, ymin, zmin);
toc

%% timestepping now inside func_growth_in_sl_parallel
timestep = 0;
timelimit = 0;

%% s-l interface moveme
% delta_pos = round(length_of_capture/2);
delta_pos = 25;

% delta_pos = 5;

disp('___________________________________')


for pos=1:delta_pos:round(5*m/6)
    tic        
    presicion = 3;
    digits(presicion);
    disp('___________________________________')
    fprintf('POS= %.f;\n', pos);
    temperature = func_move_molten_pool3D...
              (Initial_temperature, xi, yi,zi, Tfilling, pos, dx);  % no plotting 
          
    %% checking. Moving active on pos instead of moving the pool:
    struct = func_restruct_fs_addT3D(struct, temperature, Tliq, Tsol,n,m,l, active);  % no plotting
%     plot_fsstruct(struct,n,m,l)

    active = func_active_cells3D(struct, dx);
        % set random orientation of top left corner to ...
    
        
    disp('TIME TO MOVE STRUCT AND FIND ACTIVE:')   
    toc
    disp('___________________________________')
    
    pause(0.0001)
    tic
    struct = func_growth_in_sl_parallel3D(active, struct, timelimit, timestep, dx, xmin,ymin,zmin, pos);
    disp('time per growth:')
    toc
    
    %% plotting 
    plotting = 1; 
    if plotting ==1 
        close all;
        plot_struct(struct, n,m,l)
        pause(1/100)

        disp('saving figure ..............')
        savefig(strcat('Alpha. pos=', string(pos),'.fig'))
    end
end
disp('saving struct..............')
savefig(strcat('Alpha. pos=', string(pos),'.fig'))

%% saving struct and postprocessing via MTEX:
save('mystruct.mat', 'struct')
pause(1.)
run struct_to_ctf_export.m
% run mtex_script.m

pause(1/1000)
