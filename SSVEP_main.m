% LSLのストリーム名
% PetalStreamのNameを設定する
streamName = 'PetalStream2';


% FFT解析パラメータ
T = 6;          % 時間窓長(s)
intarval = 0.2;	% FFT解析間隔(s)
Fs = 256;       % Muse2のサンプリングレート(Hz) 256から変更しない
measurementTime = 60;

data_use_count = 5;
use_max_val = 20;

% 脳波データ格納用変数
lsl_eeg = [];   % raw EEGデータ
lsl_time = [];  % タイムスタンプ

specs = {};
freqs = {};

% ビープ音の設定
samplerate=44100;
Tmax=0.15;
freq=440;
t=0:1/samplerate:Tmax;
sampledata=sin(2*pi*freq*t);


% LSL通信のレシーバーを作成
inlet = create_lsl_inlet(streamName);


% LSL通信開始
inlet.open_stream();

tic;
timestep = T;

data = zeros(2,1000);

while true

    % 一定間隔ごとにEEGデータを取得し解析を行う
    timeStamp = toc;
    if timeStamp > timestep

        % ==== Muse2からEEGデータ取得 ==== %
        % LSLバッファからデータ取得
        [samples,~] = inlet.pull_chunk();

        % データに付け足す
        lsl_eeg = horzcat(lsl_eeg, samples);
        lsl_time = (0:length(lsl_eeg)-1)/Fs;
        
        % 受信したデータから直近の時間窓長分のデータを抽出
        [raw_time, raw_eeg] = extract_lsl_data(lsl_time, lsl_eeg, T*Fs);
        
        
        % ==== バンドパワー解析 ==== %
        % デトレンド
        detrended_eeg = detrend(mean(raw_eeg([1 4], :)), 2);
        
        % ローパス
        filtered_eeg = lowpass(detrended_eeg, 30, Fs);
        
        % ハミング窓
        hw = hamming(length(filtered_eeg));
        filtered_eeg = filtered_eeg .* hw;
 
        % ピリオドグラム パワースペクトル密度解析
        N = length(filtered_eeg);
        xdft = fft(filtered_eeg);
        xdft = xdft(1:N/2+1);
        psdx = (1/(Fs*N)) * abs(xdft).^2;
        psdx(2:end-1) = 2*psdx(2:end-1);
        freq = 0:Fs/N:Fs/2;
        acf = 1/(sum(hw)/N);
        psdx = psdx .* acf;
        pow_fft = pow2db(psdx);
        
        lower = 10;
        upper = 12;
        eps = 0.1;

        % 10Hzと12Hzのバンドパワー計算し比較
        power_upper = bandpower(psdx, freq, [lower-eps lower+eps], 'psd'); % 10Hz付近のパワー
        power_lower = bandpower(psdx, freq, [upper-eps upper+eps], 'psd'); % 12Hz付近のパワー
        
        data = horzcat(data, [power_lower; power_upper]);

        specs{length(specs)+1} = psdx;
        freqs{length(freqs)+1} = freq;

        uppers = zeros(1, 0);
        lowers = zeros(1, 0);

%         for d = [power_lower, power_upper]
%             for v = d
%                 if 
%             end
%         end
        
        ylim([0, use_max_val]);
        x = 1:size(data, 2);
        hold on
        plot(x, data(1, :), 'r');
        plot(x, data(2, :), 'b');
        hold off;

        drawnow;

        % パワーが大きい方を表示し、ビープ音を鳴らす
        % 10hz:短い 12hz:長い
        if power_10 > power_12
%             disp('5Hz');
            fprintf('%dHz %f.2 %f.2\n', lower ,power_10, power_12);
            sound(sampledata,samplerate);

        else
%             disp('12z');
            fprintf('%dHz %f.2 %f.2\n', upper, power_10, power_12);
            sound(repmat(sampledata, 2),samplerate);
        end
        
        
        % 次の解析タイミングを更新
        timestep = timestep + intarval;
        
        if timeStamp > measurementTime 
%             break;
        end
    end
    
end

