clear all; close all
fn = 'resampling_vs_wfft';
h = openfig([fn '.fig']);
set(h, 'visible', 'on');
% get children
ch = get(h, 'children');
% first one is legend, second is figure

xl = [1720 8000];
yl = [-0.015 0.015];
set(ch(2), 'xlim', xl);
set(ch(2), 'ylim', yl);

periodsxlim = xl./(96e3/50);

Xaxis2 = axes();
set( Xaxis2, 'position'     , [ 0.13, 0.25, 0.775, 0.815 ],
             'units'        , 'normalized'          ,
             'box'          , 'off'                 ,
             'fontsize'     , 10                    ,
             'linewidth'    , 1                     ,
             'xaxislocation', 'bottom'                 ,
             'xcolor'       , 'b'                   ,
             'xlim'         , periodsxlim,
             % 'ylim'         , [ -100, 0  ]          ,
             'yaxislocation', 'right'               ,
             'xlabel'       , 'Periods'     ,
             'ylabel'       , ''           ,
             'ycolor'       , 'w'           ,
             'color'        , 'none'                   );

saveas(gcf, [fn '_periods_axis.png'])
