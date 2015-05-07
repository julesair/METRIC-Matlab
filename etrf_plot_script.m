clear tempNDVI tempETrf ETrfvec NDVIvec
tempNDVI=zeros(1,size(points,2)-1);
tempETrf=zeros(1,size(points,2)-1);

blur=3;
for i=2:size(points,2)
    for j=1:blur
        for k=1:blur
            tempNDVI(i-1)=tempNDVI(i-1)+NDVI(round(points(2,i))+j-blur/2+0.5,round(points(1,i))+k-blur/2+0.5);
            tempETrf(i-1)=tempETrf(i-1)+ETrf(round(points(2,i))+j-blur/2+0.5,round(points(1,i))+k-blur/2+0.5);
        end
    end
    NDVIvec(i-1)=tempNDVI(i-1)/(j*k);
    ETrfvec(i-1)=tempETrf(i-1)/(j*k);
end


figure;scatter(NDVIvec,ETrfvec,'.');
% xlabel('Top of atmosphere NDVI [-]');
% ylabel('ETrf [-]');
% title('NDVI-ETrf relationship. 12. May 2013'); 