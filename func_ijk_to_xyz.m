function [xyz] = func_ijk_to_xyz(vector, dx,xmin,ymin,zmin)
% transforms ijk to vector coordinates
    delta = 0;
    x = single(vector(:,1)-delta).*dx + xmin;
    y = single(vector(:,2)-delta).*dx + ymin;
    z = single(vector(:,3)-delta).*dx + zmin;
    xyz=[x,y,z];
end