function [IsInside]= func_check_inside3D...
    (points, P, triang_metrix) % dx, i,j,k, L, initial_coordinates
    % points = coordinates of verticies. (6,3), or (any,3)
    % P = array of points, (n,3). All the neighbours are checked
    % simultaneously.

%     x = (points(:,1));
%     y = (points(:,2));
%     z = (points(:,3));
%     P = double(P);
    
    triang = 0;
    if triang ==1
%         TRIANGULATION APPROACH. SLOW
        x = double(points(:,1));
        y = double(points(:,2));
        z = double(points(:,3));
        P = double(P);
        tri = delaunayn([x y z]);     % Generate delaunay triangulation
        tn = tsearchn([x y z], tri, P); % Determine which triangle point is within
        IsInside = ~isnan(tn); % Convert to logical vector
    
    
    else       
        TR = triangulation(triang_metrix,[double(points(:,1)) double(points(:,2)) double(points(:,3))]);
        tn = tsearchn([points(:,1) points(:,2) points(:,3)], TR, P); % Determine which triangle point is within
        IsInside = ~isnan(tn); % Convert to logical vector

    end
    
    
    
end