
clf
clearvars 
OneGrain = 1;
angle=pi/4;

dim = 10;  % 10x10x10
% initialising struct with DIM dimension
for i=1:dim
    for j=1:dim
        for k=1:dim
                struct.temp(i,j,k) = 3500;
                struct.fs(i,j,k) = 0.5;
                struct.alpha(i,j,k) = rand(1)*3.14;
                struct.beta(i,j,k) = rand(1)*3.14;
                struct.gamma(i,j,k)= rand(1)*3.14;              
                struct.undercooling(i,j,k) = 100; %Tliq-temp(i,j);
                struct.length(i,j,k) = 0;
                struct.active(i,j,k) = 0;       % is 1 if active
                struct.deltaTime(i,j,k) = 0;
%                 cell.init_point = [(i-1)*dx+xmin,(j-1)*dx+ymin, (k-1)*dz+zmin];  % was j, i in 2D case. Can be an issue in 3D.                
%                 struct(i,j,k) = struct;
        end
    end
end

if OneGrain==1
    active = [1,1,1];
    struct.alpha(active(1,1),active(1,2),active(1,3)) = angle;
    struct.beta(active(1,1),active(1,2),active(1,3)) = angle;
    struct.gamma(active(1,1),active(1,2),active(1,3)) = angle;
else 
    active = [2,2,7;
              3,3,6;
              3,3,5;
              5,4,3;
              6,4,2;
              5,5,1];
end

timestep = 0.0072;
timelimit = timestep*50;

dx = 25.e-3;
xmin = 0; ymin=0; zmin = 0;

active = single(active);active=unique(active,'rows');% struct.fs=ones(7,7,7)*0.5


%inputs=open('InterpolatedTemperatureGrid.mat');
%xmin = inputs.xmin;ymin = inputs.ymin;zmin = inputs.zmin;

struct.fs(:,:,:) = 0.5;
struct.length(:,:,:) = 0;

func_growth_in_sl_parallel3D(active, struct, timelimit, timestep, dx, xmin,ymin,zmin, 1);


