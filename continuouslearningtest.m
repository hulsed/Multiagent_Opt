%function contMerit=update_continousmerit(contMerit, foundMerit, xcont)

xcont=[11.7,37,1.2];
foundmerit=[20,100,-10];

oldptsx{1}=[1,5,10,11,15,20];
oldptsx{2}=[30,35,70,110,150,200];
oldptsx{3}=[0,.05,.5,1.1,1.5,2.0];

oldptsy{1}=[10,500,100,110,150,200];
oldptsy{2}=[300,50,10,10,15,20];
oldptsy{3}=[1,-11,-50,-35,-20,-15];

tol(1)=0.1;
tol(2)=1
tol(3)=0.001;

for ag=1:3
   ptsx=oldptsx{ag}
   ptsy=oldptsy{ag}
   xx=ptsx(1):tol(ag):ptsx(end)
   %could use interp1 for linear interpolation...
   %or spline for spline
   %pchip seems to make sense
   yy=pchip(ptsx,ptsy,xx)
   
   xnew=xcont(ag)
   ynew=foundmerit(ag)
   
   figure(ag)
   plot(xx,yy,ptsx,ptsy,'o',xnew,ynew,'*');
   
  
   %if the new point is better than its closest neighbor, replace that
   %neighbor.
   
   %if not, don't add the point (even if it's better than the father
   %neighbor)
   
    
end



%end