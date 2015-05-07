function [H, rho_a, dT_hot, dT_cold] = calibrate(Rn,G,Ts,rah,cH,cC, ETr,lambda,z,rho_a)

H_hot=Rn(cH(1),cH(2))-G(cH(1),cH(2));
dT_hot=H_hot*rah(cH(1),cH(2)) / (rho_a(cH(1),cH(2))*1004);  %air density,specific energy = f(T)!!!

H_cold=Rn(cC(1),cC(2))-G(cC(1),cC(2))-1.05*ETr*lambda(cC(1),cC(2))*1000/3600*0.001;
dT_cold=H_cold*rah(cC(1),cC(2)) / (rho_a(cH(1),cH(2))*1004);  %air density,specific energy = f(T)!!!

b = (dT_hot - dT_cold) / (Ts(cH(1),cH(2))-Ts(cC(1),cC(2)));
a = dT_hot - b*Ts(cH(1),cH(2));

dT = a + b*Ts;
Ta=Ts-dT;
P=(101.3*((293-0.0065*z)/293)^5.26);
rho_a=P*1000./(287.058*Ta);

H = rho_a.*1004.*dT./rah; %air density,specific energy = f(T)!!!
end



