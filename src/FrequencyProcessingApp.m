classdef FrequencyProcessingApp < matlab.apps.AppBase
    %FREQUENCYPROCESSINGAPP IF4073 Tugas 2 -- Pemrosesan Citra dalam
    %   Ranah Frekuensi. One GUI covering Parts B-F:
    %     Tab 1 - Frequency Filtering   (B: low-pass, C: high-pass, D: brightness)
    %     Tab 2 - Periodic Noise Restoration (E: bandreject / notch reject)
    %     Tab 3 - Motion Blur Restoration (F: inverse & Wiener filtering)

    properties (Access = public)
        UIFigure
        TabGroup
        Tab1
        Tab2
        Tab3

        % ---- Tab 1: Frequency Filtering ----
        T1LoadButton
        T1RunButton
        T1ExportButton
        T1ResetButton
        T1InputAxes
        T1InputSpecAxes
        T1ResultAxes
        T1ResultSpecAxes
        T1MaskAxes
        T1GroupDropDown
        T1VariantDropDown
        T1ParamPanel
        T1ParamGrid
        T1StatusLabel

        % ---- Tab 2: Periodic Noise Restoration ----
        T2LoadButton
        T2RunButton
        T2ExportButton
        T2ResetButton
        T2InputAxes
        T2SpecBeforeAxes
        T2ResultAxes
        T2SpecAfterAxes
        T2MaskAxes
        T2GroupDropDown
        T2VariantDropDown
        T2ParamPanel
        T2ParamGrid
        T2NotchPanel
        T2NotchTable
        T2AddNotchButton
        T2RemoveNotchButton
        T2StatusLabel

        % ---- Tab 3: Motion Blur Restoration ----
        T3LoadDegradedButton
        T3LoadOriginalButton
        T3RunButton
        T3ExportButton
        T3ResetButton
        T3DegradedAxes
        T3OriginalAxes
        T3PSFAxes
        T3InverseResultAxes
        T3WienerResultAxes
        T3AField
        T3BField
        T3TField
        T3RadiusField
        T3KField
        T3StatusLabel
    end

    properties (Access = private)
        Tab1Registry
        Tab2Registry
        T1ParamControls   % containers.Map: param name -> uieditfield
        T2ParamControls   % containers.Map: param name -> uieditfield

        T1Image = []
        T1Result = []

        T2Image = []
        T2Result = []

        T3DegradedImage = []
        T3OriginalImage = []
        T3InverseResult = []
        T3WienerResult = []
    end

    % =====================================================================
    %  Small reusable layout helpers (used by all three tabs)
    % =====================================================================
    methods (Access = private)

        function ax = buildLabeledAxesCell(~, parent, row, col, labelText)
            g = uigridlayout(parent);
            g.Layout.Row = row;
            g.Layout.Column = col;
            g.RowHeight = {18, '1x'};
            g.ColumnWidth = {'1x'};
            g.Padding = [2 2 2 2];
            g.RowSpacing = 2;

            lbl = uilabel(g);
            lbl.Text = labelText;
            lbl.FontWeight = 'bold';
            lbl.FontSize = 11;
            lbl.Layout.Row = 1;
            lbl.Layout.Column = 1;

            ax = uiaxes(g);
            ax.Layout.Row = 2;
            ax.Layout.Column = 1;
            ax.XTick = [];
            ax.YTick = [];
            box(ax, 'on');
        end

        function buttons = buildToolbar(~, parent, labels)
            g = uigridlayout(parent);
            n = numel(labels);
            g.ColumnWidth = repmat({'1x'}, 1, n);
            g.RowHeight = {'1x'};
            g.Padding = [6 6 6 6];
            g.ColumnSpacing = 8;
            buttons = gobjects(1, n);
            for i = 1:n
                b = uibutton(g, 'push');
                b.Text = labels{i};
                b.Layout.Row = 1;
                b.Layout.Column = i;
                buttons(i) = b;
            end
        end

        function map = buildParamPanel(~, paramGrid, specs)
            delete(paramGrid.Children);
            map = containers.Map('KeyType', 'char', 'ValueType', 'any');

            if isempty(specs)
                paramGrid.RowHeight = {'1x'};
                paramGrid.ColumnWidth = {'1x'};
                lbl = uilabel(paramGrid);
                lbl.Text = 'No numeric parameters for this method.';
                lbl.WordWrap = 'on';
                lbl.Layout.Row = 1;
                lbl.Layout.Column = 1;
                return;
            end

            n = numel(specs);
            paramGrid.RowHeight = repmat({26}, 1, n);
            paramGrid.ColumnWidth = {'1.3x', '1x'};
            for i = 1:n
                spec = specs(i);
                lbl = uilabel(paramGrid);
                lbl.Text = spec.Label;
                lbl.Layout.Row = i;
                lbl.Layout.Column = 1;

                ef = uieditfield(paramGrid, 'numeric');
                ef.Value = spec.Default;
                ef.Limits = [spec.Min spec.Max];
                ef.Layout.Row = i;
                ef.Layout.Column = 2;

                map(spec.Name) = ef;
            end
        end

        function populateVariantDropdown(~, registry, groupDropDown, variantDropDown)
            groupKey = groupDropDown.Value;
            idx = find(strcmp({registry.Key}, groupKey), 1);
            group = registry(idx);
            variantDropDown.Items = {group.Variants.Label};
            variantDropDown.ItemsData = {group.Variants.Key};
            variantDropDown.Value = group.Variants(1).Key;
        end

        function specs = currentParamSpecs(~, registry, groupDropDown, variantDropDown)
            groupKey = groupDropDown.Value;
            idxG = find(strcmp({registry.Key}, groupKey), 1);
            group = registry(idxG);
            variantKey = variantDropDown.Value;
            idxV = find(strcmp({group.Variants.Key}, variantKey), 1);
            specs = group.Variants(idxV).Params;
        end

        function paramsStruct = collectParams(~, map)
            paramsStruct = struct();
            ks = map.keys;
            for i = 1:numel(ks)
                k = ks{i};
                ef = map(k);
                paramsStruct.(k) = ef.Value;
            end
        end

        function img = loadImageDialog(app, promptText)
            img = [];
            [file, folder] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff', 'Image Files'}, promptText);
            if isequal(file, 0)
                return;
            end
            try
                img = imread(fullfile(folder, file));
            catch ME
                uialert(app.UIFigure, sprintf('Failed to load image:\n%s', ME.message), 'Load Error');
                img = [];
                return;
            end
        end

    end

    % =====================================================================
    %  Component creation
    % =====================================================================
    methods (Access = private)

        function createComponents(app)
            app.UIFigure = uifigure('Name', 'IF4073 Tugas 2 - Frequency Domain Processing Studio');
            app.UIFigure.Position = [60 50 1300 820];

            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Units = 'normalized';
            app.TabGroup.Position = [0 0 1 1];

            app.Tab1 = uitab(app.TabGroup, 'Title', 'Frequency Filtering (B/C/D)');
            app.Tab2 = uitab(app.TabGroup, 'Title', 'Periodic Noise Restoration (E)');
            app.Tab3 = uitab(app.TabGroup, 'Title', 'Motion Blur Restoration (F)');

            app.buildTab1();
            app.buildTab2();
            app.buildTab3();

            app.UIFigure.CloseRequestFcn = @(~, ~) delete(app);
        end

        % ---------------------------- TAB 1 ----------------------------
        function buildTab1(app)
            g = uigridlayout(app.Tab1);
            g.RowHeight = {56, '1x', 30};
            g.ColumnWidth = {'1x'};
            g.Padding = [8 8 8 8];
            g.RowSpacing = 8;

            toolbarPanel = uipanel(g);
            toolbarPanel.Layout.Row = 1;
            toolbarPanel.Layout.Column = 1;
            btns = app.buildToolbar(toolbarPanel, {'Load Image', 'Run', 'Export View', 'Reset'});
            app.T1LoadButton = btns(1);
            app.T1RunButton = btns(2);
            app.T1ExportButton = btns(3);
            app.T1ResetButton = btns(4);
            app.T1LoadButton.ButtonPushedFcn = @(~, ~) app.onT1Load();
            app.T1RunButton.ButtonPushedFcn = @(~, ~) app.onT1Run();
            app.T1ExportButton.ButtonPushedFcn = @(~, ~) app.onExportView();
            app.T1ResetButton.ButtonPushedFcn = @(~, ~) app.onT1Reset();

            content = uigridlayout(g);
            content.Layout.Row = 2;
            content.Layout.Column = 1;
            content.RowHeight = {'1x', '1x'};
            content.ColumnWidth = {'1x', '1x', '1x'};
            content.ColumnSpacing = 8;
            content.RowSpacing = 8;

            app.T1InputAxes = app.buildLabeledAxesCell(content, 1, 1, 'Input Image');
            app.T1ResultAxes = app.buildLabeledAxesCell(content, 1, 3, 'Result Image');
            app.T1InputSpecAxes = app.buildLabeledAxesCell(content, 2, 1, 'Input Spectrum');
            app.T1MaskAxes = app.buildLabeledAxesCell(content, 2, 2, 'Filter Mask H(u,v)');
            app.T1ResultSpecAxes = app.buildLabeledAxesCell(content, 2, 3, 'Result Spectrum');

            controlPanel = uipanel(content);
            controlPanel.Layout.Row = 1;
            controlPanel.Layout.Column = 2;
            controlPanel.Title = 'Group / Variant / Parameters';
            cg = uigridlayout(controlPanel);
            cg.RowHeight = {20, 30, 20, 30, '1x'};
            cg.ColumnWidth = {'1x'};
            cg.Padding = [8 8 8 8];
            cg.RowSpacing = 6;

            l1 = uilabel(cg); l1.Text = 'Technique Group'; l1.Layout.Row = 1; l1.Layout.Column = 1;
            app.T1GroupDropDown = uidropdown(cg);
            app.T1GroupDropDown.Layout.Row = 2; app.T1GroupDropDown.Layout.Column = 1;
            app.T1GroupDropDown.ValueChangedFcn = @(~, ~) app.onT1GroupChanged();

            l2 = uilabel(cg); l2.Text = 'Variant'; l2.Layout.Row = 3; l2.Layout.Column = 1;
            app.T1VariantDropDown = uidropdown(cg);
            app.T1VariantDropDown.Layout.Row = 4; app.T1VariantDropDown.Layout.Column = 1;
            app.T1VariantDropDown.ValueChangedFcn = @(~, ~) app.onT1VariantChanged();

            app.T1ParamPanel = uipanel(cg);
            app.T1ParamPanel.Layout.Row = 5; app.T1ParamPanel.Layout.Column = 1;
            app.T1ParamPanel.Title = 'Parameters';
            app.T1ParamGrid = uigridlayout(app.T1ParamPanel);
            app.T1ParamGrid.RowHeight = {'1x'};
            app.T1ParamGrid.ColumnWidth = {'1x'};
            app.T1ParamGrid.Padding = [6 6 6 6];

            app.T1StatusLabel = uilabel(g);
            app.T1StatusLabel.Layout.Row = 3;
            app.T1StatusLabel.Layout.Column = 1;
            app.T1StatusLabel.BackgroundColor = [0.93 0.93 0.93];
            app.T1StatusLabel.Text = 'Ready. Load an input image to begin.';

            app.Tab1Registry = filterRegistryTab1();
            app.T1GroupDropDown.Items = {app.Tab1Registry.Label};
            app.T1GroupDropDown.ItemsData = {app.Tab1Registry.Key};
            app.T1GroupDropDown.Value = app.Tab1Registry(1).Key;
            app.populateVariantDropdown(app.Tab1Registry, app.T1GroupDropDown, app.T1VariantDropDown);
            app.T1ParamControls = app.buildParamPanel(app.T1ParamGrid, ...
                app.currentParamSpecs(app.Tab1Registry, app.T1GroupDropDown, app.T1VariantDropDown));
        end

        % ---------------------------- TAB 2 ----------------------------
        function buildTab2(app)
            g = uigridlayout(app.Tab2);
            g.RowHeight = {56, '1x', 30};
            g.ColumnWidth = {'1x'};
            g.Padding = [8 8 8 8];
            g.RowSpacing = 8;

            toolbarPanel = uipanel(g);
            toolbarPanel.Layout.Row = 1;
            toolbarPanel.Layout.Column = 1;
            btns = app.buildToolbar(toolbarPanel, {'Load Degraded Image', 'Run', 'Export View', 'Reset'});
            app.T2LoadButton = btns(1);
            app.T2RunButton = btns(2);
            app.T2ExportButton = btns(3);
            app.T2ResetButton = btns(4);
            app.T2LoadButton.ButtonPushedFcn = @(~, ~) app.onT2Load();
            app.T2RunButton.ButtonPushedFcn = @(~, ~) app.onT2Run();
            app.T2ExportButton.ButtonPushedFcn = @(~, ~) app.onExportView();
            app.T2ResetButton.ButtonPushedFcn = @(~, ~) app.onT2Reset();

            content = uigridlayout(g);
            content.Layout.Row = 2;
            content.Layout.Column = 1;
            content.RowHeight = {'1x', '1x'};
            content.ColumnWidth = {'1x', '1x', '1x'};
            content.ColumnSpacing = 8;
            content.RowSpacing = 8;

            app.T2InputAxes = app.buildLabeledAxesCell(content, 1, 1, 'Degraded Image');
            app.T2ResultAxes = app.buildLabeledAxesCell(content, 1, 3, 'Restored Image');
            app.T2SpecBeforeAxes = app.buildLabeledAxesCell(content, 2, 1, 'Spectrum Before');
            app.T2MaskAxes = app.buildLabeledAxesCell(content, 2, 2, 'Filter Mask');
            app.T2SpecAfterAxes = app.buildLabeledAxesCell(content, 2, 3, 'Spectrum After');

            controlPanel = uipanel(content);
            controlPanel.Layout.Row = 1;
            controlPanel.Layout.Column = 2;
            controlPanel.Title = 'Filter / Variant / Parameters';
            cg = uigridlayout(controlPanel);
            cg.RowHeight = {20, 30, 20, 30, '1x', '1.3x'};
            cg.ColumnWidth = {'1x'};
            cg.Padding = [8 8 8 8];
            cg.RowSpacing = 6;

            l1 = uilabel(cg); l1.Text = 'Filter Type'; l1.Layout.Row = 1; l1.Layout.Column = 1;
            app.T2GroupDropDown = uidropdown(cg);
            app.T2GroupDropDown.Layout.Row = 2; app.T2GroupDropDown.Layout.Column = 1;
            app.T2GroupDropDown.ValueChangedFcn = @(~, ~) app.onT2GroupChanged();

            l2 = uilabel(cg); l2.Text = 'Variant'; l2.Layout.Row = 3; l2.Layout.Column = 1;
            app.T2VariantDropDown = uidropdown(cg);
            app.T2VariantDropDown.Layout.Row = 4; app.T2VariantDropDown.Layout.Column = 1;
            app.T2VariantDropDown.ValueChangedFcn = @(~, ~) app.onT2VariantChanged();

            app.T2ParamPanel = uipanel(cg);
            app.T2ParamPanel.Layout.Row = 5; app.T2ParamPanel.Layout.Column = 1;
            app.T2ParamPanel.Title = 'Parameters';
            app.T2ParamGrid = uigridlayout(app.T2ParamPanel);
            app.T2ParamGrid.RowHeight = {'1x'};
            app.T2ParamGrid.ColumnWidth = {'1x'};
            app.T2ParamGrid.Padding = [6 6 6 6];

            app.T2NotchPanel = uipanel(cg);
            app.T2NotchPanel.Layout.Row = 6; app.T2NotchPanel.Layout.Column = 1;
            app.T2NotchPanel.Title = 'Notch Points (u0, v0)';
            app.T2NotchPanel.Visible = 'off';
            ng = uigridlayout(app.T2NotchPanel);
            ng.RowHeight = {'1x', 26};
            ng.ColumnWidth = {'1x'};
            ng.Padding = [4 4 4 4];
            ng.RowSpacing = 4;

            app.T2NotchTable = uitable(ng);
            app.T2NotchTable.Layout.Row = 1; app.T2NotchTable.Layout.Column = 1;
            app.T2NotchTable.ColumnName = {'u0', 'v0'};
            app.T2NotchTable.ColumnEditable = [true true];
            app.T2NotchTable.Data = zeros(0, 2);

            nbg = uigridlayout(ng);
            nbg.Layout.Row = 2; nbg.Layout.Column = 1;
            nbg.RowHeight = {'1x'};
            nbg.ColumnWidth = {'1x', '1x'};
            nbg.Padding = [0 0 0 0];
            nbg.ColumnSpacing = 4;
            app.T2AddNotchButton = uibutton(nbg, 'push');
            app.T2AddNotchButton.Text = 'Add Notch';
            app.T2AddNotchButton.Layout.Row = 1; app.T2AddNotchButton.Layout.Column = 1;
            app.T2AddNotchButton.ButtonPushedFcn = @(~, ~) app.onAddNotch();
            app.T2RemoveNotchButton = uibutton(nbg, 'push');
            app.T2RemoveNotchButton.Text = 'Remove Last';
            app.T2RemoveNotchButton.Layout.Row = 1; app.T2RemoveNotchButton.Layout.Column = 2;
            app.T2RemoveNotchButton.ButtonPushedFcn = @(~, ~) app.onRemoveNotch();

            app.T2StatusLabel = uilabel(g);
            app.T2StatusLabel.Layout.Row = 3;
            app.T2StatusLabel.Layout.Column = 1;
            app.T2StatusLabel.BackgroundColor = [0.93 0.93 0.93];
            app.T2StatusLabel.Text = 'Ready. Load a degraded image to begin.';

            app.Tab2Registry = filterRegistryTab2();
            app.T2GroupDropDown.Items = {app.Tab2Registry.Label};
            app.T2GroupDropDown.ItemsData = {app.Tab2Registry.Key};
            app.T2GroupDropDown.Value = app.Tab2Registry(1).Key;
            app.populateVariantDropdown(app.Tab2Registry, app.T2GroupDropDown, app.T2VariantDropDown);
            app.T2ParamControls = app.buildParamPanel(app.T2ParamGrid, ...
                app.currentParamSpecs(app.Tab2Registry, app.T2GroupDropDown, app.T2VariantDropDown));
        end

        % ---------------------------- TAB 3 ----------------------------
        function buildTab3(app)
            g = uigridlayout(app.Tab3);
            g.RowHeight = {56, '1x', 30};
            g.ColumnWidth = {'1x'};
            g.Padding = [8 8 8 8];
            g.RowSpacing = 8;

            toolbarPanel = uipanel(g);
            toolbarPanel.Layout.Row = 1;
            toolbarPanel.Layout.Column = 1;
            btns = app.buildToolbar(toolbarPanel, {'Load Degraded', 'Load Original', 'Run', 'Export View', 'Reset'});
            app.T3LoadDegradedButton = btns(1);
            app.T3LoadOriginalButton = btns(2);
            app.T3RunButton = btns(3);
            app.T3ExportButton = btns(4);
            app.T3ResetButton = btns(5);
            app.T3LoadDegradedButton.ButtonPushedFcn = @(~, ~) app.onT3LoadDegraded();
            app.T3LoadOriginalButton.ButtonPushedFcn = @(~, ~) app.onT3LoadOriginal();
            app.T3RunButton.ButtonPushedFcn = @(~, ~) app.onT3Run();
            app.T3ExportButton.ButtonPushedFcn = @(~, ~) app.onExportView();
            app.T3ResetButton.ButtonPushedFcn = @(~, ~) app.onT3Reset();

            content = uigridlayout(g);
            content.Layout.Row = 2;
            content.Layout.Column = 1;
            content.RowHeight = {'1x', '1x'};
            content.ColumnWidth = {'1x', '1x', '1x'};
            content.ColumnSpacing = 8;
            content.RowSpacing = 8;

            app.T3DegradedAxes = app.buildLabeledAxesCell(content, 1, 1, 'Degraded Image');
            app.T3OriginalAxes = app.buildLabeledAxesCell(content, 2, 1, 'Original (if loaded)');
            app.T3InverseResultAxes = app.buildLabeledAxesCell(content, 1, 3, 'Inverse Filtering Result');
            app.T3WienerResultAxes = app.buildLabeledAxesCell(content, 2, 3, 'Wiener Filtering Result');

            controlPanel = uipanel(content);
            controlPanel.Layout.Row = [1 2];
            controlPanel.Layout.Column = 2;
            controlPanel.Title = 'Motion Parameters / PSF';
            cg = uigridlayout(controlPanel);
            cg.RowHeight = {20, 28, 20, 28, 20, 28, '1x', 20, 28, 20, 28};
            cg.ColumnWidth = {'1x'};
            cg.Padding = [8 8 8 8];
            cg.RowSpacing = 4;

            la = uilabel(cg); la.Text = 'a (horizontal extent)'; la.Layout.Row = 1; la.Layout.Column = 1;
            app.T3AField = uieditfield(cg, 'numeric'); app.T3AField.Value = 0.1;
            app.T3AField.Layout.Row = 2; app.T3AField.Layout.Column = 1;

            lb = uilabel(cg); lb.Text = 'b (vertical extent)'; lb.Layout.Row = 3; lb.Layout.Column = 1;
            app.T3BField = uieditfield(cg, 'numeric'); app.T3BField.Value = 0.1;
            app.T3BField.Layout.Row = 4; app.T3BField.Layout.Column = 1;

            lt = uilabel(cg); lt.Text = 'T (exposure time)'; lt.Layout.Row = 5; lt.Layout.Column = 1;
            app.T3TField = uieditfield(cg, 'numeric'); app.T3TField.Value = 1;
            app.T3TField.Layout.Row = 6; app.T3TField.Layout.Column = 1;

            app.T3PSFAxes = uiaxes(cg);
            app.T3PSFAxes.Layout.Row = 7; app.T3PSFAxes.Layout.Column = 1;
            app.T3PSFAxes.XTick = []; app.T3PSFAxes.YTick = [];
            box(app.T3PSFAxes, 'on');
            title(app.T3PSFAxes, 'PSF / H(u,v)', 'FontSize', 10);

            lr = uilabel(cg); lr.Text = 'Inverse radius / threshold'; lr.Layout.Row = 8; lr.Layout.Column = 1;
            app.T3RadiusField = uieditfield(cg, 'numeric'); app.T3RadiusField.Value = 60;
            app.T3RadiusField.Limits = [1 Inf];
            app.T3RadiusField.Layout.Row = 9; app.T3RadiusField.Layout.Column = 1;

            lk = uilabel(cg); lk.Text = 'Wiener K (NSR)'; lk.Layout.Row = 10; lk.Layout.Column = 1;
            app.T3KField = uieditfield(cg, 'numeric'); app.T3KField.Value = 0.01;
            app.T3KField.Limits = [0 Inf];
            app.T3KField.Layout.Row = 11; app.T3KField.Layout.Column = 1;

            app.T3StatusLabel = uilabel(g);
            app.T3StatusLabel.Layout.Row = 3;
            app.T3StatusLabel.Layout.Column = 1;
            app.T3StatusLabel.BackgroundColor = [0.93 0.93 0.93];
            app.T3StatusLabel.Text = 'Ready. Load a degraded image, set the motion parameters, then Run.';
        end

    end

    % =====================================================================
    %  Tab 1 callbacks
    % =====================================================================
    methods (Access = private)

        function onT1GroupChanged(app, ~)
            app.populateVariantDropdown(app.Tab1Registry, app.T1GroupDropDown, app.T1VariantDropDown);
            app.onT1VariantChanged();
        end

        function onT1VariantChanged(app, ~)
            specs = app.currentParamSpecs(app.Tab1Registry, app.T1GroupDropDown, app.T1VariantDropDown);
            app.T1ParamControls = app.buildParamPanel(app.T1ParamGrid, specs);
        end

        function onT1Load(app, ~)
            img = app.loadImageDialog('Select Input Image');
            if isempty(img)
                return;
            end
            app.T1Image = img;
            app.T1Result = [];
            showImageOnAxes(app.T1InputAxes, img);
            showSpectrumOnAxes(app.T1InputSpecAxes, img);
            showImageOnAxes(app.T1ResultAxes, []);
            showSpectrumOnAxes(app.T1ResultSpecAxes, []);
            showMaskOnAxes(app.T1MaskAxes, []);
            app.T1StatusLabel.Text = 'Image loaded.';
        end

        function onT1Run(app, ~)
            if isempty(app.T1Image)
                uialert(app.UIFigure, 'Load an input image first.', 'No Image');
                return;
            end
            groupKey = app.T1GroupDropDown.Value;
            variantKey = app.T1VariantDropDown.Value;
            params = app.collectParams(app.T1ParamControls);
            app.T1StatusLabel.Text = 'Processing...';
            drawnow;
            try
                tStart = tic;
                [J, H, methodLabel, paramStr] = applyTab1Filter(app.T1Image, groupKey, variantKey, params);
                elapsed = toc(tStart);
            catch ME
                uialert(app.UIFigure, sprintf('Processing failed:\n%s', ME.message), 'Run Error');
                app.T1StatusLabel.Text = 'Ready.';
                return;
            end
            app.T1Result = J;
            showImageOnAxes(app.T1ResultAxes, J);
            showSpectrumOnAxes(app.T1ResultSpecAxes, J);
            showMaskOnAxes(app.T1MaskAxes, H);
            app.T1StatusLabel.Text = sprintf('%s | %s | %.2fs', methodLabel, paramStr, elapsed);
        end

        function onT1Reset(app, ~)
            app.T1Image = [];
            app.T1Result = [];
            showImageOnAxes(app.T1InputAxes, []);
            showImageOnAxes(app.T1ResultAxes, []);
            showSpectrumOnAxes(app.T1InputSpecAxes, []);
            showSpectrumOnAxes(app.T1ResultSpecAxes, []);
            showMaskOnAxes(app.T1MaskAxes, []);
            app.T1GroupDropDown.Value = app.Tab1Registry(1).Key;
            app.populateVariantDropdown(app.Tab1Registry, app.T1GroupDropDown, app.T1VariantDropDown);
            app.onT1VariantChanged();
            app.T1StatusLabel.Text = 'Ready. Load an input image to begin.';
        end

    end

    % =====================================================================
    %  Tab 2 callbacks
    % =====================================================================
    methods (Access = private)

        function onT2GroupChanged(app, ~)
            app.populateVariantDropdown(app.Tab2Registry, app.T2GroupDropDown, app.T2VariantDropDown);
            app.onT2VariantChanged();
        end

        function onT2VariantChanged(app, ~)
            specs = app.currentParamSpecs(app.Tab2Registry, app.T2GroupDropDown, app.T2VariantDropDown);
            app.T2ParamControls = app.buildParamPanel(app.T2ParamGrid, specs);
            if strcmp(app.T2VariantDropDown.Value, 'notch')
                app.T2NotchPanel.Visible = 'on';
            else
                app.T2NotchPanel.Visible = 'off';
            end
        end

        function onT2Load(app, ~)
            img = app.loadImageDialog('Select Degraded Image');
            if isempty(img)
                return;
            end
            app.T2Image = img;
            app.T2Result = [];
            showImageOnAxes(app.T2InputAxes, img);
            showSpectrumOnAxes(app.T2SpecBeforeAxes, img);
            showImageOnAxes(app.T2ResultAxes, []);
            showSpectrumOnAxes(app.T2SpecAfterAxes, []);
            showMaskOnAxes(app.T2MaskAxes, []);
            app.T2StatusLabel.Text = 'Degraded image loaded.';
        end

        function onT2Run(app, ~)
            if isempty(app.T2Image)
                uialert(app.UIFigure, 'Load a degraded image first.', 'No Image');
                return;
            end
            groupKey = app.T2GroupDropDown.Value;
            variantKey = app.T2VariantDropDown.Value;
            params = app.collectParams(app.T2ParamControls);
            notchPoints = app.T2NotchTable.Data;
            app.T2StatusLabel.Text = 'Processing...';
            drawnow;
            try
                tStart = tic;
                [J, H, methodLabel, paramStr] = applyTab2Filter(app.T2Image, groupKey, variantKey, params, notchPoints);
                elapsed = toc(tStart);
            catch ME
                uialert(app.UIFigure, sprintf('Processing failed:\n%s', ME.message), 'Run Error');
                app.T2StatusLabel.Text = 'Ready.';
                return;
            end
            app.T2Result = J;
            showImageOnAxes(app.T2ResultAxes, J);
            showSpectrumOnAxes(app.T2SpecAfterAxes, J);
            showMaskOnAxes(app.T2MaskAxes, H);
            app.T2StatusLabel.Text = sprintf('%s | %s | %.2fs', methodLabel, paramStr, elapsed);
        end

        function onT2Reset(app, ~)
            app.T2Image = [];
            app.T2Result = [];
            showImageOnAxes(app.T2InputAxes, []);
            showImageOnAxes(app.T2ResultAxes, []);
            showSpectrumOnAxes(app.T2SpecBeforeAxes, []);
            showSpectrumOnAxes(app.T2SpecAfterAxes, []);
            showMaskOnAxes(app.T2MaskAxes, []);
            app.T2NotchTable.Data = zeros(0, 2);
            app.T2GroupDropDown.Value = app.Tab2Registry(1).Key;
            app.populateVariantDropdown(app.Tab2Registry, app.T2GroupDropDown, app.T2VariantDropDown);
            app.onT2VariantChanged();
            app.T2StatusLabel.Text = 'Ready. Load a degraded image to begin.';
        end

        function onAddNotch(app, ~)
            app.T2NotchTable.Data = [app.T2NotchTable.Data; 10 10];
        end

        function onRemoveNotch(app, ~)
            d = app.T2NotchTable.Data;
            if ~isempty(d)
                app.T2NotchTable.Data = d(1:end-1, :);
            end
        end

    end

    % =====================================================================
    %  Tab 3 callbacks
    % =====================================================================
    methods (Access = private)

        function onT3LoadDegraded(app, ~)
            img = app.loadImageDialog('Select Degraded Image');
            if isempty(img)
                return;
            end
            app.T3DegradedImage = img;
            app.T3InverseResult = [];
            app.T3WienerResult = [];
            showImageOnAxes(app.T3DegradedAxes, img);
            showImageOnAxes(app.T3InverseResultAxes, []);
            showImageOnAxes(app.T3WienerResultAxes, []);
            showMaskOnAxes(app.T3PSFAxes, []);
            app.T3StatusLabel.Text = 'Degraded image loaded.';
        end

        function onT3LoadOriginal(app, ~)
            img = app.loadImageDialog('Select Original Image (optional)');
            if isempty(img)
                return;
            end
            app.T3OriginalImage = img;
            showImageOnAxes(app.T3OriginalAxes, img);
        end

        function onT3Run(app, ~)
            if isempty(app.T3DegradedImage)
                uialert(app.UIFigure, 'Load a degraded image first.', 'No Image');
                return;
            end
            a = app.T3AField.Value;
            b = app.T3BField.Value;
            T = app.T3TField.Value;
            radiusLimit = app.T3RadiusField.Value;
            K = app.T3KField.Value;
            app.T3StatusLabel.Text = 'Processing...';
            drawnow;
            try
                tStart = tic;
                [Jinv, Jwien, H] = applyTab3Restoration(app.T3DegradedImage, a, b, T, radiusLimit, K);
                elapsed = toc(tStart);
            catch ME
                uialert(app.UIFigure, sprintf('Processing failed:\n%s', ME.message), 'Run Error');
                app.T3StatusLabel.Text = 'Ready.';
                return;
            end
            app.T3InverseResult = Jinv;
            app.T3WienerResult = Jwien;
            showImageOnAxes(app.T3InverseResultAxes, Jinv);
            showImageOnAxes(app.T3WienerResultAxes, Jwien);
            showMaskOnAxes(app.T3PSFAxes, H);
            app.T3StatusLabel.Text = sprintf('a=%g b=%g T=%g | radius=%g K=%g | %.2fs', a, b, T, radiusLimit, K, elapsed);
        end

        function onT3Reset(app, ~)
            app.T3DegradedImage = [];
            app.T3OriginalImage = [];
            app.T3InverseResult = [];
            app.T3WienerResult = [];
            showImageOnAxes(app.T3DegradedAxes, []);
            showImageOnAxes(app.T3OriginalAxes, []);
            showImageOnAxes(app.T3InverseResultAxes, []);
            showImageOnAxes(app.T3WienerResultAxes, []);
            showMaskOnAxes(app.T3PSFAxes, []);
            app.T3AField.Value = 0.1;
            app.T3BField.Value = 0.1;
            app.T3TField.Value = 1;
            app.T3RadiusField.Value = 60;
            app.T3KField.Value = 0.01;
            app.T3StatusLabel.Text = 'Ready. Load a degraded image, set the motion parameters, then Run.';
        end

    end

    % =====================================================================
    %  Shared: export (captures whichever tab is currently active)
    % =====================================================================
    methods (Access = private)

        function onExportView(app, ~)
            folder = uigetdir(pwd, 'Select folder to save the current view');
            if isequal(folder, 0)
                return;
            end
            fname = fullfile(folder, ['gui_snapshot_' datestr(now, 'yyyymmdd_HHMMSS') '.png']); %#ok<TNOW1,DATST>
            try
                exportapp(app.UIFigure, fname);
                uialert(app.UIFigure, sprintf('Saved to:\n%s', fname), 'Exported', 'Icon', 'success');
            catch ME
                uialert(app.UIFigure, sprintf('Export failed:\n%s', ME.message), 'Export Error');
            end
        end

    end

    % =====================================================================
    %  Constructor / destructor
    % =====================================================================
    methods (Access = public)

        function app = FrequencyProcessingApp()
            srcRoot = fileparts(mfilename('fullpath'));
            coreRoot = fullfile(srcRoot, 'core');
            if exist(srcRoot, 'dir')
                addpath(srcRoot);
            end
            if exist(coreRoot, 'dir')
                addpath(coreRoot);
            end

            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure);
        end

    end
end
