function plot_octahedron(p, colour, alpha_plt)

            %% plot the cube 
            % cubic points             
            x1 = [p(1,1).' p(2,1).' p(5,1).']; % right top
            y1 = [p(1,2).' p(2,2).' p(5,2).']; % 
            z1 = [p(1,3).' p(2,3).' p(5,3).']; %         
            

            x2 = [p(1,1).' p(2,1).' p(6,1).']; % right bottom
            y2 = [p(1,2).' p(2,2).' p(6,2).']; % 
            z2 = [p(1,3).' p(2,3).' p(6,3).']; 
            
            x3 = [p(2,1).' p(3,1).' p(5,1).']; % left top
            y3 = [p(2,2).' p(3,2).' p(5,2).']; % 
            z3 = [p(2,3).' p(3,3).' p(5,3).']; 
            
            x4 = [p(2,1).' p(3,1).' p(5,1).']; % left bottom
            y4 = [p(2,2).' p(3,2).' p(5,2).']; % 
            z4 = [p(2,3).' p(3,3).' p(5,3).']; 
            
            
            x5 = [p(3,1).' p(4,1).' p(5,1).']; % left bottom
            y5 = [p(3,2).' p(4,2).' p(5,2).']; % 
            z5 = [p(3,3).' p(4,3).' p(5,3).']; 
            
            
            x6 = [p(3,1).' p(4,1).' p(6,1).']; % left bottom
            y6 = [p(3,2).' p(4,2).' p(6,2).']; % 
            z6 = [p(3,3).' p(4,3).' p(6,3).']; 
            
            
            x7 = [p(4,1).' p(1,1).' p(5,1).']; % left bottom
            y7 = [p(4,2).' p(1,2).' p(5,2).']; % 
            z7 = [p(4,3).' p(1,3).' p(5,3).']; 
                        
            x8 = [p(4,1).' p(1,1).' p(6,1).']; % left bottom
            y8 = [p(4,2).' p(1,2).' p(6,2).']; % 
            z8 = [p(4,3).' p(1,3).' p(6,3).']; 
            
            

            
            % assign the color of the cube based on the orientation
           
            
            hold on
            %DRAWING THE CUBE
            fill3(x1, y1, z1, colour, 'FaceAlpha',alpha_plt)
            fill3(x2, y2, z2, colour, 'FaceAlpha',alpha_plt)
            fill3(x3, y3, z3, colour, 'FaceAlpha',alpha_plt)
            fill3(x4, y4, z4, colour, 'FaceAlpha',alpha_plt)
            fill3(x5, y5, z5, colour, 'FaceAlpha',alpha_plt)
            fill3(x6, y6, z6, colour, 'FaceAlpha',alpha_plt)
            fill3(x7, y7, z7, colour, 'FaceAlpha',alpha_plt)
            fill3(x8, y8, z8, colour, 'FaceAlpha',alpha_plt)
%             view(35,35)
%             axis equal
%             grid minor
            pause(10/10000)      
        
end

