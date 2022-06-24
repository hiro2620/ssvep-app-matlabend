classdef WebClient < BaseWebSocketClient
    %CLIENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Recorder;
    end
    
    methods
        function obj = WebClient(recorder, varargin)
            %Constructor
            obj@BaseWebSocketClient(varargin{:});
            obj.Recorder = recorder;
        end
    end
    
    methods (Access = protected)
        function onOpen(obj,message)
            % This function simply displays the message received
            fprintf('connection opened: %s\n',message);
        end
        
        
        function onBinaryMessage(obj,bytearray)
            % This function simply displays the message received
            fprintf('Binary message received:\n');
            fprintf('Array length: %d\n',length(bytearray));
        end
        
        function onError(obj,message)
            % This function simply displays the message received
            fprintf('Error: %s\n',message);
        end
        
        function onClose(obj,message)
            % This function simply displays the message received
            fprintf('connection closed: %s\n',message);
        end

        function onTextMessage(obj,message)
            % This function simply displays the message received
            data = jsondecode(message);
            fprintf('Message received:\n%s\n',data);
        end
    end
end

