% test random orientation

run assignRandomOrientation3D.m

struct = open('RandomOrientation.mat');

save('rand_struct.mat', 'struct')

run struct_to_ctf_export.m


