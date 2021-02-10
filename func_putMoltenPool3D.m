%% adding molten pool and reassigning struct


function [outputstruct, active] = func_putMoltenPool3D(struct, T, Tliq, Tsol, dx,xmin,ymin,zmin)

    s = size(struct);    
    n=s(1);
    m=s(2);
    l=s(3);
    
    %% assigning top surface to solid. Unneeccessary!
    if 0: 
    for i=1:n
        for j=1:m
            for k=1:l
                struct(i,j,k).temp = T(i,j,k);               
                struct(i,j,k).undercooling = Tliq-T(i,j);
                struct(i,j,k).fs = 1;  % fraction solid
%                 struct(i,j,k).init_point = [(i-1)*dx+xmin,...
%                                             (j-1)*dx+ymin,...
%                                             (k-1)*dx+zmin];
            end
        end
    end
    end
    
    %
    for i=1:n
        for j=1:m
            for k=1:l
                if T(i,j,k) <= Tsol
                    struct(i,j,k).fs = 1.;
                    struct(i,j,k).undercooling=0;     
                    struct(i,j,k).length=0;                
%                     struct(i,j,k).active = 0;           
                    struct(i,j,k).deltaTime=0;
%                     struct(i,j,k).init_point = [(i-1)*dx+xmin,...
%                                                 (j-1)*dx+ymin,...
%                                                 (k-1)*dx+zmin];
                elseif T(i,j,k)>Tsol && T(i,j,k)<=Tliq
                    struct(i,j,k).fs = 1 - (T(i,j,k)-Tsol)/(Tliq-Tsol);    
                    struct(i,j,k).undercooling=100;
                    struct(i,j,k).length=0;
%                     struct(i,j,k).active = 1;
                    struct(i,j,k).deltaTime=0;
%                     struct(i,j,k).init_point = [(i-1)*dx+xmin,...
%                                                 (j-1)*dx+ymin,...
%                                                 (k-1)*dx+zmin];
                else
                    struct(i,j,k).fs = 0;
                    struct(i,j,k).undercooling=100;
                    struct(i,j,k).length=0;
%                     struct(i,j,k).active = 1;
                    struct(i,j,k).deltaTime=0;
%                     struct(i,j,k).init_point = [(i-1)*dx+xmin,...
%                                                 (j-1)*dx+ymin,...
%                                                 (k-1)*dx+zmin];
                end
            end
        end
    end
   
    %% creating boundary cells. They will be activated during competition
    %BndCells=zeros(size(t));
    
    active=[];
    
    for i=1:n
        for k=1:l
                finished = 0;
            for j=1:m
                if ~finished && struct(i,j,k).fs ~= 1
                    %BndCells(i,j-1) = 1;
                    active = [active; i,j,k];
                    finished = 1;
                end
            end
        end
    end
    
    outputstruct = struct;
end