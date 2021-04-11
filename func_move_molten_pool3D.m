
function T = func_move_molten_pool3D(T, xi, yi,zi, Tfilling, pos, dx)
	dy=dx;
    dz=dx;
    position = pos;
    % move s-l
    
    
    n=length(xi(:,1,1));
    m=length(yi(1,:,1));
    l=length(zi(1,1,:));
    
    for i=1:n
        for j=1:m
            for k=1:l
                if T(i,j,k) <= Tfilling
                    T (i,j,k) = Tfilling;
                end
            end       
        end
    end
    
    % limits
    xmin = min(yi(:,1,1));
    xmax = max(yi(:,1,1));
    
    ymin = min(yi(1,:,1));
    ymax = max(yi(1,:,1));
    
    zmin = min(zi(1,1,:));
    zmax = max(zi(1,1,:));
    
    % left point: working within zx slice. (xmiddle, y, zmax)
    found=0;
    j=0;
    i=round(n/2);
    k=l;
    
    while ~found
        j = j+1;
        if T(i,j,k)>Tfilling
            left_point = j;
            found=1;
        end
    end    
    
    % right point
    found=0;
    j=m;
    i=round(n/2);
    k=l;
 
    while ~found
        j = j-1;
        if T(i,j,k)>Tfilling
            right_point = j;
            found=1;
        end
    end    
    
    % saving to a buffering array Tbuf
    Tbuf = ones(size(T))*Tfilling;
    
    for j=1:(right_point-left_point)    % copying to the left
        Tbuf(:,j+position, :) = T(:,j+left_point, :);
    end
    T = Tbuf;
     
end

