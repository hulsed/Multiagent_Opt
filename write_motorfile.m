function []=write_motorfile(motor)
%creating motor input file
        fid = -1;
        while fid < 3
            fid = fopen([pwd '/motorfile'], 'w');
        end
        format = '\n%s\n\n %d\n\n %f\n %f\n %f\n';
        fprintf(fid, format, 'derp', 1, motor.R0, motor.I0, motor.kv);
        fclose(fid);
end