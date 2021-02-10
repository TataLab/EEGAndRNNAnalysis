% This code finds both single-sided and double-sided spectrum of a signal x(t)
%
% INPUTS:   -fs: sampling rate of the signal x
%           - x: the signal in time domain
%           - flag=1 if you want to plot the outputs and =0 if you don't;
%           - optional: hndl = handle to the figure
%
% OUTPUT:   - f: double-sided frequency
%           - y: frequency representation of the signal
%           - s_amp nd d_amp: amplitude of
%           the fft for both single-sided and double-sided representations,
%           in turn.
%           
% Example:
% t = 0:1e-4:0.1;x = sin(2*pi*100*t);
% hndl = figure;
% [f,y] = FrequencyDomain(1e4,x,1,'hndl',hndl);
%
%
% @ Jan 2020-SH

function [f,y,s_amp,d_amp] = FrequencyDomain(fs,x,flag,varargin)
if flag == 1
    hndl = figure;
else
    hndl = [];
end
assignopts(who, varargin);

if size(x,2) == 1
    x = x';
end

Ts = 1/fs;
L = length(x);
t =(0:L-1)*Ts;
N = 2^nextpow2(L);

y = fftshift(fft(x,N));  % shifted the second half of the frequency domain to the negative frequencies
% It's common not to plot the negative frequencies, in that case the plot
% can be over the f = (0:N/2).*fs./N;
f = (-N/2:N/2-1).*fs./N;

% Note that making a double sided fft will divide the power between the positive and negative sides, 
% so if you are only going to look at one side of the FFT, you can multiply
% the amplitude by 2 which is equivalent to folding the positive and
% negative parts together. Note that DC component remains the same, meaning that this procedure doesn't 
% change the amplitude of the fft on f=0 Hz.

d_amp = abs(y/N); 
s_amp = [d_amp(N/2), 2*d_amp(N/2+1:N)];

if flag == 1
    figure(hndl);
    subplot(3,1,1);plot(t,x); xlabel('time(sec)');ylabel('x(t)');title('signal');
    ylim([min(x)-.1*abs(min(x)), 1.1*max(x)])
    subplot(3,1,2);plot(f(N/2:N),s_amp); xlim([f(1),f(end)]);ylim([0, 1.1*max(s_amp)])
    xlabel('freq(Hz)');ylabel('|y| = |fft(x)|');title('single-sided FFT')
    subplot(3,1,3);plot(f,d_amp); ylim([0, 1.1*max(s_amp)])
    xlabel('freq(Hz)');ylabel('|y| = |fft(x)|');title('double-sided FFT')
end
return