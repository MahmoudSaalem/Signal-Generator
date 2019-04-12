clc;
clear;
close all;

fs = 100;

ts1 = -2;
te1 = 2;
t1 = linspace(ts1, te1, (te1 - ts1) * fs);
m = 5 * ones(1, length(t1));
% m = sin(4*pi*t1);

ts2 = 0;
te2 = 4;
t2 = linspace(ts2, te2, (te2 - ts2) * fs);
h = ones(1, length(t2));

ts = ts1 + ts2;
te = te1 + te2;
t = linspace(ts, te, (te - ts) * fs);
y = conv(h, m);
y = y / fs;

y(end+1) = 0;

noise = 0 * randn(1, length(y));
y = y + noise;

signal = fs*deconv(y, h);
signal(end) = [];

plot(t1, signal)
grid on