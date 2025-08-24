ComputerProgressBar = ComputerProgressBar or class(ComputerObjectBase)

function ComputerProgressBar:init(tweak_data)
    ComputerProgressBar.super.init(self, tweak_data)
end

function ComputerProgressBar:create(parent_object, extension, parent)
    ComputerProgressBar.super.create(self, parent_object, extension, parent)

    self._object = parent_object:panel(self._tweak_data.config)
    self._text = self._object:text({
        name = "progress_text",
        text = "Progress: 0%",
        font = "fonts/font_large_mf",
        font_size = 50,
        color = Color.white,
        align = "center",
        vertical = "center"
    })
    self._text:set_center_x(self._parent:object():w() / 2)
    self._text:set_center_y(self._parent:object():h() / 2 - 40)

    self._timer = self._object:rect({
        name = "timer",
        color = Color.white,
        w = self._parent:object():w() - self._parent:object():w() / 3,
        h = 50,
        y = self._parent:object():h() / 2 + 10,
        vertical = "center",
        layer = 1
    })
    self._timer:set_center_x(self._parent:object():w() / 2)

    self._timer_bg = self._object:rect({
        name = "timer_bg",
        color = Color.white,
        alpha = 0.5,
        w = self._timer:w() + 10,
        h = self._timer:h() + 10,
        vertical = "center",
        layer = 0
    })
    self._timer_bg:set_center(self._timer:center())
end

function ComputerProgressBar:clbk_start(window, ...)
    if not self._sent_event then
        self._sent_event = true
        managers.mission:call_global_event("hack_window_opened")
    end

    if self.extension.values.inserted_drive == "false" then
        self._parent:trigger_event("prompt_insert_drive")
        self._timer:set_visible(false)
        return
    end

    if not self._started and not self._complete then
        self._started = true
        self._tweak_data.events.open.enabled = false

        self._timer_amount = 10
        self._current_timer = self._timer_amount
        self._timer_length = self._timer:w()
        self._timer:set_color(Color.yellow)
        self._timer:set_visible(true)

        self._timer:set_w(self._timer_length * (1 - self._current_timer / self._timer_amount))
        self._text:set_text("Progress: " .. math.floor((1 - self._current_timer / self._timer_amount) * 100) .. "%")
    end
end

function ComputerProgressBar:done()
    self._started = false
    self._complete = true
    self._timer:set_color(Color.green)
    self.extension:post_event("und_harddrive_shutdown", nil, nil, true)
    self._next_window_timer = 4
end

function ComputerProgressBar:update(t, dt)
    if self._parent:active_child_window() and not self._complete then
        if self.extension.values.inserted_drive == "true" then
            self._parent:active_child_window():trigger_event("close")
            self:clbk_start() -- Call it again, but this time set self._started.
        else
            return
        end
    end

    if self._started and not self._complete then
        self._current_timer = self._current_timer - dt
        self._timer:set_w(self._timer_length * (1 - self._current_timer / self._timer_amount))
        self._text:set_text("Progress: " .. math.floor((1 - self._current_timer / self._timer_amount) * 100) .. "%")

        if self._current_timer <= 0 then
            self:done()
        end

        if not self._audio then
            self._audio = true
            self.extension:post_event("und_harddrive_access")
        end
    end

    if self._next_window_timer then
        self._next_window_timer = self._next_window_timer - dt

        if self._next_window_timer <= 0 then
            self._next_window_timer = nil
            self._parent:trigger_event("play_video")
        end
    end
end