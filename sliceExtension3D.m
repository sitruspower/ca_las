% sliceExtension3D

clear all;
xplus = 2.5; %1.1;%2.5;
xminus = 0;
inputfile = 'Temperature_100mms_Normal.csv';  % fast
inputfile = 'Temperature_100mms.csv' % full pres. slow
rows = csvread(inputfile); rows = single(rows);
x = rows(:,1);
y = rows(:,2);  % fixed
z = rows(:,3);
v = rows(:,4);

% adding desirable minimum and maximum y 
xmin = min(x) - xminus;
x = [x; xmin];
y = [y; y(1,1)];
z = [z; z(1,1)];
v = [v; NaN];

xmax = max(x)+xplus;
x = [x; xmax];
y = [y; y(1,1)];
z = [z; z(1,1)];
v = [v; NaN];



csvwrite('MeltPoolExtended.csv',[x,y,z,v]);
