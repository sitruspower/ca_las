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

alpha = zeros(size(x),'like', x);

beta= zeros(size(x),'like', x);

gamma = zeros(size(x),'like', x);

for i=1:length(x(:,1,1))
    for j=1:length(y(1,:,1))
        for k=1:length(z(1,1,:))
            alpha(i,j,k)=rand(1)*pi/4;
            beta(i,j,k)=rand(1)*pi/4;
            gamma(i,j,k)=rand(1)*pi/4;
        end
    end
end



clearvars -except alpha beta gamma;
save('RandomOrientation.mat');
