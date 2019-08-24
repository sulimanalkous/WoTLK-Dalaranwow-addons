exMania = {};
  exMania.panel = CreateFrame("Frame", nil, UIParent);
  exMania.panel.name = "exMania";

  local title = exMania.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  title:SetPoint("TOPLEFT", 10, -16); title:SetText("Title");

  local desc = exMania.panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
  desc:SetPoint("TOPLEFT", 10, -40);
  desc:SetText("Replace most of default frames in the user interface with new improved frames and add some reinforcements to them plus warning colors for bars accompaniment with it alert sounds to prevent of distractions during play. ");
  --desc:SetWidth(exMania.panel:GetRight() - exMania.panel:GetLeft() - 10);

  InterfaceOptions_AddCategory(exMania.panel);

  exMania.FirstPanel = CreateFrame("Frame", nil, exMania.panel);
  exMania.FirstPanel.name = "Appearance";
  exMania.FirstPanel.parent = exMania.panel.name;

  InterfaceOptions_AddCategory(exMania.FirstPanel);

  exMania.SecondPanel = CreateFrame("Frame", nil, exMania.panel);
  exMania.SecondPanel.name = "Window";
  exMania.SecondPanel.parent = exMania.panel.name;

  InterfaceOptions_AddCategory(exMania.SecondPanel);

