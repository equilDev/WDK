%this class retrieves a preprocessing algorithm from the UI
%this file duplicats the PreprocessingConfigurator and should be removed as
%soon as Matlab releases support for datacursor mode using App Designer
classdef PreprocessingConfiguratorGuide < handle

    properties (Access = private)
        %data
        columnNames;
        
        %computers
        signalComputers;
        
        %ui
        signalsList;
        signalComputersList;
        signalComputerVariablesTable;
        
        %state
        currentSignalComputerVariables;
    end
    
    methods (Access = public)
        function obj = PreprocessingConfiguratorGuide(signalComputers, signalsList,signalComputersList,signalComputerVariablesTable)
            obj.signalComputers = signalComputers;
            obj.signalsList = signalsList;
            obj.signalComputersList = signalComputersList;
            obj.signalComputerVariablesTable = signalComputerVariablesTable;
            
            obj.signalComputersList.Callback = @obj.handleSelectedSignalComputerChanged;
            
            obj.fillSignalComputersList();
            obj.updateSelectedSignalComputer();
            obj.updateSignalComputerVariablesTable();
        end
        
        function setDefaultSignals(obj)
            dataLoader = DataLoader();
            dataFiles = Helper.listDataFiles();
            if ~isempty(dataFiles)
                fileName = dataFiles{1};
                [~, obj.columnNames] = dataLoader.loadData(fileName);
            end
            obj.fillSignalsList();
        end
        
        function setSignals(obj,columnNames)
            obj.columnNames = columnNames;
            obj.fillSignalsList();
        end
        
        function signalComputer = getCurrentSignalComputer(obj)
            idx = obj.signalComputersList.Value;
            signalComputer = obj.signalComputers{idx};
        end
        
        function signalIdxs = getSelectedSignalIdxs(obj)
            signalIdxs = obj.signalsList.Value;
        end
        
        function computer = createSignalComputerWithUIParameters(obj)
            signalComputer = obj.getCurrentSignalComputer();
            
            data = obj.signalComputerVariablesTable.Data;
            for i = 1 : size(data,1)
                variableName = data{i,1};
                variableValue = data{i,2};
                property = Property(variableName,variableValue);
                signalComputer.setProperty(property);
            end
            
            selectedSignals = obj.getSelectedSignalIdxs();
            axisSelector = AxisSelector();
            axisSelector.axes = selectedSignals;
            
            axisSelector.addNextComputer(signalComputer);
            computer = CompositeComputer(axisSelector,{signalComputer});
            
            %computer = CompositeComputer.ComputerWithSequence({axisSelector, signalComputer});
        end
    end
    
    methods (Access = private)
        
        %ui
        function fillSignalComputersList(obj)
            obj.signalComputersList.String = Helper.generateComputerNamesArray(obj.signalComputers);
        end
        
        function fillSignalsList(obj)
            obj.signalsList.String = obj.columnNames;
        end
        
        function updateSignalComputerVariablesTable(obj)
            obj.signalComputerVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentSignalComputerVariables);
        end
        
        function updateSelectedSignalComputer(obj)
            signalComputer = obj.getCurrentSignalComputer();
            obj.currentSignalComputerVariables = signalComputer.getEditableProperties();
        end
        
        %methods
        
        function fillsignalList(obj)
            obj.signalsList.String = obj.columnNames;
        end        
        
        %handles
        function handleSelectedSignalComputerChanged(obj,~,~)
            obj.updateSelectedSignalComputer();
            obj.updateSignalComputerVariablesTable();
        end
    end
end