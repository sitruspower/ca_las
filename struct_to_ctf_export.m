clear all;
LONGIT = 1;  % For longitudinal cross section set 1;
struct_filename = 'mystruct.mat'
output_name = 'mystruct.ctf'

% Loading results from struct:
if 1
    s = open(struct_filename);
    s = s.struct;
    %mesh_struct = open('Struct_mesh.mat');
    [n,m,l] = size(s.alpha);
    % Euler Angles output:
    alpha = [s.alpha];
    beta = [s.beta];
    gamma = [s.gamma];
    
%     % reshaping inputs into 3D:
%     alpha = reshape(alpha,n,m,l);
%     beta = reshape(beta,n,m,l);
%     gamma = reshape(gamma,n,m,l);

    % export transverse XY map: 
    tic
    if LONGIT ==1
        alpha_mid_XZ = zeros(m,l);
        beta_mid_XZ = zeros(m,l);
        gamma_mid_XZ = zeros(m,l);
        % was a parfor loop:
        for i=1:m % X loop
            for j = 1:l  % Z loop        
                alpha_mid_XZ(i,j) = alpha(round(n/2),i,j)*180/pi;
                beta_mid_XZ(i,j) =   beta(round(n/2),i,j)*180/pi;
                gamma_mid_XZ(i,j) = gamma(round(n/2),i,j)*180/pi;        
            end
        end
    toc
        
    else
        alpha_top_XY = zeros(n,m);
        beta_top_XY = zeros(n,m);
        gamma_top_XY = zeros(n,m);
        for i=1:n % X loop
            for j = 1:m  % Y loop        
                alpha_top_XY(i,j) = alpha(i,j,round(l));
                beta_top_XY(i,j) = beta(i,j,round(l));
                gamma_top_XY(i,j) = gamma(i,j,round(l));        
            end
        end

    end
end

% writing the header to the file:
if 1
    
    if LONGIT ==1
        XCells = m; % X
        YCells = l; % Z
        
    else        
        XCells = m; % X
        YCells = n; % Y
    end
    %header='Channel Text File\nPrj	Project 1\nAuthor		\nJobMode	Grid		\nXCells	542		\n'
    lines = string.empty;
    lines(1) = string('Channel Text File\n');
    lines(2) = string('Prj	Project 1	\n');
    lines(3) = string('Author	\n');
    lines(4) = string('JobMode	Grid\n');
    lines(5) = sprintf('XCells\t %s \n', string(XCells));
    lines(6) = sprintf('YCells\t %s \n', string(YCells));
    lines(7) = string('XStep	1\n');
    lines(8) = string('YStep	1\n');
    lines(9) = string('AcqE1	90\n');
    lines(10) = string('AcqE2	90\n');
    lines(11) = string('AcqE3	0\n');
    lines(12) = string('Euler angles refer to Sample Coordinate system (CS0)!	Mag	200	Coverage	80	Device	0	KV	15	TiltAngle	70.0104	TiltAxis	0	DetectorOrientationE1	0.8522	DetectorOrientationE2	98.8425	DetectorOrientationE3	359.3985	WorkingDistance	17.6358	InsertionDistance	193.9844\n');
    lines(13) = string('Phases	2\n');
    lines(14) = string('3.605;3.605;5.180	90.000;90.000;90.000	 tetragonal	5	137			"ActaCrys,44B,116-120 "\n');
    lines(15) = string('5.146;5.212;5.313	90.000;99.220;90.000	Zr02 monoclinic	2	14			"JAppCrys,27,802-844"\n');
    lines(16) = "Phase	X	Y	Bands	Error	Euler1	Euler2	Euler3	MAD	BC	BS\n";

    fileID = fopen(output_name,'w');
    for i=1:length(lines)
        fprintf(fileID, lines(i));
    end
end


if LONGIT == 1  % then in XZ plane, j stands for Z
    for i=1:XCells
        for j=1:YCells

            EU1 = alpha_mid_XZ(i,j);
            EU2 = beta_mid_XZ(i,j);
            EU3 = gamma_mid_XZ(i,j);

            strwrite = sprintf('%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t \n',...
            string(1),string(j-1),string(i-1),string(0),string(0),string(EU1),string(EU2),string(EU3),string(0),string(0),string(0));
             % Phase	  X        	Y	       Bands	  Error	    Euler1	   Euler2	     Euler3	       MAD	    BC    BS


            fprintf(fileID, strwrite);
        end

    end
end


fclose(fileID);
%exporting lines:







