function []=write_propfile(prop, foil)
%creating propeller input file
       %generating propeller geometry
        sects=20;
        radius=prop.diameter/2;
        root=0.02;
        radiusvect=linspace(root,radius,sects);
        anglevect=prop.angleRoot+radiusvect*(prop.angleTip-prop.angleRoot)/radius;
        chordvect=prop.chordRoot+radiusvect*(prop.chordTip-prop.chordRoot)/radius;
       %appending airfoil data
        fid2 = -1;
        while fid2 < 3
            fid2 = fopen([pwd '/propfile'], 'w');
        end
        format2='%s\n%s\n\n%d\n\n%f %f\n%f %f\n\n%f %f %f\n%f %f\n\n%f %f %f\n%f %f %f\n\n\n';
        fprintf(fid2, format2,'1,', '',2,foil.Cl0, foil.Cla, foil.Clmin, foil.Clmax, foil.Cd0, foil.Cd2, foil.Clcd0, foil.Reref, foil.Reexp, 1, 1,1,0,0,0);
       %appending prop geometry

        format3='%f %f %f\n';
        printdata=[radiusvect',chordvect', anglevect'];
        fprintf(fid2, format3, printdata(:,:)');
        fclose(fid2);
end