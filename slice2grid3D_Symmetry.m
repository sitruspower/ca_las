if 0
    disp('extending the slice....')    
    run sliceExtension3D.m  % inputfile = 'MeltPool.csv'; --> MeltPoolExtended.csv
    toc
    tic
    disp('interpolating....')
    run slice2grid3D.m  % 'MeltPoolExtended.csv' -> 'InterpolatedTemperatureGrid.mat. Assigns "Filling temperature, which is 2200oC; Controls 'dx'
end

%% NEW SLICE2GRID
%clear all;
tic
inputfile = 'MeltPoolExtended.csv';

presicion = 10;
digits(presicion);

%% grid parameters:
dx =1.e-3; % mm  % 100 for 4 cells per z. 1um gives 2000s per small timestep
fprintf('dx=%4.f um \n', dx*1000);
dy = dx;     % uniform array
dz = dx;     % uniform array

% reading values and assigning to lists
rows = csvread(inputfile); 
x = rows(:,1); 
y = rows(:,2);  % fixed
z = rows(:,3);
v = rows(:,4);

% symmetry:
input_full = 0;

if input_full
    newv = v;
    newx = x;
    newy = -y;
    newz = z;

    x = [x;newx];
    y = [y;newy];
    z = [z;newz];
    v = [v;newv];

    % looking for min max max values which will be used for meshgrid
    xmin = min(x);
    xmax = max(x);
    ymin = min(y);
    ymax = max(y);
    zmin = min(z) + max(z)*2/3;
    zmax = max(z);
    [xi,yi, zi] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zmin:dz:zmax);
    mesh = [xi yi zi];
    vq = griddata(x,y, z, v ,xi,yi, zi); 
else
        % looking for min max max values which will be used for meshgrid
    xmin = min(x) + 1.3;  % removing left part
    xmax = max(x);
    
%     ymin = min(y);
%     ymax = max(y);
    ymin = (min(y) + max(y))/2 - 0*dx;
    ymax = (min(y) + max(y))/2 + 1*dx;

    zmin = min(z);% + max(z)*2/3;
    zmax = max(z);
    [xi,yi, zi] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zmin:dz:zmax);
    vq = griddata(x,y, z, v ,xi,yi, zi); 

end


% output 2D array. longest operation
vq(isnan(vq))=min(v);

%% MIRRORING:
%{ 
% vq(isnan(vq))=filling_temperature; 
vq_mir = flip(vq,1);
% vq_mir(1,:)
vq_mir(1,:,:) = [];

yi_mir = flip(yi);
yi = [yi, yi_mir];
vq = [vq_mir;vq];

[xi,yi, zi] = meshgrid(xmin:dx:xmax, -ymax:dy:ymax, zmin:dz:zmax);

%}


%% plotting
if 1
    xslice=[xi(1), xi(end)];
    yslice=[yi(1), yi(end)];
    zslice=[zi(1), zi(end)/2, zi(end)/2];
    h=slice(xi, yi, zi, vq, xslice, yslice, zslice);    % display the slices
    ylim([-3 3])
    view(-34,24)

    cb = colorbar;                                  % create and label the colorbar
    cb.Label.String = 'Temperature, C';

    set(h, 'EdgeColor', 'none');  
    axis equal
    grid off
    view(0,0)
    axis equal
    
end



% clearvars -except vq xi yi zi xslice yslice zslice xmin ymin zmin
save('InterpolatedTemperatureGrid.mat') %, '-v7.3'

% run MirrorSlice.m
