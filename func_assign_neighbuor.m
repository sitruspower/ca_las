function neigh = func_assign_neighbuor(active, grain, n,m,l)
    top = 0;
    btm = 0;
    begin = 0;
    finish = 0;
    left = 0;
    right = 0;

    if active(grain,1) == 1  % 1
        begin = 0;
        finish = 1;
    end
    
    if active(grain,1) == n  % en
        begin = 1;
        finish = 0;
    end
    
    
    if active(grain,2) == 1  % 1
        left = 0;
        right = 1;
    end
    
    if active(grain,2) == m  % em
        left = 1;
        right = 0;
    end
    if active(grain,3) == 1  % one
        btm = 1;
        top = 0;
    end
    
    if active(grain,3) == l  % el
        btm = 0;
        top = 1;
    end

    
    
    neigh = [                        
     [active(grain,1),active(grain,2),    active(grain,3)+1];     % 1  %hactive(grain,1)gher z plane                        
     [active(grain,1)+1,active(grain,2),  active(grain,3)];   % 2                     
     [active(grain,1),  active(grain,2)-1,active(grain,3)];   % 3
     [active(grain,1)-1,active(grain,2),  active(grain,3)];   % 4                      
     [active(grain,1),  active(grain,2)+1,active(grain,3)];   % 5  %mactive(grain,1)ddle z plane                     
     [active(grain,1),active(grain,2),    active(grain,3)-1];     % 6      %hactive(grain,1)gher z plane
     
     [active(grain,1)+1,active(grain,2),  active(grain,3)+1]; % 7
     [active(grain,1),  active(grain,2)-1,active(grain,3)+1]; % 8
     [active(grain,1)-1,active(grain,2),  active(grain,3)+1]; % 9
     [active(grain,1),  active(grain,2)+1,active(grain,3)+1]; % 10
     [active(grain,1)+1,active(grain,2)+1,active(grain,3)+1]; % 11
     [active(grain,1)+1,active(grain,2)-1,active(grain,3)+1]; % 12
     [active(grain,1)-1,active(grain,2)-1,active(grain,3)+1]; % 13
     [active(grain,1)-1,active(grain,2)+1,active(grain,3)+1]; % 14  
     
     [active(grain,1)+1,active(grain,2)+1,active(grain,3)];   % 15
     [active(grain,1)+1,active(grain,2)-1,active(grain,3)];   % 16
     [active(grain,1)-1,active(grain,2)-1,active(grain,3)];   % 17
     [active(grain,1)-1,active(grain,2)+1,active(grain,3)];   % 18  
     
     [active(grain,1)+1,active(grain,2),  active(grain,3)-1]; % 19
     [active(grain,1),  active(grain,2)-1,active(grain,3)-1]; % 20
     [active(grain,1)-1,active(grain,2),  active(grain,3)-1]; % 21
     [active(grain,1),  active(grain,2)+1,active(grain,3)-1]; % 22
     [active(grain,1)+1,active(grain,2)+1,active(grain,3)-1]; % 23
     [active(grain,1)+1,active(grain,2)-1,active(grain,3)-1]; % 24
     [active(grain,1)-1,active(grain,2)-1,active(grain,3)-1]; % 25
     [active(grain,1)-1,active(grain,2)+1,active(grain,3)-1]; % 26 
             ];   %(x,y, z)
    
    if left == 1   % 2nd index can't go to +1: 
        neigh(26,:) = nan(1,3);
        neigh(22:23,:) = nan(2,3);
        neigh(18,:) = nan(1,3);
        neigh(14:15,:) = nan(2,3);
        neigh(10:11,:) = nan(2,3);
        neigh(5,:) = nan(1,3);
    end
    
    if  right == 1 % 2nd index can't go to -1:
        neigh(24:25,:) = nan(2,3);
        neigh(20,:) = nan(1,3);
        neigh(16:17,:) = nan(2,3);
        neigh(12:13,:) = nan(2,3);
        neigh(8,:) = nan(1,3);        
        neigh(3,:) = nan(1,3);
    end
    
    
    if begin == 1 % first index can't go to +1:
        neigh(23:24,:) = nan(2,3);
        neigh(19,:) = nan(1,3);
        neigh(15:16,:) = nan(2,3);
        neigh(11:12,:) = nan(2,3);
        neigh(7,:) = nan(1,3);        
        neigh(2,:) = nan(1,3);
    end
        
    if finish == 1  % first index can't go to minus:
        neigh(25:26,:) = nan(2,3);
        neigh(21,:) = nan(1,3);
        neigh(17:18,:) = nan(2,3);
        neigh(13:14,:) = nan(2,3);
        neigh(4,:) = nan(1,3);       
        neigh(9,:) = nan(1,3);
    end
        
    if top == 1
        neigh(7:14,:) = nan(8,3);
        neigh(1,:) = nan(1,3);
    end
    
    if btm == 1
        neigh(19:26,:) = nan(8,3);
        neigh(6,:) = nan(1,3);
    end
    
    neigh = neigh(all(~isnan(neigh),2),:); 
    
%{
if active(grain,3) == 1 % one, bottom plane
    neigh = [
    [active(grain,1),active(grain,2),active(grain,3)+1];       %hactive(grain,1)gher z plane
    [active(grain,1)+1,active(grain,2),  active(grain,3)];   
    [active(grain,1),  active(grain,2)-1,active(grain,3)];   
    [active(grain,1)-1,active(grain,2),  active(grain,3)];   
    [active(grain,1),  active(grain,2)+1,active(grain,3)];  %mactive(grain,1)ddle z plane

    [active(grain,1)+1,active(grain,2),  active(grain,3)+1]; 
    [active(grain,1),  active(grain,2)-1,active(grain,3)+1]; 
    [active(grain,1)-1,active(grain,2),  active(grain,3)+1]; 
    [active(grain,1),  active(grain,2)+1,active(grain,3)+1]; 
    [active(grain,1)+1,active(grain,2)+1,active(grain,3)+1]; 
    [active(grain,1)+1,active(grain,2)-1,active(grain,3)+1]; 
    [active(grain,1)-1,active(grain,2)-1,active(grain,3)+1]; 
    [active(grain,1)-1,active(grain,2)+1,active(grain,3)+1];
    [active(grain,1)+1,active(grain,2)+1,active(grain,3)];   
    [active(grain,1)+1,active(grain,2)-1,active(grain,3)];   
    [active(grain,1)-1,active(grain,2)-1,active(grain,3)];   
    [active(grain,1)-1,active(grain,2)+1,active(grain,3)];                 
    %[active(grain,1)+1,active(grain,2),  active(grain,3)-1]; [active(grain,1),  active(grain,2)-1,active(grain,3)-1]; [active(grain,1)-1,active(grain,2),  active(grain,3)-1]; [active(grain,1),  active(grain,2)+1,active(grain,3)-1]; [active(grain,1),active(grain,2),active(grain,3)-1];       %hactive(grain,1)gher z plane
    %[active(grain,1)+1,active(grain,2)+1,active(grain,3)-1]; [active(grain,1)+1,active(grain,2)-1,active(grain,3)-1]; [active(grain,1)-1,active(grain,2)-1,active(grain,3)-1]; [active(grain,1)-1,active(grain,2)+1,active(grain,3)-1];
         ];   %(x,y, z)

elseif  active(grain,3) == l % el, active(grain,3) = EL, top plane
    neigh = [
    [active(grain,1)+1,active(grain,2),  active(grain,3)];  
    [active(grain,1),  active(grain,2)-1,active(grain,3)];   
    [active(grain,1)-1,active(grain,2),  active(grain,3)];   
    [active(grain,1),  active(grain,2)+1,active(grain,3)];  %mactive(grain,1)ddle z plane
    [active(grain,1),active(grain,2),    active(grain,3)-1];       %hactive(grain,1)gher z plane

    [active(grain,1)+1,active(grain,2)+1,active(grain,3)];   
    [active(grain,1)+1,active(grain,2)-1,active(grain,3)];   
    [active(grain,1)-1,active(grain,2)-1,active(grain,3)];   
    [active(grain,1)-1,active(grain,2)+1,active(grain,3)];                 
    [active(grain,1)+1,active(grain,2),  active(grain,3)-1]; 
    [active(grain,1),  active(grain,2)-1,active(grain,3)-1]; 
    [active(grain,1)-1,active(grain,2),  active(grain,3)-1]; 
    [active(grain,1),  active(grain,2)+1,active(grain,3)-1]; 
    [active(grain,1)+1,active(grain,2)+1,active(grain,3)-1]; 
    [active(grain,1)+1,active(grain,2)-1,active(grain,3)-1]; 
    [active(grain,1)-1,active(grain,2)-1,active(grain,3)-1]; 
    [active(grain,1)-1,active(grain,2)+1,active(grain,3)-1];
         ];   %(x,y, z)


else 
    neigh = [                        
     [active(grain,1),active(grain,2),active(grain,3)+1];       %hactive(grain,1)gher z plane                        
     [active(grain,1)+1,active(grain,2),  active(grain,3)];                        
     [active(grain,1),  active(grain,2)-1,active(grain,3)];   
     [active(grain,1)-1,active(grain,2),  active(grain,3)];                        
     [active(grain,1),  active(grain,2)+1,active(grain,3)];  %mactive(grain,1)ddle z plane                     
     [active(grain,1),active(grain,2),active(grain,3)-1];       %hactive(grain,1)gher z plane

     [active(grain,1)+1,active(grain,2),  active(grain,3)+1]; 
     [active(grain,1),  active(grain,2)-1,active(grain,3)+1]; 
     [active(grain,1)-1,active(grain,2),  active(grain,3)+1]; 
     [active(grain,1),  active(grain,2)+1,active(grain,3)+1]; 
     [active(grain,1)+1,active(grain,2)+1,active(grain,3)+1]; 
     [active(grain,1)+1,active(grain,2)-1,active(grain,3)+1]; 
     [active(grain,1)-1,active(grain,2)-1,active(grain,3)+1]; 
     [active(grain,1)-1,active(grain,2)+1,active(grain,3)+1];                     
     [active(grain,1)+1,active(grain,2)+1,active(grain,3)];   
     [active(grain,1)+1,active(grain,2)-1,active(grain,3)];   
     [active(grain,1)-1,active(grain,2)-1,active(grain,3)];   
     [active(grain,1)-1,active(grain,2)+1,active(grain,3)];                 
     [active(grain,1)+1,active(grain,2),  active(grain,3)-1]; 
     [active(grain,1),  active(grain,2)-1,active(grain,3)-1]; 
     [active(grain,1)-1,active(grain,2),  active(grain,3)-1]; 
     [active(grain,1),  active(grain,2)+1,active(grain,3)-1]; 
     [active(grain,1)+1,active(grain,2)+1,active(grain,3)-1]; 
     [active(grain,1)+1,active(grain,2)-1,active(grain,3)-1]; 
     [active(grain,1)-1,active(grain,2)-1,active(grain,3)-1]; 
     [active(grain,1)-1,active(grain,2)+1,active(grain,3)-1];
             ];   %(x,y, z)
end
%}
end
