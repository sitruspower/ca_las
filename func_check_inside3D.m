
%% function with dot products checker 


function [bool, cx, cy,cz,Lnew]= func_check_inside...
    (points, P, dx, dy,dz, i,j,k, L, alpha, beta, gamma, initial_coordinates)
    % points - cubic vicinity from the initial cell;
    % P - coordinates of the neighbouring cell centre to be captured
    
    %0.1 ms for calculations 
    %% reassigning coordinates "names" for convenience
    x1 = points(1:4,1).'; % front wall
    y1 = points(1:4,2).'; 
    z1 = points(1:4,3).'; 
    x2 = points(5:8,1).'; % back wall
    y2 = points(5:8,2).'; 
    z2 = points(5:8,3).'; 
    x3 = [points(1:2,1).' points(6,1) points(5,1)]; % right wall
    y3 = [points(1:2,2).' points(6,2) points(5,2)]; 
    z3 = [points(1:2,3).' points(6,3) points(5,3)]; 
    x4 = [points(3:4,1).' points(8,1) points(7,1)]; % left wall
    y4 = [points(3:4,2).' points(8,2) points(7,2)]; 
    z4 = [points(3:4,3).' points(8,3) points(7,3)]; 
    x5 = [points(1,1) points(4,1) points(8,1) points(5,1)]; % top wall
    y5 = [points(1,2) points(4,2) points(8,2) points(5,2)]; 
    z5 = [points(1,3) points(4,3) points(8,3) points(5,3)]; 
    x6 = [points(2,1) points(3,1) points(7,1) points(6,1)]; % top wall
    y6 = [points(2,2) points(3,2) points(7,2) points(6,2)]; 
    z6 = [points(2,3) points(3,3) points(7,3) points(6,3)]; 

    A = [points(2,:)];B = [points(6,:)];C = [points(7,:)];D = [points(3,:)];
    E = [points(1,:)];F = [points(5,:)];G = [points(8,:)];H = [points(4,:)];

    %% calculating: 
    I = (D + F) /2; % centre
    
    alpha = 0.2;
    sz=500;

    % norm vectors:
    Xlength = norm(A-D);
    Ylength = norm(C-D);
    Zlength = norm(H-D);

    % new local coordinates
    Xlocal = (A-D)/Xlength;
    Ylocal = (C-D)/Ylength;
    Zlocal = (H-D)/Zlength;

    % double of the vector from point to centre of the cube:
    V = (P-I)*2;
    px = abs(dot(V,Xlocal));
    py = abs(dot(V,Ylocal));
    pz = abs(dot(V,Zlocal));


    % Checking if the point is inside:
    if px<=Xlength && py<=Ylength && pz<=Zlength
        % fprintf('inside!\n')
        
        bool = 1;
        % nearest x:
        [val,idx] = mink( (abs(points(:,1)-P(1,1)*ones(8,1)) + ...
                           abs(points(:,2)-P(1,2)*ones(8,1)) + ...
                           abs(points(:,3)-P(1,3)*ones(8,1))), ...
        3);
        cl1 =points(idx(1),:);
        cl2 =points(idx(2),:);
        cl3 =points(idx(3),:);
        
        % determining maximum length between cl 12, 23, 31
        [val,idx] = max([norm(cl1-cl2), norm(cl2-cl3), norm(cl3-cl1)]);
        
        if idx == 1
            % cl1 and cl2 are distanced. cl3 is the "head"
            S1 = cl3; S2 = cl2; S3 = cl1;
        elseif idx == 2
            % cl23 is the biggest, cl1 is at the "head"
            S1 = cl1; S2 = cl2; S3 = cl3;
        else
            % idx=3; cl31 is the longest.
            S1 = cl2; S2 = cl1; S3 = cl3;
        end
        
        %% projecting the point onto the plane:        
        % vectors from two points:
        S1S2 = S1-S2;
        S1S3 = S1-S3;        
        % normal to the plane:
        n=cross(S1S3,S1S2)/norm(cross(S1S3,S1S2));
        D = -dot(n,S1);     % plane coefficient
        d = (dot(n,P) + D); % distance from the point P to plane
        C = P - n * d;      % projection of point P
        
        %% finding the lengths. CQ - normal from C to S1S2. CR = to S1S3
        S1C = S1-C;
        Q = C + dot(S1C,S1S2) / dot(S1S2,S1S2) * S1S2;
        R = C + dot(S1C,S1S3) / dot(S1S3,S1S3) * S1S3;
        
        %QS1 = Q-S1
        QS1 = norm(Q-S1);
        QS2 = norm(Q-S2);
        RS1 = norm(R-S1);
        RS2 = norm(R-S2);
        
        % finding the lengths S2Q, S1Q, S1R, S3R:
        L12 = 1/2*(min(QS1/sqrt(3), sqrt(3)*dx) + min(QS2/sqrt(3), sqrt(3)*dx));
        L13 = 1/2*(min(RS1/sqrt(3), sqrt(3)*dx) + min(RS2/sqrt(3), sqrt(3)*dx));      
        Lnew = sqrt(2) * max(L12, L13);        

        x0 = j*dx;
        y0 = i*dy;
        z0 = i*dz;
        
        %% PLOTTING
        
        % if want to plot -> then change to"if 1":
        if 0
            % DEFINING FIGURE POSITION
%             f = figure('Position',[2600 100 1000 600]);
%             movegui(f);
%             hold on

            % initial point of the cube:    
%             hold on
            scatter3(initial_coordinates(1), initial_coordinates(2), initial_coordinates(3), sz, 'red')


            %  PLOTTING VECTORS USING FUNCTION AT THE BOTTOM
            a=plotvector(S2,S1);
            line(a(1,:),a(2,:),a(3,:),'Color','red','LineStyle','--')
            a=plotvector(S3,S1);
            line(a(1,:),a(2,:),a(3,:),'Color','red','LineStyle','--');

            % DRAWING THE POINT OF INTEREST!!!! and its projection
            scatter3(P(1), P(2), P(3), sz/3, 'filled', 'green')
            scatter3(C(1), C(2), C(3), sz/6, [150 80 60]/256, 'filled')

            % DRAWING PROJECTION OF THE POINT
            scatter3(Q(1), Q(2), Q(3), sz/6, 'filled', 'cyan')
            scatter3(R(1), R(2), R(3), sz/6, 'filled', 'cyan')

            % DRAWING THREE POINTS TO DETERMINE LENGTH
            scatter3(S1(1), S1(2), S1(3), sz, 'filled', 'red') % centre
            scatter3(S2(1), S2(2), S2(3), sz, 'filled', 'blue')
            scatter3(S3(1), S3(2), S3(3), sz, 'filled', 'blue')


            % DRAWING THE CUBE
            fill3(x1, y1, z1, 'red', 'FaceAlpha',alpha)
            fill3(x2, y2, z2, 'red', 'FaceAlpha',alpha)
            fill3(x3, y3, z3, 'red', 'FaceAlpha',alpha)
            fill3(x4, y4, z4, 'red', 'FaceAlpha',alpha)
            fill3(x5, y5, z5, 'red', 'FaceAlpha',alpha)
            fill3(x6, y6, z6, 'red', 'FaceAlpha',alpha)

            scatter3(A(1), A(2), A(3), sz,'filled', 'red')
            scatter3(C(1), C(2), C(3), sz, 'filled', 'green')
            scatter3(H(1), H(2), H(3), sz, 'filled', 'blue')
%             scatter3(D(1), D(2), D(3), sz, 'filled', 'yellow')

            axis equal
            grid on
            view([15 15])
%             hold off
            % input('press any key to continue...')
            pause(300/1000)
%             close all
        end        
        
        
        %middle point: REQUIRES CORRECTION FOR 3D!
        cx = x0 + abs(L-Lnew)*cos(alpha);
        cy = y0 + abs(L-Lnew)*sin(alpha);
        cz = z0 + abs(L-Lnew)*sin(alpha);

    else
        % fprintf('outside!\n')
        bool = 0;  % point is not captured
        Lnew = 0;
        cx = P(1,1);
        cy = P(1,2);
        cz = P(1,3);
        
        %% PLOTTING!!        
        %{
        hold on
        % initial point of the cube:        
        scatter3(in_coord(1), in_coord(2), in_coord(3), sz, 'red')
        
        % DRAWING THE POINT OF INTEREST!!!! and its projection
        scatter3(P(1), P(2), P(3), sz/3, 'filled', 'green')       
        
        % DRAWING THE CUBE
        fill3(x1, y1, z1, 'red', 'FaceAlpha',alpha)
        fill3(x2, y2, z2, 'red', 'FaceAlpha',alpha)
        fill3(x3, y3, z3, 'red', 'FaceAlpha',alpha)
        fill3(x4, y4, z4, 'red', 'FaceAlpha',alpha)
        fill3(x5, y5, z5, 'red', 'FaceAlpha',alpha)
        fill3(x6, y6, z6, 'red', 'FaceAlpha',alpha)
        
        axis equal
        hold off
        grid on
        view([15 15])
        % input('press any key to continue...')
        pause(3/1000)
        close all
        %}
    end
        
    function a = plotvector(S2,S1)
        % plots a vector defined by two points
        a=[S2(1), S1(1); S2(2), S1(2); S2(3), S1(3)];
        line(a(1,:),a(2,:),a(3,:),'Color','red','LineStyle','--')
    end

end
