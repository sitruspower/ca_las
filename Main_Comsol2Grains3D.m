close all;


if 1
run sliceExtension3D.m  % inputfile = 'MeltPool.csv'; --> MeltPoolExtended.csv
run slice2grid3D.m  % 'MeltPoolExtended.csv' -> 'InterpolatedTemperatureGrid.mat. Assigns "Filling temperature, which is 2200oC; Controls 'dx'
run assignRandomOrientation3D.m % InterpolatedTemperatureGrid.mat -> RandomOrientation.mat 

% then run: 
Tliq = 2600;
Tsol = 2900;
velocity = 2.5; % [mm/s], laser speed
%dx = 2.5e-3;     % [mm] mesh size
A=1.e-4;         % growth velocity coefficient

% 
% Initial_temperature = open('InterpolatedTemperatureGrid.mat').vq;
% xi = open('InterpolatedTemperatureGrid.mat').xi;
% yi = open('InterpolatedTemperatureGrid.mat').yi;
% zi = open('InterpolatedTemperatureGrid.mat').zi;

inputs=open('InterpolatedTemperatureGrid.mat'); % opening just for the slice, to be removed...
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
Tfilling = 2200 % oc. Change slice2grid3D.m when assigned different

dx = xi(1,2,1)-xi(1,1,1);  % mm
end


dy = dx;  % mm
dz = dx;  % mm

dx = xi(1,2,1)-xi(1,1,1);  % mm
struct = func_initialise_struct3D(Initial_temperature, Tliq, Tsol);

active = func_active_cells3D(struct, xslice, yslice, zslice, xi, yi, zi, xmin, ymin, zmin);
vmax = max(vertcat(struct.undercooling)).^2*A;

%timestepping
NUMBER_OF_TIMESTEPS = 60; % 80=17; 40=9, 60=13
timestep = dx/(10*sqrt(2)* vmax); % 10 timesteps per square % CHANGE COEFFICIENT TO >=2
timelimit = timestep*NUMBER_OF_TIMESTEPS; %0.04;


% active = func_active_cells3D();   % saves 'active.mat'

f = figure('Position',[2600 100 1000 600]);
movegui(f);
axis equal

hold on
if 1
    for pos=1:5:round(3*m/5) %10:10:600
        fprintf('POS= %.f;', pos);
        time = (pos+5)/velocity*dx  % s
        temperature = func_move_molten_pool3D...
                      (Initial_temperature, xi, yi,zi, Tfilling, velocity, time, dx);  % no plotting
        orient = open('RandomOrientation.mat');
        
        
        
        struct = func_restruct_fs_addT3D(struct, temperature, Tliq, Tsol,n,m,l);  % no plotting
        pause(0.5)
        
        % here we have: updated struct, opened "orient".
        
        % really weird!!!
        active = func_active_cells3D(struct, xslice, yslice, zslice, xi, yi, zi, xmin, ymin, zmin); % plotted active. Stopped
        hold on
        %scatter3((active(:,2)-1)*dy+xmin,(active(:,1)-1)*dy+ymin,(active(:,3)-1)*dz+zmin,100,'red','filled')
        
        
        
        struct = func_growth_in_sl3D(active, struct, timelimit);
        
        if 1
        close all;
            % hold on
            fs = [struct.alpha];
            fs = reshape(fs,n,m,l);
            h = slice(xi, yi, zi, fs, xslice, yslice, zslice);
            axis equal;

            %         set(h,'EdgeColor','none',...
            %         'FaceColor','interp',...
            %         'FaceAlpha','interp');
            %         alpha('color');
            %         cm_plasma=colormap_plasma(100);
            %     %         alphamap('rampdown')  
            %         colormap(cm_plasma) %hot hsv
            %         colormap(hot) %hot hsv
            %         alphamap('increase',0.001)
            %         colorbar;
            %         pause(1/1000)        
        end
        
        strcat('pos=', string(pos),'.fig')
        strcat('struct=', string(pos),'.m')
        savefig(strcat('Alpha. pos=', string(pos),'.fig'))
        save(strcat('struct=', string(pos),'.mat'))
        
        
        pause(1/1)
        
    end
end