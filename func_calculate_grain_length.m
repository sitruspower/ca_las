function Lnew = func_calculate_grain_length(points, P, plotvar)
    % calculating distance from given point to closest plane from octahedron
    % octa points are the points describing octahedron;
    % P is the point from which new length is calculated
%     
%     dx = plotvar(1);
%     xmin = plotvar(2);
%     ymin = plotvar(3);
%     zmin = plotvar(4);

    % Distance to the points of the side:
    DistSide = pdist2(points(1:4,:),P);
    [valSide , idxSide] = mink(DistSide, 2);
    % Finding what is closer: top or bottom
    DistTB = pdist2(points(5:6,:),P);
    [val , idxTop] = min(DistTB);
    idx =[idxSide;idxTop+4];   
    % defining plane from these 3 points
    plane=points(idx,:);
    % projected points on nearest plane
    [px,py,pz] = func_find_projection(P, plane);
    
%     % plotting the points:
%     hold on
%     plot_xyz([px,py,pz], dx, xmin, ymin, zmin, 'black'); pause(1/1000);
%     plot_xyz(points(idx,:), dx, xmin, ymin, zmin, 'black'); pause(1/1000);
%     % manually found distance:

    % here, 1.4142 comes from the base. 0.89514 comes from 
    % the angle between C and A axis. 
    % tg(w)=c*sqrt(2)/a. 'w' = 63.53deg. length=d/sin(w)
    Lnew=norm([px,py,pz]-P)*1.4142/0.89514;
end

