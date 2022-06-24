classdef EEGRecorder < handle
    %ANALYZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Running
        FftTimeWindow = 6
        FftInterval = 0.4
        MuseSamplingRate = 256
        lsl_eeg = []
        lsl_time = []
        Inlet
        Judges = []
    end
    
    methods
        function obj = EEGRecorder(streamName)
            %ANALYZER Construct an instance of this class
            %   Detailed explanation goes here
            obj.Inlet = create_lsl_inlet(streamName);
            obj.Running = false;
        end


        function clear(obj)
            obj.Judges = [];
            obj.lsl_eeg = [];
            obj.lsl_time = [];
        end

        function [cnt_l, cnt_u] = judge_cnt(obj, duration)
            run(duration);
            cnt_l = 0;
            cnt_u = 0;
            
            for i = 1:1:length(obj.Judges)
                if obj.Judges(i)
                    cnt_u = cnt_u + 1;
                else
                    cnt_l = cnt_l + 1;
                end
                obj.clear();
            end
            
        end

        function [pow_l, pow_u] = judge(obj, duration)
            obj.clear();
            obj.run(duration, false);
            [pow_l, pow_u] = obj.fft();
        end

        function run(obj, duration, fft=true)
            tic;
            timeStep = obj.FftTimeWindow;
            while true
                timeStamp = toc;
                if timeStamp > obj.FftInterval
                    obj.recordData();
                    if fft
                        obj.fft();
                    end
                    timeStep = timeStep + obj.FftInterval;
                end
                if timeStamp > duration
                    break
                end
                pause(0.01);
            end
        end

        function recordData(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here

            % ==== Muse2からEEGデータ取得 ==== %
            % LSLバッファからデータ取得
            [samples,~] = obj.Inlet.pull_chunk();
    
            Fs = obj.MuseSamplingRate;

            % データに付け足す
            obj.lsl_eeg = [obj.lsl_eeg samples];
            obj.lsl_time = (0:length(obj.lsl_eeg)-1)/Fs;
        end

        function [power_lower, power_upper] = fft(obj)
            % 受信したデータから直近の時間窓長分のデータを抽出
            Fs = obj.MuseSamplingRate;
            T = obj.FftTimeWindow;

            [~, raw_eeg] = extract_lsl_data(obj.lsl_time, obj.lsl_eeg, T*Fs);
            
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
%             pow_fft = pow2db(psdx);
            
            lower = 10;
            upper = 12;
            eps = 0.1;
    
            % 10Hzと12Hzのバンドパワー計算し比較
            power_upper = bandpower(psdx, freq, [lower-eps lower+eps], 'psd'); % 10Hz付近のパワー
            power_lower = bandpower(psdx, freq, [upper-eps upper+eps], 'psd'); % 12Hz付近のパワー

            obj.Judges = [obj.Judges power_lower < power_upper];
        end
    end
end

