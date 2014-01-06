function expandAxes(hndls)
% Copyright 2007 The MathWorks, Inc.
% Sets all axes in the handle list to expand in a new figure on buttondown. 
%
% SYNTAX:
% expandAxes
%    Sets the current axes to expand on buttondown.
% 
% expandAxes(hndls)
%    Sets all axes in the input list of handles to expand on buttondown.
% 
% NOTE: This function modifies the BUTTONDOWNFCN of axes in the input list,
%       and their children. However, it will not modify any object whose
%       buttondownfcn is nonempty. 
%
% USAGE:
% Allows you to click on any axes (or child thereof) in the list of input
% handles. LEFT-CLICKING will popup a new window in the position of the
% original, filled with the single axes and all its children. Clicking on
% that figure closes the popup window. (RIGHT-CLICKING restores
% non-expanding status to the axis and its children.)
%
%
% EXAMPLES:
%    figure;
%    a=zeros(1,9);
%    t = 0:pi/64:4*pi;
%    for ii = 1:9
%        a(ii) = subplot(3,3,ii);
%        plot(t,ii*sin(ii*t));
%        title(sprintf('ii = %d',ii),'color','r');
%    end
%    expandAxes(a);
%
%   %NOTE: This example requires the Image Processing Toolbox
%    figure
%    h(1)=axes('pos',[0.1 0.1 0.3 0.3]);
%    imshow('cameraman.tif');
%    h(2)=axes('pos',[0.5 0.1 0.3 0.3]);
%    imshow('peppers.png');
%    expandaxes(h)
%
% MOTIVATION:
% In real estate, there's a saying: "Location, location, location." In
% computer graphics, the saying is (or ought to be): "Real estate, real
% estate, real estate." This function allows you to show a lot more plots,
% graphics, etc. in a single figure without sacrificing the ability to see
% larger versions of same.

% The author is very grateful to John D'Errico for his constructive
% comments on this function prior to its posting.
%
% Written by Brett Shoelson, PhD
% brett.shoelson@mathworks.com
% 12/18/2007

% Opertate on current axes if no handle list is provided.
if nargin == 0
	hndls = gca;
end

for ii = 1:numel(hndls)
    % Ignore any handles that are not of type axes
    if strcmp(get(hndls(ii),'type'),'axes')
        % Create a structure of handles for each axes in the list
        clear hndlSet;
        % The axes itself:
        hndlSet.ax = hndls(ii);
        % The parent figure
        hndlSet.oldfig = get(hndls(ii),'parent');
        allchildren = allchild(hndls(ii));
        % All children WITH EMPTY BUTTONDOWNFCNs
        validChildren = allchildren(cellfun(@isempty,get(allchildren,'buttondownfcn')));
        hndlSet.objectsOfInt = [hndlSet.ax;validChildren];
        % Modify buttondownfcns of all ("valid") axes and children
        set(hndlSet.objectsOfInt,'buttondownfcn',{@expandIt,hndlSet});
    end
end

    function expandIt(varargin)
        hndlSet = varargin{3};
        selType = get(gcf,'SelectionType');
        switch selType
            % EXPAND
            case 'normal'
                new_fig = figure('numbertitle','off',...
                    'name','CLICK ON THE FIGURE TO CLOSE AND CONTINUE...',...
                    'units',get(hndlSet.oldfig,'units'),'position',get(hndlSet.oldfig,'position'),...
                    'color',get(hndlSet.oldfig,'color'),'toolbar','figure','tag','new_fig',...
                    'colormap',get(hndlSet.oldfig,'colormap'),'menubar','none',...
                    'toolbar',get(hndlSet.oldfig,'toolbar'));
                set(new_fig,'buttondownfcn','closereq');
                new_ax = copyobj(hndlSet.ax,new_fig);
                set(new_ax,'units','normalized','position',[0.1 0.1 0.8 0.8]);
                % Click anywhere in the new figure to close it
                set(findall(new_fig),'buttondownfcn','closereq');
            case 'alt'
                % RESET
                set(hndlSet.objectsOfInt,'buttondownfcn','');
        end
    end
end