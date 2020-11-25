function [rotated_points]=func_calculate_cubic_points3D(initial_point, alpha,beta, gamma, length)
    % Creates square points (can become a rectangle in the future)    
    % initial points of the cube without rotation:   
    
    
    a = length/sqrt(2);
    c1 = [a a a];
    c2 = [a -a a];
    c3 = [-a -a a];
    c4 = [-a a a];
    c5 = [a a -a];
    c6 = [a -a -a];
    c7 = [-a -a -a];
    c8 = [-a a -a];
    
    cubic_points = [c1;c2;c3;c4;c5;c6;c7;c8];
    points = cubic_points + initial_point;   

    % rotation matrices:    
    Rx = [cos(alpha)*cos(beta) ...
        cos(alpha)*sin(beta)*sin(gamma) - sin(alpha)*cos(gamma) ...
        cos(alpha)*sin(beta)*cos(gamma) + sin(alpha)*sin(gamma);
        
        sin(alpha)*cos(beta) ...
        sin(alpha)*sin(beta)*sin(gamma) + cos(alpha)*cos(gamma) ...
        sin(alpha)*sin(beta)*cos(gamma) - cos(alpha)*sin(gamma);
        
        -sin(beta) cos(beta)*sin(gamma) cos(beta)*cos(gamma)];       
        
    p1r = initial_point + c1*Rx;
    p2r = initial_point + c2*Rx;
    p3r = initial_point + c3*Rx;
    p4r = initial_point + c4*Rx;
    p5r = initial_point + c5*Rx;
    p6r = initial_point + c6*Rx;
    p7r = initial_point + c7*Rx;
    p8r = initial_point + c8*Rx;
    
    rotated_points = [p1r;p2r;p3r;p4r;p5r;p6r;p7r;p8r];
    
    %{
    % PLOTTING
       
    hold on
    % initial point:
    scatter3(initial_point(1),initial_point(2),initial_point(3), 'g', 'filled')
    
    % points of the cube without rotation:
    for i=1:8
        plot_coord = points(i,:);
        scatter3(plot_coord(1),plot_coord(2),plot_coord(3), 'b')
    end
    
    % points of the cube after rotation:
    for i=1:8
        plot_coord = rotated_points(i,:);
        scatter3(plot_coord(1),plot_coord(2),plot_coord(3), 'r', 'filled')
    end
    view(40,35)
    grid on
    axis equal
    hold off
    rotated_points;
    %}
end
