%% Import Script for EBSD Data

close all;
% ORIGINAL FILENAME

% Office PC Quasi2D folder
pname = 'D:\OneDrive - University of Nottingham\OneDrive - The University of Nottingham\1.3. Solidification Project\4. Modelling\1. CA Model FINAL\1.1CA_Quasi2D';
pname = 'C:\Users\Dima\OneDrive - The University of Nottingham\1.3. Solidification Project\4. Modelling\1. CA Model FINAL\1.1CA_Quasi2D _100mmsResults';
fname = [pname '\mystruct.ctf'];  % - copy" for cubic

% fname = [pname '\rand_struct.ctf'];  % - copy" for cubic


biggrainsize = 600; % perfect for 1mm grid
biggrainsize = 600.;
% smallerthan = 600; % avoids vcalculations of small grains

model = 1;

name = ' tetragonal';
if 1  % loading results
%% Specify Crystal and Specimen Symmetries
% crystal symmetry
CS = {... 
  'notIndexed',...
  crystalSymmetry('4/mmm', [3.6 3.6 5.2], 'mineral', ' tetragonal', 'color', [0.53 0.81 0.98]),...
  crystalSymmetry('12/m1', [5.1 5.2 5.3], [90,99.22,90]*degree, 'X||a*', 'Y||b', 'Z||c', 'mineral', 'monoclinic', 'color', [0.56 0.74 0.56])};

%% plotting convention
%4 
setMTEXpref('xAxisDirection','south');
setMTEXpref('zAxisDirection','outOfPlane');

%% Specify File Names

% path to files
pname = 'D:\OneDrive - University of Nottingham\OneDrive - The University of Nottingham\1.3. Solidification Project\4. Modelling\1. CA Model FINAL\1. Main Git\CA_grain_growth_laser_melting-main';
pname = 'C:\Users\Dima\OneDrive - The University of Nottingham\1.3. Solidification Project\4. Modelling\1. CA Model FINAL\1.1CA_Quasi2D';

original_EBSD = 0;
if original_EBSD == 1
    fname = [pname '\LP100V2p5Export.ctf']; 
end

%% Import the Data
% create an EBSD variable containing the data
ebsd = EBSD.load(fname,CS,'interface','ctf',...
  'convertEuler2SpatialReferenceFrame');
end % loading finished 

%% PARAMETERS
% EBSD Map processing
plot_ebsd =1; 
plot_ipf_key_ebsd = 1; % plotting ipf key for colouring
plot_crystals = 1; % plotting crystals on the EBSD map
% one of the two: 
grain_cubic_orient = 1;
grain_sphere_orient =1;

% ORIENTATION DISTRIBUTION FUNCTION
plot_ODF = 1;

% POLE FIGURE
plot_pole_fig = 1;

% INVERSE POLE FIGURE
plot_ipf = 1; % plotting IPF map


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotx2north % this command tell MTEX to plot the x coordinate pointing towards east

if model == 1
    plotzIntoPlane
else 
    plotzOutOfPlane
end

%plot(ebsd,'coordinates','on')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ebsd(' tetragonal').orientations;
grains = calcGrains(ebsd('indexed'),'theshold',1*degree)%1*degree
big_grains = grains(grains.grainSize > biggrainsize); % 500 lat, 200 for transverse
%       
%% 
% PLOTTING EBSD
if plot_ebsd == 1
    % plotting ebsd data: 
    f0=figure;
    plot(ebsd(' tetragonal'),ebsd(' tetragonal').orientations,'micronbar','off')
    % reconstruct grains with theshold angle 6 degree
    
    % smooth the grains to avoid the stair casing effect
    %grains = smooth(grains,5);

    hold on
    plot(grains.boundary,'lineWidth',.2)
    %hold off
    
    if plot_crystals == 1

        [grains,ebsd.grainId] = calcGrains(ebsd('indexed'));
        % 2. remove all very small grains. USEFUL BUT CREATES ABNORMAL
        % BOUNDARIES
        % ebsd(grains(grains.grainSize < 2)) = [];
        % 3. redo grain reconstruction
        [grains,ebsd.grainId] = calcGrains(ebsd('indexed'));
        % 4. plot the grain boundaries
        
        plot(grains.boundary,'lineWidth',0.5,'micronbar','off')
        % 5. select only very large grains
%           big_grains = grains(grains.grainSize < smallerthan); % 500 lat, 200 for transverse
          big_grains = grains(grains.grainSize > biggrainsize); % 500 lat, 200 for transverse
        % 6.  plot the crystals
        hold on
        %% TYPE 1; CUBIC CRYSTAL ORIENTED

        if grain_cubic_orient == 1
            hold on
            cS = crystalShape.hex(ebsd(' tetragonal').CS);
            plot(big_grains(' tetragonal'),0.8*cS,'linewidth',2,'colored')
            hold off
        end

        %% TYPE 2; ROTATED SPHERE
        if grain_sphere_orient == 1
            hold on            
            ipfKey = ipfColorKey(grains(' tetragonal'));
            plot(big_grains(' tetragonal'),ipfKey)
            hold off
        end
        legend off
    end
    if plot_ipf_key_ebsd==1
        % plotting EBSD key for IPF map:
        f1=figure;
        hold on
        ipfKey = ipfColorKey(grains(' tetragonal'));
        plot(ipfKey)
        hold off
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse Pole Figure\
if plot_ODF == 1
    %close all
    f2=figure
%     ebsd = ebsd(' tetragonal')
    %plot(ebsd.orientations,'Euler')
    odf = calcDensity(big_grains(' tetragonal').meanOrientation)
    ori = orientation.byEuler(0,0,0,ebsd(' tetragonal').CS);
    odf.eval(ori)
    plot3d(odf,'Euler', 'all')
    hold on
    %plot(ebsd.orientations,'Euler','MarkerEdgeColor','k')
    hold off
    
end


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse Pole Figure
if plot_ipf == 1
    f3=figure
    % this computes the colors for each orientation specified as input
    colors = ipfKey.orientation2color(big_grains(' tetragonal').meanOrientation);

    % this plots the grains colorized according to the RGB values stored in colors
    plot(big_grains(' tetragonal'),colors)
    f4=figure;
    plot(ipfKey,'complete','upper')
    h = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{1,0,1},{0,1,1},{1,2,0},{0,2,1},...
      ebsd(' tetragonal').CS);
    annotate(h.symmetrise,'labeled','backgroundColor','w')
    title('IPF color annotation')
    
    %% COMMENTED ON 04/01/2020
    %%%
    f5=figure;
    r = vector3d.Z;
    % puts points of the crystals on IPF Map!
    plotIPDF(big_grains(' tetragonal').meanOrientation,colors,vector3d.Z,...
  'MarkerSize',0.5*big_grains(' tetragonal').area,'markerEdgeColor','k')
    title('IPDF MEAN ORIENTATION MAP. Big Brains')
% plot the position of the z-Axis in crystal coordinates

%     f6=figure;
%     plotIPDF(ebsd(' tetragonal').orientations,r,'MarkerSize',5,...
%   'MarkerFaceAlpha',0.05,'MarkerEdgeAlpha',0.05)
%     
%     
%     plotIPDF(big_grains(' tetragonal').orientations,r,'MarkerSize',5,...
%   'MarkerFaceAlpha',0.05,'MarkerEdgeAlpha',0.05)
% 
% 
%     f7=figure;
%     plotIPDF(ebsd(' tetragonal').orientations,[vector3d.X,vector3d.Y,vector3d.Z]...
%         )%,'contourf','complete','upper')
    mtexColorbar
    
end



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pole FIGURE

if plot_pole_fig == 1
    f8=figure;
    h = Miller({1,0,0},{0,1,0},{0,0,1},{0,1,1},{1,1,0},{1,0,1},{1,1,1},ebsd(' tetragonal').CS);
    % plot their positions with respect to specimen coordinates
    % working:
%     plotPDF(ebsd(' tetragonal').orientations,h,'figSize','medium')
    
    % NEW, FOR BIG GRAINS:    
    plotPDF(big_grains(' tetragonal').meanOrientation,h,'figSize','medium')    
    title('IPDF MEAN ORIENTATION MAP. Big Brains')
    
%     r = vector3d.Z;
    % puts points of the crystals on IPF Map!
%     plotPDF(big_grains(' tetragonal').meanOrientation,colors,vector3d.Z,...
%   'MarkerSize',0.5*big_grains(' tetragonal').area,'markerEdgeColor','k')

    % the fixed specimen direction
    
    
    
    %% VERSION 2
    name = ' tetragonal'
    %set the pole figures to plot
    h=[Miller(0,0,1,ebsd(name).CS), Miller(0,1,0,ebsd(name).CS),Miller(1,0,0,ebsd(name).CS), ...
        Miller(1,1,0,ebsd(name).CS),Miller(1,0,1,ebsd(name).CS),Miller(0,1,1,ebsd(name).CS),Miller(1,1,1,ebsd(name).CS)];
    %plot the discrete pole figure
    f9=figure; 
    % FOR ALL THE GRAINS:
%     plotPDF(ebsd(name).orientations,h,'upper','projection','eangle','points','all','markersize',1);

    % FOR CHOSEN BIG GRAINS ONLY:   
    
    title('discrete pole figure') 
    plotPDF(big_grains(name).meanOrientation,h,'upper','projection','eangle','points','all','markersize',1);

    set(gcf, 'Position',  [50, 50, 800, 600])
    %plot the odf
    f10=figure; plotPDF(odf,h,'upper','projection','eangle','contourf','minmax');
    set(gcf, 'Position',  [50, 50, 800, 600])
    % title('Orientation Distribution Funtion')
    %annotate(modes(1), 'MarkerSize',1,'label','Mode 1');

    
end
save = 0;
if save ==1
    saveas(f2, 'odf_map.png')
    saveas(f1, 'ipf_key.png')
    saveas(f3, 'ipf_distrib.png')
    saveas(f0, 'ebsd.png')
end
