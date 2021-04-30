function plot_coord_from_ijk(neigh, dx, xmin, ymin, zmin, sz, color)

if color == 0
    color = [1,1,1];
end

% THIS PART TEMPORARILY COMMENTED! 
neigh = func_ijk_to_xyz(neigh, dx,xmin,ymin,zmin);
% hold on
scatter3(neigh(:,2),neigh(:,3),neigh(:,1),sz, 'filled', color)

pause(1/10000)
end

% plot_coord_from_ijk(active, dx, xmin, ymin, zmin, 10, [0,0,0])