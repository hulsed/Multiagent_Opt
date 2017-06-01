function [meritfxn,oldptsx,oldptsobj,oldptscon,learned, objImprovement,conImprovement]=update_continousmerit(oldptsx,oldptsobj,oldptscon,xfound, objfound,confound, UB,LB,tol,maxzones, Meritinit)


for ag=1:numel(oldptsx)
   learned(ag)=0;
   objImprovementz(ag)=0;
   conImprovementz(ag)=0;
   conImprovement(ag)=0;
   objImprovement(ag)=0;
   
   
   ptsx=oldptsx{ag};
   ptsobj=oldptsobj{ag};
   ptscon=oldptscon{ag};
   
   zones(ag)=max(4,min(maxzones(ag),round(numel(ptsx)/10)));
   zone{ag}=linspace(LB(ag),UB(ag),zones(ag));
   
   for z=1:zones(ag)-1
       zonepts=(zone{ag}(z)<ptsx & ptsx<=zone{ag}(z+1));
       xpts=ptsx.*zonepts;
       objpts=ptsobj.*zonepts;
       conpts=ptscon.*zonepts;
       
       if any(xpts~=0)
        zptsx=xpts(xpts~=0);
        zptsobj=objpts(xpts~=0);
        zptscon=conpts(xpts~=0);
        
        minconzone=min(zptscon);
            mostfeaspts=minconzone==zptscon;
            
            mostfeasx=zptsx(mostfeaspts);
            mostfeasobj=zptsobj(mostfeaspts);
            %best point is the most feasible
            zonerepcon(z)=minconzone;
            %that has the best objective value
            [zonerepobj(z), loc]=min(mostfeasobj);
            %
            zonerepx(z)=mostfeasx(loc);
           
       else
       zonerepobj(z)=Meritinit;
        zonerepcon(z)=Meritinit;
       zonerepx(z)=(zone{ag}(z+1)-zone{ag}(z))/2+zone{ag}(z);
            
       end
       % learned if better than other points in the zone
       if (zone{ag}(z)<xfound(ag) && xfound(ag)<=zone{ag}(z+1))
            
            if confound(ag)<zonerepcon(z)
                
                   conImprovementz(ag)=zonerepcon(z)-confound(ag);
                   
                   if objfound(ag)<zonerepobj(z)
                        objImprovementz(ag)=zonerepobj(z)-objfound(ag);
                   else
                        objImprovementz(ag)=0;
                   end
                   
                   learned(ag)=1;

                   zonerepx(z)=xfound(ag);
                   zonerepobj(z)=objfound(ag);
                    zonerepcon(z)=confound(ag);
            
            elseif confound(ag)==zonerepcon(z)
               if objfound(ag)<zonerepobj(z)
                   
                   conImprovementz(ag)=0;
                   objImprovementz(ag)=zonerepobj(z)-objfound(ag);
                   
                   
                   learned(ag)=1;

                   zonerepx(z)=xfound(ag);
                   zonerepobj(z)=objfound(ag);
                    zonerepcon(z)=confound(ag);
                    
               else
               conImprovementz(ag)=0;
                objImprovementz(ag)=0;
                                      
               end
               
            else
                
                conImprovementz(ag)=0;
                objImprovementz(ag)=0;
                
            end

       
       else
           conImprovementz(ag)=0;
           objImprovementz(ag)=0;
           
       end
       
       conImprovement(ag)=conImprovement(ag)+conImprovementz(ag);
       objImprovement(ag)=objImprovement(ag)+objImprovementz(ag);
       

   end

   xcell{ag}=[LB(ag),zonerepx,UB(ag)+0.0001];
   ycell{ag}=[mean(zonerepobj),zonerepobj,mean(zonerepobj)];
   zcell{ag}=[mean(zonerepcon),zonerepcon,mean(zonerepcon)];

   
   %create interpolation of merit of each
   xx{ag}=xcell{ag}(1):tol(ag):xcell{ag}(end);
   %could use interp1 for linear interpolation...
   %or spline for spline
   
   %pchip seems to make sense
   yy{ag}=pchip(xcell{ag},ycell{ag},xx{ag});
   zz{ag}=pchip(xcell{ag},zcell{ag},xx{ag});

   %figure(ag)
   %plot(xx{ag},yy{ag},ptsx,ptsy,'o');
   
    
    %add found point to cell
    oldptsx{ag}=[oldptsx{ag},xfound(ag)];
    oldptsobj{ag}=[oldptsobj{ag},objfound(ag)];
    oldptscon{ag}=[oldptscon{ag},confound(ag)];
    
    %create merit function (for use in action selection)
    meritfxn{ag}=[xx{ag};yy{ag}; zz{ag}];

    
    clear zonerepx zonerepobj zonerepcon
    
end



end