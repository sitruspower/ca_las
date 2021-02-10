%% Transfer data from XYZ to 3D array [Txyz]
% manual cut operation of the array

%clear all;
tic
inputfile = 'MeltPoolExtended.csv';
Tleft = 2000; % K, everything smaller will be removed
filling_temperature = 2200; % K

presicion = 5;
digits(presicion);

%% grid parameters:
dx = 10.e-3; % mm  % 100 for 4 cells per z
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
vq(isnan(vq))=filling_temperature;

%%  ----------------------------------------
% !!!! CHANGING THE SIZE TO SMALL FOR CHECKS.

% disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
% disp('SMALL GRID! CHECK SLICE2GRID.M AND COMMENT THIS SECTION!')
% si  = size(vq);
% u = si(3);
% vq = vq(1:u, 1:u, 1:u);
% xi = xi(1:u, 1:u, 1:u);
% yi = yi(1:u, 1:u, 1:u);
% zi = zi(1:u, 1:u, 1:u);
% end of this

%% slicing
xslice = [(xmax+xmin)/2 xmax];                               % define the cross sections to view
yslice = [(ymax+ymin)/3 (ymax+ymin)/2 (ymax+ymin)/3*2 ymax];
zslice = [zmin (zmax+zmin)/2 zmax];


%% plotting
if 0
    slice(xi, yi, zi, vq, xslice, yslice, zslice)    % display the slices
    ylim([-3 3])
    view(-34,24)

    cb = colorbar;                                  % create and label the colorbar
    cb.Label.String = 'Temperature, C';

    grid off
    axis equal
end


vq=single(vq); xi=single(xi);yi=single(yi);zi=single(zi);

clearvars -except vq xi yi zi xslice yslice zslice xmin ymin zmin
save('InterpolatedTemperatureGrid.mat') %, '-v7.3'

if 0
    save('mesh.mat', 'mesh')
    clear all;
    load('mesh.mat', 'mesh')
    [xi,yi, zi] = mesh
end
toc
