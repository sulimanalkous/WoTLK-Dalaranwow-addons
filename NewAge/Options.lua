NewAge = {};
 NewAge.panel = CreateFrame( "Frame", nil, UIParent );
 NewAge.panel.name = "NewAge";
 InterfaceOptions_AddCategory(NewAge.panel);

 NewAge.FirstPanel = CreateFrame( "Frame", nil, NewAge.panel);
 NewAge.FirstPanel.name = "Appearance";
 NewAge.FirstPanel.parent = NewAge.panel.name;
 InterfaceOptions_AddCategory(NewAge.FirstPanel);

 NewAge.SecondPanel = CreateFrame( "Frame", nil, NewAge.panel);
 NewAge.SecondPanel.name = "Window";
 NewAge.SecondPanel.parent = NewAge.panel.name;
 InterfaceOptions_AddCategory(NewAge.SecondPanel);
