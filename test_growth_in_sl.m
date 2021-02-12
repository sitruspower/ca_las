

clearvars -except struct
OneGrain = 0;
if OneGrain==1
    active = [4,4,4];
    angle=pi;
    struct.alpha(4,4,4) = angle;
    struct.beta(4,4,4) = angle;
    struct.gamma(4,4,4) = angle;
else 
    active = [2,2,7;
              3,3,6;
              3,3,5;
              5,4,3;
              6,4,2;
              5,5,1];
end

timestep = 0.0072;
timelimit = timestep*20;
dx = 25.e-3;

active = single(active);active=unique(active,'rows');% struct.fs=ones(7,7,7)*0.5

inputs=open('InterpolatedTemperatureGrid.mat');
xmin = inputs.xmin;ymin = inputs.ymin;zmin = inputs.zmin;

struct.fs(:,:,:) = 0.5;


struct.length(:,:,:) = 0;

func_growth_in_sl_parallel3D(active, struct, timelimit, timestep, dx, xmin,ymin,zmin);
