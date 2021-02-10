function [xyz] = func_ijk_to_xyz(vector, dx,xmin,ymin,zmin)
% transforms ijk to vector coordinates

x = single((vector(:,1)-1)).*dx+xmin;
y = single(vector(:,2)-1).*dx + ymin;
z = single(vector(:,3)-1).*dx+zmin;
xyz=[x,y,z];
end