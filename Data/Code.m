clear;close all force;clc;%Job at Exxon Mobil
files = dir('./Database 1');
files2 = dir('./Database 2');
wavelets = ["bior3.5","bior1.5","bior3.9","coif3","coif5","db2","db9","haar","sym3","sym5","sym7"];
N = 3;
f = waitbar(0,'Extracting Features','Name','Loading Data...',...
     'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
 setappdata(f,'canceling',0);
for w=1:length(wavelets)
    AAA = []
    ADDD = []
    Y = []
    for i=3:size(files)
        filename = files(i).name;
        filename = strcat('./Database 1/',filename);
        ff = load(filename);
        % Sampling frequency of 500 Hz. Duration 6 seconds. Number of samples
        % 3000
        fields = fieldnames(ff);
        sz = size(fields);
        for j=1:2:sz
            for k=1:30
                if getappdata(f,'canceling')
                    break
                end
                waitbar(k/30,f,sprintf('Percentage Done %0.1f%%',100*k/30)); 
                x = ff.(fields{j})(k,:);
                %x_noise = <NOISE CODE>
                % SECOND CASE: x_filtered = DENOISE, then change x in
                % wavedec to x_filtered
                [c_1,l_1] = wavedec(x,3,wavelets{w});
                A_1_1 = appcoef(c_1,l_1,wavelets{w},1);
                A_1_2 = appcoef(c_1,l_1,wavelets{w},2);
                A_1_3 = appcoef(c_1,l_1,wavelets{w},3);
                [D_1_1,D_1_2,D_1_3] = detcoef(c_1,l_1,[1 2 3]);
                
                x = ff.(fields{j+1})(k,:);
                %x_noise = <NOISE CODE>
                % SECOND CASE: x_filtered = DENOISE, then change x in
                % wavedec to x_filtered
                [c_2,l_2] = wavedec(x,3,wavelets{w});
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
            end
        end
    end
    
    for i=3:size(files2)
        filename = files2(i).name;
        filename = strcat('./Database 2/',filename);
        ff = load(filename);
        % Sampling frequency of 500 Hz. Duration 5 seconds. Number of samples
        % 2500
        fields = fieldnames(ff);
        sz = size(fields);
        for j=1:2:sz
            for k=1:100
                if getappdata(f,'canceling')
                    break
                end
                waitbar(k/100,f,sprintf('Percentage Done %0.1f%%',100*k/100)); 
                x = ff.(fields{j})(k,:);
                %x_noise = <NOISE CODE>
                % SECOND CASE: x_filtered = DENOISE, then change x in
                % wavedec to x_filtered
                [c_1,l_1] = wavedec(x,3,wavelets{w});
                A_1_1 = appcoef(c_1,l_1,wavelets{w},1);
                A_1_2 = appcoef(c_1,l_1,wavelets{w},2);
                A_1_3 = appcoef(c_1,l_1,wavelets{w},3);
                [D_1_1,D_1_2,D_1_3] = detcoef(c_1,l_1,[1 2 3]);
                
                x = ff.(fields{j+1})(k,:);
                %x_noise = <NOISE CODE>
                % SECOND CASE: x_filtered = DENOISE, then change x in
                % wavedec to x_filtered
                [c_2,l_2] = wavedec(x,3,wavelets{w});
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
            end
        end
    end
    csvwrite(strcat('./CSV2/',wavelets{w}, '_AAA.csv'),AAA); % CHANGE CSV NAME
    csvwrite(strcat('./CSV2/',wavelets{w}, '_ADDD.csv'),ADDD); % CHANGE CSV NAME
    csvwrite(strcat('./CSV2/',wavelets{w}, '_target.csv'),Y);% CHANGE CSV NAME
end
delete(f)