addpath("./liblsl-Matlab");
addpath("./matlab-websocket");
addpath("./matlab-websocket/src");

% SERVER_URL = 'ws://localhost:8080';
PORT = 8081;
% 

% analyzer = Analyzer();
% rec = EEGRecorder('petalStream2');
rec = 0;

% client = WebClient(a, SERVER_URL);
% 
% client.send( ...
%     jsonencode(struct('action',0, 'payload',0)) ...
%     );

try
    server = WebServer(rec, PORT);
catch ME
    server.close();
    rethrow(ME);
end



% tic;
% lastTime = 0;
% while true
%     c = toc;
%     disp(c-lastTime)
%     lastTime = c;
% end