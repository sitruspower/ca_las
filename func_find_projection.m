function [px,py,pz]=func_find_projection(point, plane)
% plane = 3x3 array of points definind the plane
% point = point from which the projection is needed
plane=double(plane);
p1=plane(1,:);
p2=plane(2,:);
p3=plane(3,:);

x=double(point(1));
y=double(point(2));
z=double(point(3));
[a,b,c,d] = (func_points_to_plane(p1, p2, p3));

% given an plane equation ax+by+cz=d, project points xyz onto the plane
% return the coordinates of the new projected points
A=[1 0 0 -a; 0 1 0 -b; 0 0 1 -c; a b c 0];
B=[x; y; z; -d];
X=A\B;
px=X(1);
py=X(2);
pz=X(3);

end
