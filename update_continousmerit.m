function [meritfxn,oldptsx,oldptsy,learned, expImprovement]=update_continousmerit(oldptsx,oldptsy,xfound, yfound, UB,LB,tol,maxzones, Qinit)


for ag=1:numel(oldptsx)
   learned(ag)=0;
   expImprovement(ag)=0;
   
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

   x{ag}=[LB(ag),zonerepx,UB(ag)+0.0001];
   y{ag}=[Qinit,zonerepy,Qinit];

   
   %create interpolation of merit of each
   xx{ag}=x{ag}(1):tol(ag):x{ag}(end);
   %could use interp1 for linear interpolation...
   %or spline for spline
   
   %pchip seems to make sense
   try
   yy{ag}=pchip(x{ag},y{ag},xx{ag});
   catch error
       
   end
   %figure(ag)
   %plot(xx{ag},yy{ag},ptsx,ptsy,'o');
   
    
    %add found point to cell
    oldptsx{ag}=[oldptsx{ag},xfound(ag)];
    oldptsy{ag}=[oldptsy{ag},yfound(ag)];
    
    %create merit function (for use in action selection)
    meritfxn{ag}=[xx{ag};yy{ag}];
end



end