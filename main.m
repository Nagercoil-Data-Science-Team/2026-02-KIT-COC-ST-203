%% ================================================================
%  BEFORE vs AFTER OPTIMIZATION — REAL-TIME WAVE PLOTS
%  Each metric in its own separate figure window
%  Light background | Waveform + Bar comparison per metric
%% ================================================================
clc; clear; close all;

%% ================================================================
%  SIMULATED DATA (n=60 time points)
%% ================================================================
rng(7);
n = 60;
t = 1:n;

% ---- BEFORE data (unhealthy range, noisy) ----
BP_bef   = 145 + 12*sin(2*pi*t/20) + randn(1,n)*6;
SpO2_bef = 88  + 3*sin(2*pi*t/15)  + randn(1,n)*1.5;
HR_bef   = 108 + 15*sin(2*pi*t/12) + randn(1,n)*5;
Sleep_bef= 4.2 + 0.8*sin(2*pi*t/30)+ randn(1,n)*0.4;
Usab_bef = 4.5 + 0.6*sin(2*pi*t/18)+ randn(1,n)*0.3;

% ---- AFTER data (optimized, calmer) ----
BP_aft   = 118 + 6*sin(2*pi*t/20)  + randn(1,n)*3;
SpO2_aft = 97  + 1.5*sin(2*pi*t/15)+ randn(1,n)*0.6;
HR_aft   = 72  + 8*sin(2*pi*t/12)  + randn(1,n)*3;
Sleep_aft= 7.2 + 0.5*sin(2*pi*t/30)+ randn(1,n)*0.3;
Usab_aft = 8.2 + 0.4*sin(2*pi*t/18)+ randn(1,n)*0.25;

% Clamp to realistic ranges
BP_bef   = max(125,min(175,BP_bef));    BP_aft  = max(100,min(135,BP_aft));
SpO2_bef = max(83, min(93, SpO2_bef));  SpO2_aft= max(94, min(100,SpO2_aft));
HR_bef   = max(95, min(145,HR_bef));    HR_aft  = max(58, min(90, HR_aft));
Sleep_bef= max(3,  min(6,  Sleep_bef)); Sleep_aft=max(6,  min(9,  Sleep_aft));
Usab_bef = max(3,  min(6,  Usab_bef));  Usab_aft= max(7,  min(10, Usab_aft));

%% ================================================================
%  METRIC CONFIG
%% ================================================================
metrics = {
    'Usability Score',   Usab_bef,  Usab_aft,  'Score',    [3  10],  [0.95 0.40 0.10], [0.10 0.65 0.30],  1;
    'Blood Pressure',    BP_bef,    BP_aft,     'mmHg',     [90 180], [0.85 0.15 0.15], [0.15 0.55 0.90], -1;
    'Heart Rate',        HR_bef,    HR_aft,     'bpm',      [50 160], [0.90 0.25 0.25], [0.10 0.60 0.85], -1;
    'SpO2',              SpO2_bef,  SpO2_aft,   '%',        [80 100], [0.80 0.35 0.10], [0.10 0.70 0.40],  1;
    'Sleep Hours',       Sleep_bef, Sleep_aft,  'hrs',      [3  10],  [0.75 0.20 0.60], [0.10 0.55 0.80],  1;
};
% cols: name | bef_data | aft_data | unit | yrange | color_bef | color_aft | improve_dir

nMetrics = size(metrics,1);

%% ================================================================
%  SCREEN TILING — 3 columns x 2 rows
%% ================================================================
scr  = get(0,'ScreenSize');
cols_layout = 3;
rows_layout = 2;
padX = 40; padY = 50;
titH = 30;  % rough taskbar
winW = floor((scr(3) - padX*(cols_layout+1)) / cols_layout);
winH = floor((scr(4) - titH - padY*(rows_layout+1)) / rows_layout);

winPos = cell(6,1);
for r = 1:rows_layout
    for c = 1:cols_layout
        idx = (r-1)*cols_layout + c;
        px  = padX + (c-1)*(winW+padX);
        py  = scr(4) - titH - r*(winH+padY) + padY;
        winPos{idx} = [px py winW winH];
    end
end

%% ================================================================
%  LIGHT THEME HELPER
%% ================================================================
BG      = [0.97 0.97 1.00];   % figure background
AX_BG   = [1.00 1.00 1.00];   % axes background
AX_COL  = [0.25 0.25 0.35];   % axis line / tick color
GRID_C  = [0.82 0.82 0.90];   % grid color
TXT_C   = [0.15 0.15 0.25];   % title/label text

%% ================================================================
%  FIGURES 1-5: One window per metric
%% ================================================================
for mi = 1:nMetrics

    mName  = metrics{mi,1};
    d_bef  = metrics{mi,2};
    d_aft  = metrics{mi,3};
    mUnit  = metrics{mi,4};
    yRng   = metrics{mi,5};
    cB     = metrics{mi,6};   % before color
    cA     = metrics{mi,7};   % after color
    impDir = metrics{mi,8};

    fig = figure('Name', sprintf('%s — Before vs After', mName), ...
        'Position', winPos{mi}, ...
        'Color', BG, ...
        'NumberTitle','off');

    %--------------------------------------------------
    % TOP TITLE BAND
    %--------------------------------------------------
    annotation(fig,'textbox',[0 0.92 1 0.08], ...
        'String', sprintf('  Step 9:  %s  —  Before vs After Optimization', mName), ...
        'HorizontalAlignment','left','VerticalAlignment','middle', ...
        'FontSize',13,'FontWeight','bold','Color',TXT_C, ...
        'BackgroundColor',[0.90 0.92 1.00],'EdgeColor',[0.70 0.72 0.90], ...
        'FitBoxToText','off','Interpreter','none');

    %==================================================
    % SUBPLOT 1: BEFORE waveform (real-time style)
    %==================================================
    ax1 = subplot(3,2,1);
    setupAx(ax1, AX_BG, AX_COL, GRID_C);
    hold(ax1,'on');

    % Fill under curve
    fill(ax1,[t fliplr(t)],[d_bef ones(1,n)*yRng(1)], cB, ...
        'FaceAlpha',0.18,'EdgeColor','none');
    % Main waveform line
    plot(ax1, t, d_bef, '-','Color',cB,'LineWidth',2.0);
    % Mean line
    mu_b = mean(d_bef);
    plot(ax1,[1 n],[mu_b mu_b],'--','Color',cB*0.7,'LineWidth',1.4);
    text(ax1, n*0.72, mu_b + (yRng(2)-yRng(1))*0.04, ...
        sprintf('Mean: %.1f %s',mu_b,mUnit), ...
        'FontSize',9,'Color',cB*0.7,'FontWeight','bold');

    ylim(ax1, yRng); xlim(ax1,[1 n]);
    ylabel(ax1, mUnit,'FontSize',9,'Color',TXT_C);
    title(ax1,'BEFORE Optimization','FontSize',10,'FontWeight','bold','Color',cB*0.8);
    ax1.XTickLabel = {};

    %==================================================
    % SUBPLOT 2: AFTER waveform (real-time style)
    %==================================================
    ax2 = subplot(3,2,2);
    setupAx(ax2, AX_BG, AX_COL, GRID_C);
    hold(ax2,'on');

    fill(ax2,[t fliplr(t)],[d_aft ones(1,n)*yRng(1)], cA, ...
        'FaceAlpha',0.18,'EdgeColor','none');
    plot(ax2, t, d_aft, '-','Color',cA,'LineWidth',2.0);
    mu_a = mean(d_aft);
    plot(ax2,[1 n],[mu_a mu_a],'--','Color',cA*0.7,'LineWidth',1.4);
    text(ax2, n*0.72, mu_a + (yRng(2)-yRng(1))*0.04, ...
        sprintf('Mean: %.1f %s',mu_a,mUnit), ...
        'FontSize',9,'Color',cA*0.7,'FontWeight','bold');

    ylim(ax2, yRng); xlim(ax2,[1 n]);
    ylabel(ax2, mUnit,'FontSize',9,'Color',TXT_C);
    title(ax2,'AFTER Optimization','FontSize',10,'FontWeight','bold','Color',cA*0.8);
    ax2.XTickLabel = {};

    %==================================================
    % SUBPLOT 3-4 (merged): OVERLAY waveform comparison
    %==================================================
    ax3 = subplot(3,2,[3 4]);
    setupAx(ax3, AX_BG, AX_COL, GRID_C);
    hold(ax3,'on');

    fill(ax3,[t fliplr(t)],[d_bef ones(1,n)*yRng(1)], cB, ...
        'FaceAlpha',0.12,'EdgeColor','none');
    fill(ax3,[t fliplr(t)],[d_aft ones(1,n)*yRng(1)], cA, ...
        'FaceAlpha',0.12,'EdgeColor','none');
    lB = plot(ax3,t,d_bef,'-','Color',cB,'LineWidth',1.8);
    lA = plot(ax3,t,d_aft,'-','Color',cA,'LineWidth',1.8);

    % Shade improvement zone between means
    ylo = min(mu_b,mu_a); yhi = max(mu_b,mu_a);
    fill(ax3,[1 n n 1],[ylo ylo yhi yhi],[0.60 0.90 0.60], ...
        'FaceAlpha',0.12,'EdgeColor','none');

    plot(ax3,[1 n],[mu_b mu_b],'--','Color',cB,'LineWidth',1.2);
    plot(ax3,[1 n],[mu_a mu_a],'--','Color',cA,'LineWidth',1.2);

    legend(ax3,[lB lA],{'Before','After'}, ...
        'Location','northeast','FontSize',9,'Box','on', ...
        'TextColor',TXT_C,'EdgeColor',[0.75 0.76 0.88]);
    ylim(ax3,yRng); xlim(ax3,[1 n]);
    xlabel(ax3,'Time Points','FontSize',9,'Color',TXT_C);
    ylabel(ax3,mUnit,'FontSize',9,'Color',TXT_C);
    title(ax3,'Overlay Comparison — Before (solid) vs After (solid)', ...
        'FontSize',10,'FontWeight','bold','Color',TXT_C);

    %==================================================
    % SUBPLOT 5: Bar comparison with stats
    %==================================================
    ax4 = subplot(3,2,5);
    setupAx(ax4, AX_BG, AX_COL, GRID_C);
    hold(ax4,'on');

    b1 = bar(ax4,1,mu_b,0.45,'FaceColor',cB,'EdgeColor',cB*0.7,'LineWidth',1.2);
    b2 = bar(ax4,2,mu_a,0.45,'FaceColor',cA,'EdgeColor',cA*0.7,'LineWidth',1.2);

    % Std dev error bars
    errorbar(ax4,1,mu_b,std(d_bef),'Color',cB*0.6,'LineWidth',1.8,'CapSize',12);
    errorbar(ax4,2,mu_a,std(d_aft),'Color',cA*0.6,'LineWidth',1.8,'CapSize',12);

    % Value text
    vpad = (yRng(2)-yRng(1))*0.04;
    text(ax4,1,mu_b+vpad,sprintf('%.2f',mu_b), ...
        'HorizontalAlignment','center','FontSize',10,'FontWeight','bold','Color',cB*0.8);
    text(ax4,2,mu_a+vpad,sprintf('%.2f',mu_a), ...
        'HorizontalAlignment','center','FontSize',10,'FontWeight','bold','Color',cA*0.8);

    set(ax4,'XTick',[1 2],'XTickLabel',{'Before','After'});
    ax4.XAxis.FontSize=10; ax4.XAxis.FontWeight='bold';
    ylim(ax4,[yRng(1) yRng(2)+(yRng(2)-yRng(1))*0.15]);
    ylabel(ax4,mUnit,'FontSize',9,'Color',TXT_C);
    title(ax4,'Mean ± Std Dev','FontSize',10,'FontWeight','bold','Color',TXT_C);

    %==================================================
    % SUBPLOT 6: Delta / Improvement indicator
    %==================================================
    ax5 = subplot(3,2,6);
    setupAx(ax5, AX_BG, AX_COL, GRID_C);
    hold(ax5,'on');

    delta_ts = d_aft - d_bef;   % point-wise change
    zero_line = zeros(1,n);

    % Color positive and negative separately
    posIdx = delta_ts >= 0;
    negIdx = delta_ts <  0;

    if any(posIdx)
        fill(ax5,[t(posIdx) fliplr(t(posIdx))], ...
            [delta_ts(posIdx) zeros(1,sum(posIdx))], ...
            [0.15 0.72 0.35],'FaceAlpha',0.40,'EdgeColor','none');
    end
    if any(negIdx)
        fill(ax5,[t(negIdx) fliplr(t(negIdx))], ...
            [delta_ts(negIdx) zeros(1,sum(negIdx))], ...
            [0.85 0.20 0.20],'FaceAlpha',0.40,'EdgeColor','none');
    end

    plot(ax5,t,delta_ts,'-','Color',[0.30 0.30 0.50],'LineWidth',1.8);
    plot(ax5,[1 n],[0 0],'-','Color',[0.50 0.50 0.60],'LineWidth',1.2);

    % Mean delta annotation
    meanDelta = mean(delta_ts);
    pct = (meanDelta/mu_b)*100;
    if (meanDelta*impDir) > 0
        dCol = [0.05 0.55 0.20]; dTxt = 'IMPROVED';
    else
        dCol = [0.75 0.10 0.10]; dTxt = 'DECLINED';
    end
    text(ax5, n*0.5, max(delta_ts)*0.75, ...
        sprintf('%s\n%+.2f %s avg\n(%+.1f%%)', dTxt, meanDelta, mUnit, pct), ...
        'HorizontalAlignment','center','FontSize',10,'FontWeight','bold', ...
        'Color',dCol,'BackgroundColor',[0.95 0.97 1.00], ...
        'EdgeColor',dCol,'Margin',5);

    xlim(ax5,[1 n]);
    xlabel(ax5,'Time Points','FontSize',9,'Color',TXT_C);
    ylabel(ax5,sprintf('Delta (%s)',mUnit),'FontSize',9,'Color',TXT_C);
    title(ax5,'Point-wise Change  (After - Before)', ...
        'FontSize',10,'FontWeight','bold','Color',TXT_C);

    fig.Color = BG;
    drawnow;
end

%% ================================================================
%  FIGURE 6: FULL SUMMARY WINDOW — All 5 metrics
%% ================================================================
figS = figure('Name','Step 9 — Full Summary: All Metrics Before vs After', ...
    'Position', winPos{6}, ...
    'Color', BG, ...
    'NumberTitle','off');

annotation(figS,'textbox',[0 0.93 1 0.07], ...
    'String','  Step 9:  Full Optimization Summary — All 5 Metrics', ...
    'HorizontalAlignment','left','VerticalAlignment','middle', ...
    'FontSize',13,'FontWeight','bold','Color',TXT_C, ...
    'BackgroundColor',[0.90 0.92 1.00],'EdgeColor',[0.70 0.72 0.90], ...
    'FitBoxToText','off');

%------------------------------------------------------
% Top panel: Normalized waveforms all-in-one
%------------------------------------------------------
axAll = subplot(2,1,1);
setupAx(axAll, AX_BG, AX_COL, GRID_C);
hold(axAll,'on');

all_bef = {Usab_bef, BP_bef, HR_bef, SpO2_bef, Sleep_bef};
all_aft = {Usab_aft, BP_aft, HR_aft, SpO2_aft, Sleep_aft};
mNames  = {'Usability','BP','Heart Rate','SpO2','Sleep'};
bef_cols = {metrics{1,6},metrics{2,6},metrics{3,6},metrics{4,6},metrics{5,6}};
aft_cols = {metrics{1,7},metrics{2,7},metrics{3,7},metrics{4,7},metrics{5,7}};
rngs     = {metrics{1,5},metrics{2,5},metrics{3,5},metrics{4,5},metrics{5,5}};

leg_handles = [];
leg_labels  = {};
for mi2 = 1:nMetrics
    lo = rngs{mi2}(1); hi = rngs{mi2}(2);
    nb = (all_bef{mi2}-lo)/(hi-lo)*100;
    na = (all_aft{mi2}-lo)/(hi-lo)*100;
    hb = plot(axAll,t,nb,'-','Color',bef_cols{mi2},'LineWidth',1.5,'LineStyle','--');
    ha = plot(axAll,t,na,'-','Color',aft_cols{mi2},'LineWidth',1.5);
    if mi2==1
        leg_handles(end+1)=hb; leg_labels{end+1}='— Before (dashed)';
        leg_handles(end+1)=ha; leg_labels{end+1}='— After (solid)';
    end
end

ylim(axAll,[0 100]); xlim(axAll,[1 n]);
xlabel(axAll,'Time Points','FontSize',9,'Color',TXT_C);
ylabel(axAll,'Normalized Score (0-100)','FontSize',9,'Color',TXT_C);
title(axAll,'All Metrics Normalized — Before (dashed) vs After (solid)', ...
    'FontSize',11,'FontWeight','bold','Color',TXT_C);
legend(axAll,leg_handles,leg_labels,'Location','southeast','FontSize',8, ...
    'TextColor',TXT_C,'EdgeColor',[0.75 0.76 0.88]);

%------------------------------------------------------
% Bottom panel: Grouped bar — mean before vs after, all metrics
%------------------------------------------------------
axBar = subplot(2,1,2);
setupAx(axBar, AX_BG, AX_COL, GRID_C);
hold(axBar,'on');

norm_bef = zeros(1,nMetrics);
norm_aft = zeros(1,nMetrics);
imp_dirs = cell2mat(metrics(:,8))';

for mi2 = 1:nMetrics
    lo = rngs{mi2}(1); hi = rngs{mi2}(2);
    norm_bef(mi2) = (mean(all_bef{mi2})-lo)/(hi-lo)*100;
    norm_aft(mi2) = (mean(all_aft{mi2})-lo)/(hi-lo)*100;
end

bw2 = 0.30;
for mi2 = 1:nMetrics
    bar(axBar, mi2-bw2/2, norm_bef(mi2), bw2, ...
        'FaceColor',bef_cols{mi2},'EdgeColor','none','FaceAlpha',0.75);
    bar(axBar, mi2+bw2/2, norm_aft(mi2), bw2, ...
        'FaceColor',aft_cols{mi2},'EdgeColor','none','FaceAlpha',0.75);
    % Arrow / delta
    delta_n = norm_aft(mi2) - norm_bef(mi2);
    if (delta_n * imp_dirs(mi2)) > 0
        arrowC = [0.05 0.55 0.15];
        arrowS = sprintf('+%.1f',delta_n);
    else
        arrowC = [0.80 0.10 0.10];
        arrowS = sprintf('%.1f',delta_n);
    end
    plot(axBar,[mi2-bw2/2 mi2+bw2/2],[norm_bef(mi2) norm_aft(mi2)], ...
        '-o','Color',arrowC,'LineWidth',2.0,'MarkerSize',5,'MarkerFaceColor',arrowC);
    text(axBar, mi2, max(norm_bef(mi2),norm_aft(mi2))+3.5, arrowS, ...
        'HorizontalAlignment','center','FontSize',9,'FontWeight','bold','Color',arrowC);
end

set(axBar,'XTick',1:nMetrics,'XTickLabel',mNames);
axBar.XAxis.FontSize=10; axBar.XAxis.FontWeight='bold';
ylim(axBar,[0 115]);
ylabel(axBar,'Normalized Score (0-100)','FontSize',9,'Color',TXT_C);
title(axBar,'Mean Comparison — All Metrics (Normalized)  |  Green = Improved, Red = Declined', ...
    'FontSize',10,'FontWeight','bold','Color',TXT_C);

bLeg1 = bar(axBar,NaN,NaN,bw2,'FaceColor',[0.5 0.5 0.7],'EdgeColor','none');
bLeg2 = bar(axBar,NaN,NaN,bw2,'FaceColor',[0.3 0.7 0.4],'EdgeColor','none');
legend(axBar,[bLeg1 bLeg2],{'Before Optimization','After Optimization'}, ...
    'Location','north','FontSize',9,'TextColor',TXT_C,'EdgeColor',[0.75 0.76 0.88]);

figS.Color = BG;
drawnow;

%% ================================================================
%  COMMAND WINDOW SUMMARY
%% ================================================================
fprintf('\n=================================================\n');
fprintf('   BEFORE vs AFTER OPTIMIZATION — SUMMARY\n');
fprintf('=================================================\n');
fprintf('%-16s %8s %8s %10s  %s\n','Metric','Before','After','Change','Result');
fprintf('%-16s %8s %8s %10s  %s\n','------','------','-----','------','------');
mUnits = {'pts','mmHg','bpm','%','hrs'};
for mi2=1:nMetrics
    mb = mean(all_bef{mi2}); ma = mean(all_aft{mi2});
    dd = ma - mb; pc = (dd/mb)*100;
    if (dd*imp_dirs(mi2))>0, st='IMPROVED'; else, st='DECLINED'; end
    fprintf('%-16s %8.2f %8.2f  %+8.2f %-4s (%+.1f%%)  %s\n', ...
        mNames{mi2},mb,ma,dd,mUnits{mi2},pc,st);
end
fprintf('=================================================\n\n');

%% ================================================================
%  HELPER: Setup axes with light theme
%% ================================================================
function setupAx(ax, axBG, axCol, gridC)
    ax.Color           = axBG;
    ax.XColor          = axCol;
    ax.YColor          = axCol;
    ax.GridColor       = gridC;
    ax.MinorGridColor  = gridC;
    ax.XGrid           = 'on';
    ax.YGrid           = 'on';
    ax.FontSize        = 9;
    ax.Box             = 'off';
    ax.LineWidth       = 1.0;
    ax.TickDir         = 'out';
end