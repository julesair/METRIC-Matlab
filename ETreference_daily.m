function ETr = ETreference(meteodata,m_i,time,lambda,dRnG_COLD)
% 

Cn=66;
Cd=0.25;
time=datevec(time);
time=round(time(4)+time(5)/60,0);
u2=meteodata.WDSP(m_i);
z=meteodata.LONLATELEV(3);
lambda=lambda*10^-6;
dRnG_COLD=dRnG_COLD*3600/10^6;
Tmax=meteodata.MAX(m_i-1:m_i,1);
Tmin=meteodata.MIN(m_i:m_i+1,1);
T=Thourly(Tmax(2),Tmin(1),Tmax(1),Tmin(2),time);
slope=4098*0.6108*exp(17.27*T/(T+237.3))/(T+237.3)^2;
P=101.3*((293-0.0065*z)/293)^5.26;
gamma=1.013*10^-3*P/(0.622*lambda);
e_sat=0.6108*exp(17.27*T/(T+237.3));
e_act=e_sat*meteodata.HUM(m_i)/100;

ETr = 0.408*slope*dRnG_COLD+gamma*Cn/(T+273)*u2*(e_sat-e_act)/(slope+gamma*(1+Cd*u2));


ETr=ETr/3600; %mm/s

end


    function T = Thourly(Tmax,Tmin,Tmax_t0,Tmin_t2, varargin)
    % Tmax=10.3; %max
    % Tmax_t0=4.1; %day before
    % Tmin=-3.3; %min
    % Tmin_t2=-3.3; %min following day

    t_sunset=18; %Time of sunset
    t_sunrise=6; %Time of sunrise

    t_sunrise_t2=t_sunrise+24; %Time of sunrise next day
    t_Tmax=t_sunset-4; %Time of max temperature

    T_sunset_t0=Tmax_t0-0.39*(Tmax_t0-Tmin); %Sunset-Temperature the day before
    T_sunset=Tmax-0.39*(Tmax-Tmin_t2); %Sunset-Temperature current day
    T(t_sunset)=T_sunset; 


    z=0.5; %default
    a2=(Tmin_t2-T_sunset)/(t_sunrise_t2-t_sunset)^z;
    a1=(Tmin-T_sunset_t0)/(t_sunrise+24-t_sunset)^z;

    for h=1:24
        t=h;
        if t>0 && t<=t_sunrise

            T(h)=T_sunset_t0+a1*(t+24-t_sunset)^0.5;
        elseif t>t_sunrise && t<=t_Tmax

           T(h)=Tmin+(Tmax-Tmin)/2*(1+sin(pi*(t-t_sunrise)/(t_Tmax-t_sunrise)-pi/2));
       elseif t>t_Tmax && t<=t_sunset

           T(h)=T_sunset+(Tmax-T_sunset)*sin(pi/2*(1+(t-t_Tmax)/(t_sunset-t_Tmax)));
       elseif t>t_sunset && t<=t_sunrise_t2;

           T(h)=T_sunset+a2*(t-t_sunset)^0.5;
        end
    end;

    if nargin==5
        T=T(varargin{1});
    end

end