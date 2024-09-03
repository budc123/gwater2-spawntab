-- by andrew
--	"Water", "Cloth", "Emitters And Drains", "Other"

GWater2EntityCategories = {
	"Water", "Cloth", "Emitters And Drains", "Other"
}

hook.Add("GWater2PopulateSpawnmenu", "AddGWater2Stuff", function(pnlContent, tree, node)
	-- DISCLAIMER not actual cats, its categories im too lazy to write it completely
	local cats = {}
	local ents = list.Get("gwater2_entities")
	
	if ents then
		for k,v in pairs(ents) do
			v.Category = v.Category or "Other"
			cats[v.Category] = cats[v.Category] or {}
			v.ClassName = k
			v.PrintName = v.Name
			table.insert(cats[v.Category], v)
		end
	end



	-- ENTITIES --
	local entnode = tree:AddNode("Entities", "icon16/bricks.png")
	local ListPanel = vgui.Create("ContentContainer", pnlContent)
	ListPanel:SetVisible(false)
	ListPanel:SetTriggerSpawnlistChange(false)
	
	entnode.DoPopulate = function(self)
		ListPanel:Clear()
		
		for k1,v1 in next, GWater2EntityCategories do
			local k,v = v1, cats[v1]
			local Header = vgui.Create("ContentHeader", ListPanel)
			Header:SetText(k)
			ListPanel:Add(Header)
			
			for k,ent in SortedPairsByMemberValue(v, "PrintName") do
				spawnmenu.CreateContentIcon("gwater2_entity", ListPanel, {
					nicename = ent.PrintName or ent.ClassName,
					spawnname = ent.ClassName,
					material = ent.Material,
					admin = ent.AdminOnly
				})
			end
		end
	end

	 entnode.DoClick = function(self)
	 	self:DoPopulate()
		pnlContent:SwitchPanel(ListPanel)
	 end
	
	-- Select the first node
	local FirstNode = tree:Root():GetChildNode(0)
	if IsValid(FirstNode) then
		FirstNode:InternalDoClick()
	end


	local menunode = tree:AddNode("Menu (WIP)", "icon16/wrench.png")
	local ListPanelMenu = vgui.Create("DPanel", pnlContent)
	ListPanelMenu:SetVisible(false)

	menunode.DoPopulate = function(self)
		ListPanelMenu:Clear()
		local menu = GWater2CreateMenu(ListPanelMenu)
		if menu then menu:Center() end
	end

	menunode.DoClick = function(self)
		self:DoPopulate()
		pnlContent:SwitchPanel(ListPanelMenu)
	end
end)

spawnmenu.AddCreationTab("GWater2", function()
	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	ctrl:CallPopulateHook("GWater2PopulateSpawnmenu")
	return ctrl
end, "icon16/water.png", 50, "Dynamic Water in Garry's Mod!")

spawnmenu.AddContentType("gwater2_entity", function(container, obj)
	if not obj.nicename then return end
	if not obj.spawnname then return end

	local icon = vgui.Create("ContentIcon", container)
	icon:SetContentType("gwater2_entity")
	icon:SetSpawnName(obj.spawnname)
	icon:SetName(obj.nicename)
	if obj.material then icon:SetMaterial(obj.material) end
	icon:SetAdminOnly(obj.admin and true or false)
	icon:SetColor(Color(0, 0, 0, 255))
	
	icon.DoClick = function()
		RunConsoleCommand("gm_spawnsent", obj.spawnname)
		surface.PlaySound("ui/buttonclickrelease.wav")
	end
	
	icon.OpenMenu = function(icon)
		local menu = DermaMenu()
			menu:AddOption("Copy to Clipboard", function() SetClipboardText(obj.spawnname) end)
			menu:AddOption("Spawn using Toolgun", function() 
				RunConsoleCommand("gmod_tool", "creator") 
				RunConsoleCommand("creator_type", "0") 
				RunConsoleCommand("creator_name", obj.spawnname) 
			end):SetIcon("icon16/brick_add.png")
		menu:Open()
	end
	
	if IsValid(container) then
		container:Add(icon)
	end

	return icon
end)