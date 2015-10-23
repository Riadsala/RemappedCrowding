function g = GenGabor(n, theta)
x = repmat(1:n, [n,1])-round(n/2);
y = x';

lambda =7;

phi = 0;
sigma = 4;
psi = 1;

x1 =  x.*cos(theta) + y.*sin(theta);
y1 = -x.*sin(theta) + y.*cos(theta);

z1 = x1.^2 + (psi.^2).*(y1.^2);
z2 = 2*pi*(x1./lambda) + phi;

g = exp(-(z1)./(2*sigma.^2)) .* cos(z2);
g  = 0.5*g./max(abs(g(:)));
end