function [epsilon0 epsilonNB] = thermal_emissivity(LAI,albedo)
% Calculates surface thermal emissivity as proposed by SEBAL
% CALL:  thermal_emissivity(NDVI,albedo)
% INPUT: NDVI: n x m matrix with values [-1 ... 1]
%        albedo: n x m matrix with values [0 ... 1]


epsilon0 = 0.97+0.0033*LAI;
epsilonNB = 0.95+0.01*LAI;

epsilon0(LAI>3) = 0.98;
epsilonNB(LAI>3) = 0.98;

end