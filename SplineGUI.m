classdef SplineGUI < handle
    % GUI to test spline function
    properties
        xdata
        ydata
        cs
        h_fig
        h_ax
        h_bt
        h_plt_line
        h_plt_ctrlpt
        h_plt_hpt % highlighted point
        ind_hpt   % highelighted point index
        timerS
    end
    
    methods
        function self= SplineGUI(x,y)
            self.xdata= x;
            self.ydata= y;
            self.cs = spline(x, y);
            %% setup GUI
            self.setupUI();
           
        end
        function setupUI(self)
            self.h_fig= figure();
            self.h_ax= axes();
            
            self.h_bt= uicontrol('parent',self.h_fig,'units','normalized',...
                'position',[0.4 0.05 0.3 0.1],'style','pushbutton',...
                'string','Get Points', 'callback',@self.getPoints);
            %% plot now
            self.plotnow();
            %% setup callback
            set(self.h_fig,'WindowButtonMotionFcn',@self.mouseMove);
            set(self.h_fig,'WindowButtonDownFcn',@self.mouseDown);
            
        end
        
        %% callback getPoints
        function getPoints(self,src,ev)
        
        end
        
        function plotnow(self)
            if ishandle(self.h_plt_ctrlpt), delete(self.h_plt_ctrlpt); end
            if ishandle(self.h_plt_line), delete(self.h_plt_line); end
            xx = linspace(self.xdata(1),self.xdata(end),101);
            self.h_plt_ctrlpt= plot(self.h_ax, self.xdata,self.ydata,'bo');
            hold all;
            self.h_plt_line= plot(self.h_ax,xx,ppval(self.cs,xx),'r-');
            hold all;
        end
        function mouseMove(self,hobj,evt)
            % delete highlighted line first
            if ishandle(self.h_plt_hpt), delete(self.h_plt_hpt); end
            % update current point
            C= get(self.h_ax,'CurrentPoint');
            title(self.h_ax,sprintf('(X,Y)=(%8.4f,%8.4f)',...
                C(1,1),C(1,2)));
            % detect whether to snap a point
            xlim= get(self.h_ax,'xlim');
            ylim= get(self.h_ax,'ylim');
            tol= norm([(xlim(end)-xlim(1)) (ylim(end)-ylim(1))])/20;
            for i=1:length(self.xdata)
                xnow= self.xdata(i);
                ynow= self.ydata(i);
                dist= norm(C(1,1:2)-[xnow,ynow]);
                if dist < tol
                    self.h_plt_hpt= plot(self.h_ax,xnow,ynow,'ro',...
                        'markersize',12);
                    self.ind_hpt= i;
                    break;
                end 
            end
        end
        function mouseDown(self,hobj,evt)
            if ishandle(self.h_plt_hpt)
                set(self.h_fig,'WindowButtonMotionFcn',@self.mouseDrag);
                set(self.h_fig,'WindowButtonUpFcn',@self.mouseUp);                
            end
        end
        function mouseDrag(self,hobj,evt)
            % update current point title
            C= get(self.h_ax,'CurrentPoint');
            title(self.h_ax,sprintf('(X,Y)=(%8.4f,%8.4f)',...
                C(1,1),C(1,2)));
            % updata highlighted point plot
            set(self.h_plt_hpt,'xdata',C(1,1));
            set(self.h_plt_hpt,'ydata',C(1,2));
            % update control points data and plot
            self.xdata(self.ind_hpt)= C(1,1);
            self.ydata(self.ind_hpt)= C(1,2);
            set(self.h_plt_ctrlpt,'xdata', self.xdata);
            set(self.h_plt_ctrlpt,'ydata', self.ydata);            
        end
        function mouseUp(self,hobj,evt)
            % reset spline model
            self.cs = spline(self.xdata, self.ydata);
            % plot now
            self.plotnow;
            % reset WindowButton functions
            set(self.h_fig,'WindowButtonMotionFcn',@self.mouseMove);
            set(self.h_fig,'WindowButtonUpFcn',[]);            
        end
            
    end
    
end

