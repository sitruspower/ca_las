function plot_coord_from_ijk(neigh, dx, xmin, ymin, zmin, sz, color)

if color == 0
    color = [1,1,1];
end


scatter3(single((neigh(:,1)-1)).*dx+xmin,...
                    single(neigh(:,2)-1).*dx + ymin,...
                    single(neigh(:,3)-1).*dx+zmin, sz, 'filled', color)
                pause(1/10000)
end

% plot_coord_from_ijk(active, dx, xmin, ymin, zmin, 10, [0,0,0])