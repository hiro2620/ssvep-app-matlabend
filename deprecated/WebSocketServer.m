classdef WebSocketServer < BaseWebSocketServer
    %ECHOSERVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = WebSocketServer(varargin)
            %Constructor
            obj@BaseWebSocketServer(varargin{:});
        end
    end
    
    methods (Access = protected)
        function onOpen(obj,conn,message)
            fprintf('connected (%s:%s)\n',conn.Adress, conn.Port)
        end
        
        function onTextMessage(obj,conn,message)
            % This function sends an echo back to the client
            conn.send(message); % Echo
        end
        
        function onBinaryMessage(obj,conn,bytearray)
            % This function sends an echo back to the client
%             conn.send(bytearray); % Echo
            disp("received a binary message")
        end
        
        function onError(obj,conn,message)
            fprintf('%s\n',message)
        end
        
        function onClose(obj,conn,message)
            fprintf('connection closed (%s)\n',message)
        end
    end
end

