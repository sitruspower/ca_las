function plot_ijk(neigh, dx, xmin, ymin, zmin, color)


scatter3(single((neigh(:,1)-1)).*dx+xmin,...
                    single(neigh(:,2)-1).*dx + ymin,...
                    single(neigh(:,3)-1).*dx+zmin, 300, color)
                pause(1/10000)
end

% plot_ijk(active, dx, xmin, ymin, zmin, 'red')