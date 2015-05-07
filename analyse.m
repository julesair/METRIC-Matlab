%analyse ETrf
clear out;

for k=1:100
    k
    f=0.9+0.1*k;
    ETr=ETr_initial*f;
    
    %% 9. Iteration loop for computation of sensible heat flux H

    % Calculate initial values for aerodynamic resistance rah [s/m] and 
    % Friction velocity [m/s]
    % Calculate roughness length Zom [m] and windspeed at height
    % 200m above ground [m] from meteodata.
    [rah, ux, u200, Zom]=initial_rah(landsat,prm,meteodata,LAI);

    %Calculate ETr [mm/s] at Cold anchor pixel from meteodata
    lambda=(2.501-0.00236*(Ts-273.15))*10^6; %latent heat of vaporization [J/kg]
    dRnG_COLD=Rn(cC(1),cC(2))-G(cC(1),cC(2));
    %ETr = ETreference(meteodata,prm.m_i,landsat.TIME,lambda(cC(1),cC(2)),dRnG_COLD,rah(cC(1),cC(2)));

    %iteration loop:
    i=1; %set count to 1
    rah_mean(i)=nanmean(nanmean(rah));
    delta_mean(i)=abs(rah_mean(i));
    while (delta_mean(i)>0.0001) & (i<1)
        H = calibrate(Rn,G,Ts,rah,cH,cC,ETr,lambda);
        [rah] = stability_correction(Ts,H,ux,u200,Zom);
        i=i+1;
        rah_mean(i)=nanmean(nanmean(rah));
        delta_mean(i)=abs(rah_mean(i)-rah_mean(i-1));
    end

    H = calibrate(Rn,G,Ts,rah,cH,cC, ETr,lambda);

    ET= 3600./lambda.*(Rn - G - H);
    
    ETrf=ET/(ETr*3600);
    [N, edges]=histcounts(ETrf);
    out.N{k}=N;
    out.edges{k}=edges;
    out.ETr(k)=ETr*3600
    end;
