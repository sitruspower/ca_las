function neigh = func_assign_neighbuor(active, grain, l)
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
end
