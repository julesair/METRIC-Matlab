function [RLdown, RLup] = lw_radiation(VapP,cC,epsilon0,Ts,z)
% Calculates outgoing and incoming longwave radiation from earth surface
% CALL: longwave_radiation(VapP,Temp,epsilon0,Ts)
% INPUT: VapP : Vapour Pressure at scene [kPa]
%        cH : coordinates [x y] of cold pixel 
%        epsilon0 : surface thermal emissivity n x m matrix
%        Ts : Surface Temperature n x m matrix

boltzmann = 5.67 * 10^-8;
RLup = epsilon0 .* Ts.^4 * boltzmann;
theta_sw=0.75+2*10^-5*z; %replace 40 with elevation
epsilon_atm=0.85*(-log(theta_sw))^0.09; %atmospheric emissivity 
RLdown = epsilon_atm*boltzmann*(Ts(cC(1),cC(2)))^4;
end