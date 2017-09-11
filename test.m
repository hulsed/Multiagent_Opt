
 xcont=rand(1,3);
 foundmerit=rand(1,3);
% 
% %upper bounds
 UB(1)=1;
 UB(2)=10;
 UB(3)=100;
% %lower bounds
 LB(1)=0;
 LB(2)=1;
 LB(3)=50;
% %points stored already for each variable
 %oldptsx{1}=rand(1,100)*(UB(1)-LB(1))+LB(1);
 %oldptsx{2}=rand(1,100)*(UB(2)-LB(2))+LB(2);
 %oldptsx{3}=rand(1,100)*(UB(3)-LB(3))+LB(3);
% 
 %oldptsy{1}=rand(1,100);
 %oldptsy{2}=rand(1,100);
 %oldptsy{3}=rand(1,100);
% 
% %tolerance for each variable
 tol(1)=0.0001;
 tol(2)=0.001;
 tol(3)=0.001;
% %maximum number of zones for each variable
 maxzones(1)=20;
 maxzones(2)=20;
 maxzones(3)=20;
% %initial value
 Qinit=10;
 
 temps=[1, 1, 1]
 
 meritfxn=init_meritfxn(UB,LB,tol, Qinit);
 [oldptsx,oldptsy]=init_pts(UB,LB,maxzones, Qinit)
 
 for z=1:1000
 x_cont = choose_continuousparamvals(meritfxn, temps)
 
 yfound=x_cont.^2;
 xfound=x_cont;
 
 [meritfxn,oldptsx,oldptsy,learned,expImprovement]=update_continousmerit(oldptsx,oldptsy,xfound, yfound, UB,LB,tol,maxzones, Qinit);

 end
 