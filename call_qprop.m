function [perf]=call_qprop(velStr, rpmStr, voltStr, dBetaStr, thrustStr, torqueStr, ampsStr, peleStr, mode, motorNum)
%Note about qprop syntax:
%The input looks like
%qprop propfile motorfile vel rpm volt dBeta Thrust Torque Amps Pele 
      
 qpropinput={'qprop.exe' 'propfile' ['motorfiles/motorfile' num2str(motorNum)] velStr rpmStr ...
     voltStr dBetaStr thrustStr torqueStr ampsStr peleStr '["]' };  

 %BEGIN JAVA CODE       
 pb = java.lang.ProcessBuilder({''});
        % The command to execute, complete with arguments
        pb.command(qpropinput);
        myProcess = pb.start();
        
        % Reads what comes out of QProp (Even though code says "Input")
        reader = java.io.BufferedReader(java.io.InputStreamReader(...
            myProcess.getInputStream()));

        % Writes to the command line, basically
        writer = java.io.BufferedWriter(java.io.OutputStreamWriter(...
            myProcess.getOutputStream()));
    
        writer.newLine; % Execute!
        writer.close; % Don't need the writer anymore, has done its job
        
        line = reader.readLine; % Start reading output from QProp
        i = 0;
        a=0;
%output must be read differently depending on if the run is a single or multi-point run        
switch mode
    case 'multipoint'
%OUTPUT FROM MULTI-POINT RUNS
         while ~isequal(line, []) % Keep reading until next line is empty
             line = char(line);
             if isequal(line, ' ') || isequal(line, '\n') || isequal(line, '') || isequal(line(1), '#')
                 % Skip unimportant line, read next line and continue
                 line = reader.readLine;
                 continue
             end
             % Note we don't need to save any files, just read directly
             i = i + 1;
             line = line(1:length(line)); % remove newline character
             crayon = sscanf(line, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f');
             qpropoutputV(i,:) = crayon';
             line = reader.readLine; % read next line
         end
    case 'singlepoint'
%OUTPUT FROM SINGLE-POINT RUNS
        while ~isequal(line, []) % Keep reading until next line is empty
            line = char(line);
            a=a+1;
            if isequal(line, ' ') || isequal(line, '\n') || isequal(line, '') || not(isequal(a,18))
                % Skip unimportant line, read next line and continue
                line = reader.readLine;
                continue
            end
            % Note we don't need to save any files, just read directly
            i = i + 1;
            line = line(2:length(line)); % remove newline character
            if line(1:6)=='GVCALC'
                crayon=nan(1,24);
            else
                crayon = sscanf(line, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f');
            end
            qpropoutputV(i,:) = crayon';
            %line = reader.readLine; % read next line
        end   
end
%END JAVA CODE
    % Whichever way we got the output of QProp, get our individual outputs
    perf.velocity=qpropoutputV(:,1);
    perf.rpm=qpropoutputV(:,2);
    perf.dbeta=qpropoutputV(:,3);
    perf.thrust=qpropoutputV(:,4);
    perf.q=qpropoutputV(:,5);
    perf.pshaft=qpropoutputV(:,6);
    perf.volts=qpropoutputV(:,7);
    perf.amps=qpropoutputV(:,8);
    perf.effmotor=qpropoutputV(:,9);
    perf.effprop=qpropoutputV(:,10);
    perf.adv=qpropoutputV(:,11);
    perf.ct=qpropoutputV(:,12);
    perf.cp=qpropoutputV(:,13);
    perf.dv=qpropoutputV(:,14);
    perf.eff=qpropoutputV(:,15);
    perf.pelec=qpropoutputV(:,16);
    perf.pprop=qpropoutputV(:,17);
    perf.clavg=qpropoutputV(:,18);
    perf.cdavg=qpropoutputV(:,19);
end