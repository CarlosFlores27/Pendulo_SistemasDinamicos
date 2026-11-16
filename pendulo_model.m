function output = pendulo_model(x, t, m, l, y0)
kf = x;
g = 9.81;

pendulo_ode = @(t, y) [y(2);
                       -(g/l) * sin(y(1)) - (kf/ m)* y(2)];

[~, y_sol] = ode45(pendulo_ode, t, y0);

output = y_sol(:, 1);

end