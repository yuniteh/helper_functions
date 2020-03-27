function errorbar_ez(type,x,data,se,len,color)

xvals = [x, x];
yvals = [data-se, data+se];

xcap = [x-len, x+len];
xleft = [x-len, x-len];
xright = [x+len, x+len];
ycap = [data+se data+se];
ybot = [data-se data-se];
switch type
    case 'box'
        plot([xleft xcap xright flip(xcap)],[yvals ycap flip(yvals) ybot],'LineWidth',1,'Color','k')
        fill([xleft xcap xright flip(xcap)],[yvals ycap flip(yvals) ybot],color)
%         alpha(0.8)
%         plot(xright,yvals,'LineWidth',1,'Color',color)
        plot(xcap,[data data],'LineWidth',1,'Color','k')
    case 'line'
        plot(xvals+.2,yvals,'LineWidth',1.5,'color','k')
        plot(x+.2,data,'.','MarkerSize',15,'color','k')
    case 'cap'
        plot(xvals,yvals,'LineWidth',1.5,'color','k')
        plot(x,data,'.','MarkerSize',15,'color','k')
        plot(xcap,ycap,'LineWidth',1.5,'color','k')
        plot(xcap,ybot,'LineWidth',1.5,'color','k')
    case 'line_simple'
        plot(xvals,yvals,'LineWidth',1,'color','k')
    case 'boxwhisk'
        quants = quantile(data,3);
        q1 = quants(1);
        med = quants(2);
        q3 = quants(3);
        top = max(data);
        bot = min(data);
        
        yvals = [q1, q3];
        ycap = [q3, q3];
        ybot = [q1, q1];
        plot(xvals,[bot q1],'LineWidth',1,'Color','k')
        plot(xvals,[top q3],'LineWidth',1,'Color','k')
        plot([xleft xcap xright flip(xcap)],[yvals ycap flip(yvals) ybot],'LineWidth',1,'Color','k')
        fill([xleft xcap xright flip(xcap)],[yvals ycap flip(yvals) ybot],color)
        alpha(0.8)
        plot(xcap,[med med],'LineWidth',1,'Color','k')
        plot(x,med,'o','MarkerSize',4,'color','k','MarkerFaceColor','k')    
    case 'bar'
        y = [0, data];
        ycap = [data, data];
        ybot = [0, 0];
        fill([xleft xcap xright flip(xcap)],[y ycap flip(y) ybot],color,'linestyle','none')
%         alpha(0.8)
        plot([xleft xcap xright flip(xcap)],[y ycap flip(y) ybot],'LineWidth',1,'Color','k')
        
        plot(xvals,yvals,'LineWidth',1,'color','k')
end

end