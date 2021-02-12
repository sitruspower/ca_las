function func_plot_cube(cubic_points, colour, alpha_plt)

            %% plot the cube 
            % cubic points             
            x1 = cubic_points(1:4,1).'; % front wall
            y1 = cubic_points(1:4,2).'; 
            z1 = cubic_points(1:4,3).'; 
            x2 = cubic_points(5:8,1).'; % back wall
            y2 = cubic_points(5:8,2).'; 
            z2 = cubic_points(5:8,3).'; 
            x3 = [cubic_points(1:2,1).' cubic_points(6,1) cubic_points(5,1)]; % right wall
            y3 = [cubic_points(1:2,2).' cubic_points(6,2) cubic_points(5,2)]; 
            z3 = [cubic_points(1:2,3).' cubic_points(6,3) cubic_points(5,3)]; 
            x4 = [cubic_points(3:4,1).' cubic_points(8,1) cubic_points(7,1)]; % left wall
            y4 = [cubic_points(3:4,2).' cubic_points(8,2) cubic_points(7,2)]; 
            z4 = [cubic_points(3:4,3).' cubic_points(8,3) cubic_points(7,3)]; 
            x5 = [cubic_points(1,1) cubic_points(4,1) cubic_points(8,1) cubic_points(5,1)]; % top wall
            y5 = [cubic_points(1,2) cubic_points(4,2) cubic_points(8,2) cubic_points(5,2)]; 
            z5 = [cubic_points(1,3) cubic_points(4,3) cubic_points(8,3) cubic_points(5,3)]; 
            x6 = [cubic_points(2,1) cubic_points(3,1) cubic_points(7,1) cubic_points(6,1)]; % top wall
            y6 = [cubic_points(2,2) cubic_points(3,2) cubic_points(7,2) cubic_points(6,2)]; 
            z6 = [cubic_points(2,3) cubic_points(3,3) cubic_points(7,3) cubic_points(6,3)]; 

            
            % assign the color of the cube based on the orientation
           
            
            hold on
            %DRAWING THE CUBE
            fill3(x1, y1, z1, colour, 'FaceAlpha',alpha_plt)
            fill3(x2, y2, z2, colour, 'FaceAlpha',alpha_plt)
            fill3(x3, y3, z3, colour, 'FaceAlpha',alpha_plt)
            fill3(x4, y4, z4, colour, 'FaceAlpha',alpha_plt)
            fill3(x5, y5, z5, colour, 'FaceAlpha',alpha_plt)
            fill3(x6, y6, z6, colour, 'FaceAlpha',alpha_plt)
            
            pause(10/10000)      
        
end

