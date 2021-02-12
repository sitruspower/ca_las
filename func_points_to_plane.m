function [a,b,c,d] = func_points_to_plane(p1, p2, p3)

% This function plots a line from three points. 
% I/P arguments: 
%   p1, p2, p3 eg, p1 = [x y z]%
% O/P is: 
% normal: it contains a,b,c coeff , normal = [a b c]
% d : coeff
normal = cross(p1 - p2, p1 - p3);
d = p1(1)*normal(1) + p1(2)*normal(2) + p1(3)*normal(3);
d = -d;
a=normal(1);b=normal(2);c=normal(3);

% plotting plane:
if 0
    x = 1:3; y = 1:3;
    [X,Y] = meshgrid(x,y);
    Z = (-d - (normal(1)*X) - (normal(2)*Y))/normal(3);
    mesh(X,Y,Z)
end

end

