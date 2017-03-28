function [meritfxn,oldptsx,oldptsy,learned]=update_continousmerit(oldptsx,oldptsy,xfound, yfound, UB,LB,tol,maxzones, Qinit)

% xfound=[0.4,9,75];
% yfound=[0.99,0.99,0.99];
% 
% xcont=rand(1,3);
% foundmerit=rand(1,3);
% 
% %upper bounds
% UB(1)=1;
% UB(2)=10;
% UB(3)=100;
% %lower bounds
% LB(1)=0;
% LB(2)=1;
% LB(3)=50;
% %points stored already for each variable
% oldptsx{1}=rand(1,100)*(UB(1)-LB(1))+LB(1);
% oldptsx{2}=rand(1,100)*(UB(2)-LB(2))+LB(2);
% oldptsx{3}=rand(1,100)*(UB(3)-LB(3))+LB(3);
% 
% oldptsy{1}=rand(1,100);
% oldptsy{2}=rand(1,100);
% oldptsy{3}=rand(1,100);
% 
% %tolerance for each variable
% tol(1)=0.0001;
% tol(2)=0.001;
% tol(3)=0.001;
% %maximum number of zones for each variable
% maxzones(1)=20;
% maxzones(2)=20;
% maxzones(3)=20;
% %initial value
% Qinit=0;



for ag=1:3
   learned(ag)=0;
   
   ptsx=oldptsx{ag};
   ptsy=oldptsy{ag};
   
   zones(ag)=max(4,min(maxzones(ag),round(numel(ptsx)/10)));
   zone{ag}=linspace(LB(ag),UB(ag),zones(ag));
   
   for z=1:zones(ag)-1
       zonepts=(zone{ag}(z)<ptsx & ptsx<=zone{ag}(z+1));
       xpts=ptsx.*zonepts;
       ypts=ptsy.*zonepts;
       
       if any(xpts~=0)
        zptsx=xpts(xpts~=0);
        zptsy=ypts(xpts~=0);
        
       [zonerepy(z),loc]=min(zptsy);
       zonerepx(z)=zptsx(loc);
           
       else
       zonerepy(z)=Qinit;
       zonerepx(z)=(zone{ag}(z+1)-zone{ag}(z))/2+zone{ag}(z);
            
       end
       % learned if better than other points in the zone
       if (zone{ag}(z)<xfound(ag) & xfound(ag)<=zone{ag}(z+1))
           if yfound(ag)<zonerepy(z)
               expImprovement(ag)=zonerepy(z)-yfound(ag);
               learned(ag)=1;
               
               zonerepx(z)=xfound(ag);
               zonerepy(z)=yfound(ag);
               
           end
           
       end
       
   end
   
   x{ag}=[LB(ag),zonerepx,UB(ag)];
   y{ag}=[Qinit,zonerepy,Qinit];
   
   %create interpolation of merit of each
   xx{ag}=x{ag}(1):tol(ag):x{ag}(end);
   %could use interp1 for linear interpolation...
   %or spline for spline
   %pchip seems to make sense
   yy{ag}=pchip(x{ag},y{ag},xx{ag});
   
   %figure(ag)
   %plot(xx{ag},yy{ag},ptsx,ptsy,'o');
   
    
    %add found point to cell
    oldptsx{ag}=[oldptsx{ag},xfound(ag)];
    oldptsy{ag}=[oldptsy{ag},yfound(ag)];
    
    %create merit function (for use in action selection)
    meritfxn{ag}=[xx{ag};yy{ag}]
end



end