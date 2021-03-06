EditorMenu = EditorMenu or class() 
function EditorMenu:init()
    self._menus = {}
    local accent_color = BeardLibEditor.Options:GetValue("AccentColor")
	self._main_menu = MenuUI:new({
        name = "Editor",
        layer = 1500,
        background_blur = true,
        auto_text_color = true,
        accent_color = accent_color,
        marker_highlight_color = accent_color,
		create_items = callback(self, self, "create_items"),
	})
	MenuCallbackHandler.BeardLibEditorMenu = callback(self, self, "set_enabled", true)
    MenuHelperPlus:AddButton({
        id = "BeardLibEditorMenu",
        title = "BeardLibEditorMenu",
        node_name = "options",
        position = managers.menu._is_start_menu and 9 or 7,
        callback = "BeardLibEditorMenu",
    })
end

function EditorMenu:make_page(name, clbk, opt)
    self._menus[name] = self._menus[name] or self._main_menu:Menu(table.merge({
        name = name,
        background_color = BeardLibEditor.Options:GetValue("BackgroundColor"),
        items_size = 20,
        visible = false,
        position = "RightBottom",
        w = self._main_menu._panel:w() - 250,
    }, opt or {}))
    self._menus[name].marker_highlight_color = self._menus[name].text_color:with_alpha(0.1)
    self:Button(name, clbk or callback(self, self, "select_page", name), {offset = 4, marker_highlight_color = self._menus[name].marker_highlight_color})

    return self._menus[name]
end

function EditorMenu:create_items(menu)
	self._main_menu = menu
	self._tabs = menu:Menu({
		name = "tabs",
        scrollbar = false,
        background_color = BeardLibEditor.Options:GetValue("BackgroundColor"),
        border_color = BeardLibEditor.Options:GetValue("AccentColor"),
        visible = true,
        items_size = 24,
        w = 200,
        h = self._main_menu._panel:h(),
        position = "Left",
	})
	MenuUtils:new(self, self._tabs)   
    local div = self:Divider("BeardLibEditor", {items_size = 24, offset = 0, marker_color = self._tabs.marker_highlight_color}) 
    self:SmallButton("x", callback(self, self, "set_enabled", false), div, {
        marker_highlight_color = false,
        w = self._tabs.items_size, h = self._tabs.items_size,
        text_align = "center", size_by_text = false
    })
end

function EditorMenu:should_close()
    return self._main_menu:ShouldClose()
end

function EditorMenu:hide()
    self:set_enabled(false)
    return true
end

function EditorMenu:set_enabled(enabled)
    local in_editor = managers.editor and game_state_machine:current_state_name() == "editor"
    local opened = BeardLib.managers.dialog:DialogOpened(self)
    if enabled then
        if not opened then
            BeardLib.managers.dialog:ShowDialog(self)
            self._main_menu:Enable()
            if in_editor then
                managers.editor._enabled = false
            end
        end
    elseif opened then
        BeardLib.managers.dialog:CloseDialog(self)
        self._main_menu:Disable()
        if in_editor then
            managers.editor._enabled = true
        end
    end
end

function EditorMenu:select_page(page, menu, item)
    for name, m in pairs(self._menus) do
        self._tabs:GetItem(name):SetBorder({left = false})
        m:SetVisible(false)
    end 
    if not page or self._current_page == page then
        self._current_page = nil
        return
    end
    self._current_page = page
    item:SetBorder({left = true})
    self._menus[page]:SetVisible(true)
end