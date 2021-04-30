
% inputs=open('InterpolatedTemperatureGrid.mat');
% xmin = inputs.xmin;ymin = inputs.ymin;zmin = inputs.zmin; dx=inputs.xi(1,2,1)-inputs.xi(1,1,1);
% parameters: 
xmin=0;ymin=0;zmin=0;
dx=10.25; 

% initial octahedron
x=1;y=1;z=1;
length = dx*3;
triangulation_matrix = [5     2     1     3;
    6     1     2     3;4     5     1     3;
                        4     1     6     3;];

% neighbouring octahedron
MaxI = 2;
neighb = [randi(MaxI),randi(MaxI),randi(MaxI)];
% angles for a given point:
a=pi/1; b=pi/1; g=pi/1;
% need to plot? takes some time
plotting = 1;
plotvar = [dx,xmin,ymin,zmin];
% calculating initial octahedron
octahedron_points = func_calculate_points3D([x,y,z],...
               xmin, ymin, zmin,dx, ...
               a,b,g, length);
% checking if the neighbour is captured aty all
IsCaptured = logical(func_check_inside3D(octahedron_points, func_ijk_to_xyz(neighb, dx,xmin,ymin,zmin), triangulation_matrix));
% calculating new length
Lnew = func_calculate_grain_length(octahedron_points,func_ijk_to_xyz(neighb, dx,xmin,ymin,zmin), 0);
% calculating neighbour's octahedron points
octahedron_points_neigh = func_calculate_points3D(neighb,...
               xmin, ymin, zmin,dx, ...
               a,b,g, Lnew);


if plotting == 1
    % INITIAL = RED
    % NEIGHBOUR = GREEN
%     test new length
    clf; hold on
    plot_ijk([x,y,z], dx, xmin, ymin, zmin, 'red')    
    plot_xyz(octahedron_points, dx, xmin, ymin, zmin, 'red')
    
    plot_ijk(neighb, dx, xmin, ymin, zmin, 'green')
    plot_xyz(octahedron_points_neigh, dx, xmin, ymin, zmin, 'green')
    
    
    plot_octahedron(octahedron_points, 'red', 0.1)
    plot_octahedron(octahedron_points_neigh, 'green', 0.1)
    
    % calc again to enable plotting from inside the function
    Lnew = func_calculate_grain_length(octahedron_points,func_ijk_to_xyz(neighb, dx,xmin,ymin,zmin), plotvar);

    
%     grid minor;
    axis equal;pause(0.2);view(20,20);
%     view(35,35) 
end 
