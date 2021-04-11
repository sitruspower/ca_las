function [rotated_points]=func_calculate_points3D(in, ...
                                    xmin, ymin, zmin,dx,...
                                    alpha,beta, gamma, length_cube)
% Creates square points (can become a rectangle in the future)    
% initial points of the cube without rotation:   

a = double(length_cube);
c = (a)*2; %5.1/3.6; %5.108/3.605; % long/short side
% c=a;
c1 = [ a  0  0];
c2 = [ 0  a  0];
c3 = [-a  0  0];
c4 = [0  -a  0];
c5 = [ 0  0  c];
c6 = [ 0  0 -c];

% transforming from idx to actual point coordinates:
% delta = 0;
% initial_point = [(single(in(1)-delta))*dx+xmin,...
%         single((in(2)-delta))*dx+ymin,...
%         single((in(3)-delta))*dx+zmin];

initial_point = func_ijk_to_xyz(in, dx,xmin,ymin,zmin);
cubic_points = [c1;c2;c3;c4;c5;c6];
points = cubic_points + initial_point;   

% rotation matrices:    
Rx = [cos(alpha)*cos(beta) ...
    cos(alpha)*sin(beta)*sin(gamma) - sin(alpha)*cos(gamma) ...
    cos(alpha)*sin(beta)*cos(gamma) + sin(alpha)*sin(gamma);

    sin(alpha)*cos(beta) ...
    sin(alpha)*sin(beta)*sin(gamma) + cos(alpha)*cos(gamma) ...
    sin(alpha)*sin(beta)*cos(gamma) - cos(alpha)*sin(gamma);

    -sin(beta) cos(beta)*sin(gamma) cos(beta)*cos(gamma)];       

p1r = initial_point + c1*Rx;
p2r = initial_point + c2*Rx;
p3r = initial_point + c3*Rx;
p4r = initial_point + c4*Rx;
p5r = initial_point + c5*Rx;
p6r = initial_point + c6*Rx;

rotated_points = [p1r;p2r;p3r;p4r;p5r;p6r];



end
