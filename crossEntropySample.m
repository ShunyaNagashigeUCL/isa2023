%
clear
clc
close all

%%
p=linspace(0,1,100);
q=linspace(0,1,100);

[X,Y] = meshgrid(p,q);

H=-(X.*log2(Y)+(1-X).*log2(1-Y));
mesh(H)