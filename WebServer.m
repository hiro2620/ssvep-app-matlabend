classdef WebServer < BaseWebSocketServer
    %ECHOSERVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Recorder
    end
    
    methods
        function obj = WebServer(recorder, varargin)
            %Constructor
            obj@BaseWebSocketServer(varargin{:});
            obj.Recorder = recorder;
        end
    end
    
    methods (Access = protected)
        function onOpen(obj, conn, message) 
            fprintf('%s\n',message)
        end
                
        function onBinaryMessage(obj,conn,bytearray)
            % This function sends an echo back to the client
%             conn.send(bytearray); % Echo
            disp("received binary");
        end
        
        function onError(obj,conn,message)
            fprintf('%s\n',message)
        end
        
        function onClose(obj,conn,message)
            fprintf('%s\n',message)
        end

        function onTextMessage(obj,conn,message)
            % This function sends an echo back to the client
%             disp(message);
%             conn.send(message); % Echo
            data = jsondecode(message);
            disp(data);

            if data.action == 1
%                 cl, cu = obj.Recorder.judge_cnt(6);
                cl = 4;
                cu = 3;
                pause(6);
%                 [cl, cu] = obj.Recorder.judge(6);
                fprintf('%f %f\n',cu, cl);
                conn.send(jsonencode(struct('action',1, 'payload',[cl cu])));
            end
        end

    end
end

