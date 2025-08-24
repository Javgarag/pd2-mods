ComputerVideo = ComputerVideo or class(ComputerObjectBase)

function ComputerVideo:init(tweak_data)
    ComputerVideo.super.init(self, tweak_data)
end

function ComputerVideo:create(parent_object, extension, parent)
    ComputerVideo.super.create(self, parent_object, extension, parent)

    self._object = parent_object:video(self._tweak_data.config)
    self._object:pause()
end

function ComputerVideo:play_video()
    -- Note on videos; their sound seems to be uncontrolable and plays at full volume regardless of how far the player is to the computer.
    -- Either use a video with no volume and use PlaySound or mute it alltogether.
    self._object:play()
    self._object:set_volume_gain(((managers.user:get_setting("sfx_volume") or 100) / 100) or 1)

    managers.mission:call_global_event("video_played")
end

function ComputerVideo:update(t, dt)
    if alive(self._object) and self._object:loop_count() > 0 and self._parent:is_open() then
        self._object:pause()
        self._object:rewind()
        self._parent:trigger_event("close")
        managers.mission:call_global_event("video_finished")
    end
end