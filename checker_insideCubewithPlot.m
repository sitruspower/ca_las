close all;

points =[
    0.0997    0.4498    0.3010
    0.1003    0.4490    0.3003
    0.0995    0.4493    0.2994
    0.0989    0.4501    0.3001
    0.1005    0.4507    0.3006
    0.1011    0.4499    0.2999
    0.1003    0.4502    0.2990
    0.0997    0.4510    0.2997];

% front plane: points(1:4)
% back plane: points(5:8)
% right plane: points(1:2), points(5:6)
% left plane: points(3:4), points(7:8)


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

alpha = 0.2;
f = figure('Position',[2600 100 1000 600]);
movegui(f);
hold on
fill3(x1, y1, z1, 'red', 'FaceAlpha',alpha)
fill3(x2, y2, z2, 'red', 'FaceAlpha',alpha)
fill3(x3, y3, z3, 'red', 'FaceAlpha',alpha)
fill3(x4, y4, z4, 'red', 'FaceAlpha',alpha)
fill3(x5, y5, z5, 'red', 'FaceAlpha',alpha)
fill3(x6, y6, z6, 'red', 'FaceAlpha',alpha)

A = [points(2,:)];
B = [points(6,:)];
C = [points(7,:)];
D = [points(3,:)];
E = [points(1,:)];
F = [points(5,:)];
G = [points(8,:)];
H = [points(4,:)];

I = (D + F) /2; % centre
sz=500
scatter3(I(1), I(2), I(3), sz/2, 'filled', 'magenta')
scatter3(A(1), A(2), A(3), sz,'filled', 'red')
scatter3(C(1), C(2), C(3), sz, 'filled', 'green')
scatter3(H(1), H(2), H(3), sz, 'filled', 'blue')

scatter3(D(1), D(2), D(3), sz, 'filled', 'yellow')

Xlength = norm(A-D)
Ylength = norm(C-D)
Zlength = norm(H-D)

Xlocal = (A-D)/Xlength
Ylocal = (C-D)/Ylength
Zlocal = (H-D)/Zlength

for i=1:1000
    point_in = I + 0.8*(rand(1,3)-0.5)*sqrt(Xlength^2+Ylength^2+Zlength^2);
    P = point_in;

    V = (P-I)*2;
    px = abs(dot(V,Xlocal));
    py = abs(dot(V,Ylocal));
    pz = abs(dot(V,Zlocal));

    if px<=Xlength && py<=Ylength && pz<=Zlength    
        scatter3(P(1), P(2), P(3), 'filled', 'green')
        %fprintf('inside!')
    else    
        scatter3(P(1), P(2), P(3), 'filled', 'blue')
        %fprintf('outside!')
    end

end
hold off

    
    

%px = V.*
%P = [0.4750    0.1000    0.3250];  %neigh(p,:).*dx. POINT OF INTEREST


%scatter3(C(1), C(2), C(3), 'red', 'filled')
%scatter3(I(1), I(2), I(3), 'blue', 'filled')

axis equal


dx = 0.0250;
dy = 0.0250;
dz = 0.0250;

i = 4;
j = 18;
k = 12;


grid on
hold off

%% function with dot products checker 
function [bool, cx, cy, Lnew]= func_check_inside(cubic_points, point, dx, dy, i,j, L, alpha, beta, gamma)
    % compares radius-vector from the point with perimeter
               
        
        A = cubic_points(1,:);
        B = cubic_points(2,:);
        C = cubic_points(3,:);
        D = cubic_points(4,:);
        AP = point-A;
        AD = D-A;
        AB = B-A;

        if dot(AP,AD)>0 && dot(AP,AD)<dot(AD,AD) && ...
           dot(AP,AB)>0 && dot(AP,AB)<dot(AB,AB)
            %fprintf('point is inside\n')
            bool = 1;  % point is captured
            % nearest x:
            [val,idx] = mink( (abs(cubic_points(:,1)-point(1,1)*ones(4,1)) + abs(cubic_points(:,2)-point(1,2)*ones(4,1))), 2);
            cl1 =cubic_points(idx(1),:);
            cl2 =cubic_points(idx(2),:);
            L1=sqrt( (cl1(1) - point(1))^2 +  (cl1(2) - point(2))^2);
            L2=sqrt( (cl2(1) - point(1))^2 +  (cl2(2) - point(2))^2);
            
            Lnew = sqrt(2)*(min(L1/sqrt(2), sqrt(2)*dx)+ min(L2/sqrt(2), sqrt(2)*dx) );
            
            x0 = j*dx;
            y0 = i*dy;
            
            %middle point:
            cx = x0 + abs(L-Lnew)*cos(alpha);
            cy = y0 + abs(L-Lnew)*sin(alpha);
            
        else
            %fprintf('point is outside\n')
            bool = 0;  % point is not captured
            Lnew = 0;
            cx = point(1,1);
            cy = point(1,2);
        end
end

