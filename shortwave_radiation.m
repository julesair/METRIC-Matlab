function out = shortwave_radiation_down(prm,date,sun_elev,z)
% calculates incoming short-wave radiation
% CALL:  sw_radiation_down(prm,date,sun_elev,z)
% INPUT: prm: struct containing solar constant [W/m2] as .Gsc
%        date: serial date of scene acquisition
%        sun_elev: sun_elevation in degree
%        z: height of scene above sea level (soon replaced by DEM)

DOY=date2doy(date);
dr=1+0.033*cos(2*pi/365*DOY); % inverse of square of relative distance to earth
tau_sw=0.75 + 2 * 10^-5 * z; %one-way broadband transmissivity
theta=(90-sun_elev)/360*2*pi; %solar zenith angle
Rs_down = prm.Gsc*cos(theta)*dr*tau_sw;

out = Rs_down;
end