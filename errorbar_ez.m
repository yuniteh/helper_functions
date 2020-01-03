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
        alpha(0.8)
%         plot(xright,yvals,'LineWidth',1,'Color',color)
        plot(xcap,[data data],'LineWidth',1,'Color','k')
%         plot(xcap,ycap,'LineWidth',1,'Color',color)
%         plot(xcap,ybot,'LineWidth',1,'Color',color)
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
end

end