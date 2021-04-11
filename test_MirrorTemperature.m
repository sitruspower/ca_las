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
inputfile = 'Temperature_100mms.csv';
Tleft = 2000; % K, everything smaller will be removed
filling_temperature = 2200; % K

presicion = 5;
digits(presicion);

%% grid parameters:
dx = 5.e-3; % mm  % 100 for 4 cells per z
fprintf('dx=%3.f um \n', dx*1000);
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
mesh = [xi yi zi];

% output 2D array. longest operation
vq = griddata(x,y, z, v ,xi,yi, zi); 
% vq(isnan(vq))=filling_temperature; 
vq_mir = flipdim(vq,1);
% vq_mir(1,:)
vq_mir(1,:,:) = [];

yi_mir = flip(yi);
yi = [yi, yi_mir];
vq = [vq_mir;vq];

[xi,yi, zi] = meshgrid(xmin:dx:xmax, -ymax:dy:ymax, zmin:dz:zmax);


%% plotting
if 1
    xslice=[xi(1), xi(end)];
    yslice=[yi(1), yi(end)];
    zslice=[zi(1), zi(end)];
    slice(xi, yi, zi, vq, xslice, yslice, zslice)    % display the slices
    ylim([-3 3])
    view(-34,24)

    cb = colorbar;                                  % create and label the colorbar
    cb.Label.String = 'Temperature, C';

    grid off
    axis equal
end

