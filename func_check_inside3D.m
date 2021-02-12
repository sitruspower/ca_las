function [IsInside]= func_check_inside3D...
    (points, P) % dx, i,j,k, L, initial_coordinates
    % points = coordinates of verticies. (6,3), or (any,3)
    % P = array of points, (n,3). All the neighbours are checked
    % simultaneously.
    
    x = double(points(:,1));
    y = double(points(:,2));
    z = double(points(:,3));
    P = double(P);
    
    tri = delaunayn([x y z]); % Generate delaunay triangulization
    tn = tsearchn([x y z], tri, P); % Determine which triangle point is within
    IsInside = ~isnan(tn); % Convert to logical vector

    
end