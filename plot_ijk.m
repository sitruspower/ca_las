function plot_ijk(neigh, dx, xmin, ymin, zmin, color)
% recalculating ijk to xyz
neigh = func_ijk_to_xyz(neigh, dx,xmin,ymin,zmin);
% plotting
scatter3(neigh(:,1),neigh(:,2),neigh(:,3),300, 'filled', color)
pause(1/10000)
end

% plot_ijk(active, dx, xmin, ymin, zmin, 'red')