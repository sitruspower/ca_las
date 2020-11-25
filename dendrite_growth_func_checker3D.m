%% simulation parameters
tic
Tliq = 2950;            % K  liquidus temperature
Tsol = 2850;            % K
A = 10^-4;              % undercooling constant (for Ni based superalloys)
dx=1.e-3;               
dy=dx;

inputfile = 'MeltPoolExtended.csv';
rows = csvread(inputfile);
x = rows(:,1);y = rows(:,2);z = rows(:,3);v = rows(:,4);
xmin = min(x);xmax = max(x);
ymin = min(y);ymax = max(y);
zmin = min(z);zmax = max(z);    
dx = 25e-3; % mm    
dy = dx;     % uniform array
dz = dx;     % uniform array

[xi,yi, zi] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zmin:dz:zmax);
velocity = 2.5e-3;  % mm/s
%% initialisation
% struct = func_initialise_struct(n,m, temperature,orient, Tliq,Tsol, dx);

struct = open('struct.mat').struct;
s = size(struct);
n=s(1);
m=s(2);
l=s(3);
temperature_input = zeros(size(struct));
alpha = zeros(size(struct));
beta = zeros(size(struct));
gamma = zeros(size(struct));
for i=1:n
    for j=1:m
        for k=1:l
            alpha(i,j,k) = struct(i,j,k).alpha;
            beta(i,j,k) = struct(i,j,k).beta;
            gamma(i,j,k) = struct(i,j,k).gamma;
            temperature_input(i,j,k) = struct(i,j,k).temp;
        end
    end
end


%csvwrite('orient_output.csv', orient_output);

timelimit = 0.04;

% 2 seconds till here
%% 
toc
f = figure('Position',[2600 100 1900 800]);
movegui(f);
axis equal
for pos=10 %10:10:600
    time = (pos+5)/velocity*dx;  % s
    temperature = func_move_molten_pool3D...
                  (temperature_input, xi, yi,zi, Tsol, velocity, time, dx);
    orient = csvread('orient_output.csv');
    struct = func_initialise_struct3D(temperature);
    active=[];
    [outputstruct, active] = func_putMoltenPool3D...
        (struct, temperature_input, Tliq, Tsol, dx,xmin,ymin,zmin);
    struct = outputstruct;
    toc
    %plotting(orient, temperature, struct,active);
    struct=func_growth_in_sl3D(struct, active, Tliq, Tsol, A, dx,dy, n,m, timelimit);
    
    for i=1:n  % rows, i.e. y
        for j=1:m  % columns, i.e. y
            orient_output(i,j) = struct(i,j).orientation;
        end
    end
    csvwrite('orient_output.csv', orient_output)
    
end
