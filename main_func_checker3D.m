close all;
clear all;


% check_move_pool
%check_put_pool


%function check_put_pool()

    clear all;
    inputs_Temperature=open('InterpolatedTemperatureGrid.mat');

    inputfile = 'MeltPoolExtended.csv';
    
    % parameters
    Tsol = 2990;
    Tliq = 2300;
    velocity = 2.5e-3;  % mm/s

    %%%%%%%    CHANGE ACCORDING TO THE ACTUAL MESH SIZE    %%%%%%%%%%%%%%%%
    % grid parameters:
    dx = 25e-3; % mm    

    dy = dx;     % uniform array
    dz = dx;     % uniform array

    % reading values and assigning to lists
    rows = csvread(inputfile);
    x = rows(:,1);
    y = rows(:,2);  % fixed
    z = rows(:,3);
    v = rows(:,4);

    % looking for min max max values which will be used for meshgrid
    xmin = min(x);
    xmax = max(x);
    ymin = min(y);
    ymax = max(y);
    zmin = min(z);
    zmax = max(z);
    
    [xi,yi, zi] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zmin:dz:zmax);
    T = inputs_Temperature.vq;
    
    xslice = [(xmax+xmin)/2 xmax];        % define the cross sections to view
    yslice = [(ymax+ymin)/3 (ymax+ymin)/2 (ymax+ymin)/3*2 ymax];
    zslice = [zmin (zmax+zmin)/2 zmax];
    struct = func_initialise_struct3D(T);
    
    save('struct.mat','struct')

    % position and time
    pos= 45;      % returns an error when too large (45 in 25um grid)
    time = (pos)/velocity*dx;  % s

    
    [outputstruct, active] = func_putMoltenPool3D(struct, T, Tliq, Tsol, dx,xmin,ymin,zmin);
    struct = outputstruct;
    
    save('active.mat','active')
    
    %T = func_move_molten_pool3D(T, xi, yi,zi, Tsol, velocity, time, dx);
    
    f = figure('Position',[2600 100 1900 800]);
    movegui(f);
    hold on    
    %slice(xi, yi, zi, T, xslice, yslice, zslice)
    axis equal
    
    temp=ones(size(struct));
    undercooling=ones(size(struct));
    fs=ones(size(struct));
    length=ones(size(struct));
    active_points=ones(size(struct));
    init_point=ones(size(struct));
    alpha=ones(size(struct));
    s = size(T);
    n=s(1);
    m=s(2);
    l=s(3);
    
    for i=1:n
        for j=1:m
            for k=1:l
                temp(i,j,k) = struct(i,j,k).temp;
                fs(i,j,k) = struct(i,j,k).fs;
                length(i,j,k) = struct(i,j,k).length;
                active_points(i,j,k) = struct(i,j,k).active;   
                alpha(i,j,k) = struct(i,j,k).alpha;
            end
        end
    end
  
    slice(xi, yi, zi, alpha, xslice, yslice, zslice);
    scatter3((active(:,2)-1)*dx+xmin,...
             (active(:,1)-1)*dy+ymin,...
             (active(:,3)-1)*dz+zmin, 'MarkerFaceColor',[0 .75 .75]);
    colorbar;
    