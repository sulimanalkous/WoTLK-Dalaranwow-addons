
RegisterUnitWatch(frame, asState)
/*
Assists in controlling unit frames -- can either show/hide the frame based on whether its unit exists;
or deliver that information via a state attribute.
frame: Frame-derived widget - The frame to be shown, hidden or notified when its unit exists or does not exist.
asState: Boolean - if true, the "state-unitexists" attribute will be set to a boolean value denoting whether the unit exists; if false,
the frame will be shown if its unit exists, and hidden if it does not.
*/
//Example
local frame = CreateFrame("BUTTON", nil, UIParent, "SecureUnitButtonTemplate");
frame:SetWidth(50); frame:SetHeight(50); frame:SetPoint("CENTER")
local tex = frame:CreateTexture(); tex:SetAllPoints(); tex:SetTexture(1,0,0)
frame:SetAttribute("unit", "player");
RegisterUnitWatch(frame)

/run print(GetMouseFocus():GetName()) //Get the active frame