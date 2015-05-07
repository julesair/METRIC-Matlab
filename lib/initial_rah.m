function [rah ux u200 Zom]= initial_rah(landsat, prm, meteodata, LAI, Ts)
    WDSP=meteodata.WDSP(prm.m_i); %other meteostations?
    station_height=2; %default
    Zomw=0.5; %station roughness length
    Zom=0.018*LAI;
    Zom(Zom<0.005)=0.005;  %bare agricultural field
    u200=WDSP*log(200/Zomw)/log(station_height/Zomw);
    ux=0.41*u200./log(200./Zom);
    rah=log(prm.z(2)/prm.z(1))./(ux*0.41);
end