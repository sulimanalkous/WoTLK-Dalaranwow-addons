msgFrame  = CreateFrame("Frame", "AnimorHistoryFrame", UIParent);
msgFrame:SetPoint("TOP", UIParent, "TOP", 0, -40);
msgFrame:SetFrameStrata("FULLSCREEN_DIALOG");
msgFrame.width  = 350;
msgFrame.height = 100;
msgFrame:SetSize(msgFrame.width, msgFrame.height);
msgFrame:SetBackdrop(FrameBackdrop);
msgFrame:SetBackdropColor(0, 0, 0, 0.25);
msgFrame:EnableMouse(true);
msgFrame:EnableMouseWheel(true);
--msgFrame:RegisterAllEvents();

-- ScrollingMessageFrame
ScrollFrame = CreateFrame("ScrollingMessageFrame", nil, msgFrame);
ScrollFrame:SetPoint("TOPLEFT", 5, -6);
ScrollFrame:SetSize(msgFrame.width - 23, msgFrame.height - 11);
ScrollFrame:SetBackdrop(FrameBackdrop);
ScrollFrame:SetBackdropColor(0, 0, 0, 0.25);
ScrollFrame:SetFontObject(GameFontNormal);
ScrollFrame:SetJustifyH("LEFT");
ScrollFrame:SetMaxLines(300);
ScrollFrame:SetHyperlinksEnabled(true);
ScrollFrame:SetFading(false);
msgFrame.messageFrame = ScrollFrame;

-- Scroll bar
local scrollBar = CreateFrame("Slider", nil, msgFrame, "UIPanelScrollBarTemplate");
scrollBar:SetPoint("TOPRIGHT", 6, -23);
scrollBar:SetSize(30, msgFrame.height - 44);
scrollBar:SetMinMaxValues(0, 9);
scrollBar:SetValueStep(1);
scrollBar.scrollStep = 1;
msgFrame.scrollBar = scrollBar;
scrollBar:SetScript("OnValueChanged", function(self, value)
	ScrollFrame:SetScrollOffset(select(2, scrollBar:GetMinMaxValues()) - value);
end);
scrollBar:SetValue(select(2, scrollBar:GetMinMaxValues()));

msgFrame:SetScript("OnMouseWheel", function(self, delta)
	local cur_val = scrollBar:GetValue();
	local min_val, max_val = scrollBar:GetMinMaxValues();
	if delta < 0 and cur_val < max_val then
		cur_val = math.min(max_val, cur_val + 1);
		scrollBar:SetValue(cur_val);
	elseif delta > 0 and cur_val > min_val then
		cur_val = math.max(min_val, cur_val - 1);
		scrollBar:SetValue(cur_val);
	end
end);

msgFrame:SetScript("OnEvent", function(self, event)
  --ScrollFrame:AddMessage(event);
end);

