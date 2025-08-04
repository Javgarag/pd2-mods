StorylineContinued = StorylineContinued or class()
StorylineContinued._path = ModPath
StorylineContinued._data_path = SavePath .. "StorylineContinued_data.txt"
StorylineContinued._data = {}

StorylineContinued._languages = {
	"en",
	"pl",
	"chs",
	"ru",
	"fr"
}

function StorylineContinued:Save()
	local file = io.open(self._data_path, "w+")
	if file then
		file:write(json.encode(self._data))
		file:close()
	end
end

function StorylineContinued:Load()
	local file = io.open(self._data_path, "r")
	if file then
		self._data = json.decode(file:read("*all"))
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_StorylineContinued", function(loc)
	StorylineContinued:Load()
	loc:load_localization_file(StorylineContinued._path .. "loc/" .. (StorylineContinued._data and StorylineContinued._languages[StorylineContinued._data.language] or "en") .. ".txt", false)
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_StorylineContinued", function(menu_manager)

	MenuCallbackHandler.storyline_continued_save = function(self, item)
		StorylineContinued:Save()
	end

	MenuCallbackHandler.callback_storyline_continued_language = function(self, item)
		StorylineContinued._data.language = item:value()
		StorylineContinued:Save()
	end

	StorylineContinued:Load()

	if StorylineContinued._data.language == nil then
		StorylineContinued._data.language = 1
		StorylineContinued:Save()
	end
	
	MenuHelper:LoadFromJsonFile(StorylineContinued._path .. "menu/storyline_continued_menu.json", StorylineContinued, StorylineContinued._data)
end)