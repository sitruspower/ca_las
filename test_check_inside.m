% TEST script for check_inside3D.m, built for checking the octahedron
% mechanism

%% first creating the edges:
clf;

initial_point = [1,0,0];
alpha = 0;
beta = 0;
gamma = 0;
length_cube = 1;
xmin = 0.;ymin = 0.;zmin = 0.;dx=50.e-3;colour = [0,0,0]; alpha_plt = 0.1;

points = func_calculate_points3D(initial_point, ...
                                    xmin, ymin, zmin,dx,...
                                    alpha,beta, gamma, length_cube);

P = (rand(260,3)-0.5)*3;
IsCaptured = func_check_inside3D(points, P);
capturedPoints = P.*IsCaptured;
capturedPoints( ~any(capturedPoints,2), : ) = [];

hold on
scatter3(points(:,1),points(:,2),points(:,3),100, 'filled','red')
scatter3(P(:,1), P(:,2), P(:,3), 20,'cyan')
scatter3(capturedPoints(:,1), capturedPoints(:,2), capturedPoints(:,3), 100,'filled','green')
plot_octahedron(points, [0,0,0], 0.5)
axis equal 
grid minor
view(35, 25)
