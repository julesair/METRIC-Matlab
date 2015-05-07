function rho_air = air_density(Ts,dT,z)

    Ta=Ts-dT;
    P=(101.3*((293-0.0065*u)/293)^5.26);
    rho_a=P*1000./(287.058*Ta);
    
end