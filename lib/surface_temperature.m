function Ts = surface_temperature(landsat,epsilonNB)
% Calculates Surface Temperature from Landsat 7 Band 6
% CALL:  surface_temperature(prm,BAND_6,mask,epsilon0)
% INPUT: prm: struct containing coefficients .K1,.K2 for at satellite T
%         BAND_6: n x m matrix
%         mask: logical matrix of size Band 3&4, true cells are set NaN
%         epsilon0: surface thermal emissivity n x m

Rc=landsat.A{7};
epsilonNB=ones(size(epsilonNB));
Ts=(~landsat.mask)*landsat.K(2)./log(epsilonNB*landsat.K(1)./Rc + 1);
end