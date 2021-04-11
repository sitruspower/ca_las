% assigning random orientation of grains. 
% inpurts: array and Grain size
clear;

filename=('InterpolatedTemperatureGrid.mat');

inputs=open(filename);
x = inputs.yi;
y = inputs.xi;
z = inputs.zi;
dx = x(2,1,1)-x(1,1,1);  % mm
dy = y(1,2,1)-y(1,1,1); % mm
dz = z(1,1,2)-z(1,1,1);  % mm

alpha = zeros(size(x),'like', x); alpha = single(alpha);
beta= zeros(size(x),'like', x); beta = single(beta);
gamma = zeros(size(x),'like', x); gamma = single(gamma);


%%
alpha(:,:,:) = round(rand(size(x))*pi/2*100)/100;
beta(:,:,:) = round(rand(size(x))*pi/2*100)/100;
gamma(:,:,:) = round(rand(size(x))*pi*100)/100;

if 0
    disp('in script "ASSIGN RANDOM ORIENTATION" alpha beta gamma changed to fixed value!!!!!!')
    alpha(:,:,:) = pi;
    beta(:,:,:) = pi;
    gamma(:,:,:) = pi;
end


clearvars -except alpha beta gamma;
save('RandomOrientation.mat');
clear all;
