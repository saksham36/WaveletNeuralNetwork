clear;close all force;clc;
files = dir('./Database 1');
files2 = dir('./Database 2');
%wavelets = ["bior3.5","bior1.5","bior3.9","coif3","coif5","db2","db9","haar","sym3","sym5","sym7"];
wavelets = ["coif5"];
modes = ["clean","noise","filtered"];
p0 = 2 * eye(13);
lambda = 0.99;
%wavelets = ["coif5"];
N = 3;
f = waitbar(0,'Extracting Features','Name','Loading Data...',...
     'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
 setappdata(f,'canceling',0);
for w=1:length(wavelets)
    AAA = [];
    ADDD = [];
    Y = [];
    for i=3:size(files2)
        filename = files2(i).name;
        name = files2(i).name;
        filename = strcat('./Database 2/',filename);
        ff = load(filename);
        % Sampling frequency of 500 Hz. Duration 5 seconds. Number of samples
        % 2500
        fields = fieldnames(ff);
        sz = size(fields);
        for m = 1:length(modes)
            AAA = [];
            ADDD = [];
            Y = [];
            for j=1:2:sz
                for k=1:100
                    if getappdata(f,'canceling')
                        break
                    end
                    waitbar(k/100,f,sprintf('Percentage Done %0.1f%%',100*k/100));

                    x_1 = ff.(fields{j})(k,:);
                    x_2 = ff.(fields{j+1})(k,:);
                    x_1_noise = awgn(x_1,25);
                    x_2_noise = awgn(x_2,25);
                    for interval=1:25
                        if(m==1)
                            x_11 = x_1((interval-1)*100+1: interval*100);
                            [c_1,l_1] = wavedec(x_11,3,wavelets{w});
                            x_22 = x_2((interval-1)*100+1: interval*100);
                            [c_2,l_2] = wavedec(x_22,3,wavelets{w});
                        elseif(m==2)
                            x_11 = x_1_noise((interval-1)*100+1: interval*100);
                            [c_1,l_1] = wavedec(x_11,3,wavelets{w});
                            x_22 = x_2_noise((interval-1)*100+1: interval*100); 
                            [c_2,l_2] = wavedec(x_22,3,wavelets{w});
                        elseif(m==3)
                            x_11 = x_1_noise((interval-1)*100+1: interval*100);
                            rls = dsp.RLSFilter(13,'ForgettingFactor',lambda,...
                           'InitialInverseCovariance',p0);
                            x1_filtered=rls(x_11,x_1((interval-1)*100+1: interval*100));
                            [c_1,l_1] = wavedec(x1_filtered,3,wavelets{w});
                            
                            x_22 = x_2_noise((interval-1)*100+1: interval*100); 
                            rls = dsp.RLSFilter(13,'ForgettingFactor',lambda,...
                            'InitialInverseCovariance',p0);
                            x2_filtered=rls(x_22,x_2((interval-1)*100+1: interval*100));
                            [c_2,l_2] = wavedec(x2_filtered,3,wavelets{w});
                        end
                        A_1_1 = appcoef(c_1,l_1,wavelets{w},1);
                        A_1_2 = appcoef(c_1,l_1,wavelets{w},2);
                        A_1_3 = appcoef(c_1,l_1,wavelets{w},3);
                        [D_1_1,D_1_2,D_1_3] = detcoef(c_1,l_1,[1 2 3]);
                    
                        A_2_1 = appcoef(c_2,l_2,wavelets{w},1);
                        A_2_2 = appcoef(c_2,l_2,wavelets{w},2);
                        A_2_3 = appcoef(c_2,l_2,wavelets{w},3);
                        [D_2_1,D_2_2,D_2_3] = detcoef(c_2,l_2,[1 2 3]);

                        temp_AAA = [max(abs(A_1_3)),max(abs(A_1_2)),max(abs(A_1_1)), max(abs(A_2_3)),max(abs(A_2_2)),max(abs(A_2_1))];
                        temp_ADDD = [max(abs(A_1_3)),max(abs(D_1_3)),max(abs(D_1_2)),max(abs(D_1_1)),max(abs(A_2_3)),max(abs(D_2_3)),max(abs(D_2_2)),max(abs(D_2_1))];
                        output_size = round(sz/2);
                        temp_Y = zeros(output_size(1),1);
                        temp_Y(round(j/2)) = 1;
                        AAA = [AAA,temp_AAA'];
                        ADDD = [ADDD,temp_ADDD'];
                        Y = [Y,temp_Y];
                        
                    end % Intervals
                end % Different attempts
            end % Different Class
            size(AAA)
            csvwrite(strcat('./NEW/CSV_',name(1:end-4),"_",modes{m},"/",wavelets{w}, '_AAA.csv'),AAA); % CHANGE CSV NAME
            csvwrite(strcat('./NEW/CSV_',name(1:end-4),"_",modes{m},"/",wavelets{w}, '_ADDD.csv'),ADDD); % CHANGE CSV NAME
            csvwrite(strcat('./NEW/CSV_',name(1:end-4),"_",modes{m},"/",wavelets{w}, '_target.csv'),Y);% CHANGE CSV NAME
        end % Different mode
    end % Different Subject
end % Different Wavelets
delete(f)