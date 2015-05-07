function [rah] = stability_correction(Ts,H,ux,u200,Zom,rho_a)

L = (1004*rho_a.*(ux.^3).*Ts) ./ (0.41*9.807*H);

%Initialize stability values
Psi_m200m=zeros(size(L));
Psi_h2m=zeros(size(L));
Psi_h01m=zeros(size(L));

%L above zero
Psi_m200m(L>0)=-5*(2./L(L>0));
Psi_h2m(L>0)=-5*(2./L(L>0));
Psi_h01m(L>0)=-5*(0.1./L(L>0));

%L below zero
x_200m=ones(size(L));
x_2m=ones(size(L));
x_01m=ones(size(L));    
x_200m(L<0)=(1-16*200./L(L<0)).^0.25;
x_2m(L<0)=(1-16*2./L(L<0)).^0.25;
x_01m(L<0)=(1-16*0.1./L(L<0)).^0.25;           
Psi_m200m(L<0)=2*log(0.5*(1+x_200m(L<0)))+log(0.5*(1+x_200m(L<0).^2))-2*atan(x_200m(L<0))+0.5*pi;
Psi_h2m(L<0)=2*log(0.5*(1+x_2m(L<0).^2));
Psi_h01m(L<0)=2*log(0.5*(1+x_01m(L<0).^2));

%correction for rah
ux=u200*0.41./(log(200./Zom)-Psi_m200m);
rah=(log(2/0.1)-Psi_h2m+Psi_h01m)./(0.41*ux);




