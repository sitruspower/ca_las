clear all

ticBytes(gcp);

n = 20;
A = 500;
a = zeros(1,n);
parfor i = 1:n
    a(i) = max(abs(eig(rand(A))));
end
tocBytes(gcp);

tocBytes(gcp)