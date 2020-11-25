Readme file created on 24/11/2020

1. Run Main_Comsol2Grains3D.m

initialisation:
MeltPool.csv  =>>> MeltPoolExtended.csv =>>> InterpolatedTemperatureGrid.mat =>>> RandomOrientation.mat
assign dx,dy,dz,Tliq,Tsol, velocity, A. Check timestepping.

result: pos=__.fig, struct=__.mat


2. Postprocessing the model:

2.1 check the last struct filename, for example, "struct=41.mat"
2.2 Open struct_to_ctf_export.m
Change struct_filename to e.g. "struct=41.mat"
Change output_filename to e.g. "model_export_v=2p5.mat"

3. Using EBSD Data in MTEX matlab extension





