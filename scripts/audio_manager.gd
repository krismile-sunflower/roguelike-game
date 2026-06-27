# AudioManager - 全局音频管理器
# 使用 AutoLoad 单例，游戏任意处通过 AudioManager.play_sound(...) 播放音效
# 支持音效(SFX)和背景音乐(BGM)分离管理
extends Node

# ==================== 音效预设 ====================

# 音效字典：key 为音效名称，value 为音频资源路径
var sfx_presets: Dictionary = {
    "jump": "res://assets/audio/sfx/jump.ogg",
    "collect": "res://assets/audio/sfx/collect.ogg",
    "hurt": "res://assets/audio/sfx/hurt.ogg",
    "enemy_die": "res://assets/audio/sfx/enemy_die.ogg",
    "powerup": "res://assets/audio/sfx/powerup.ogg",
    "game_over": "res://assets/audio/sfx/game_over.ogg",
    "level_start": "res://assets/audio/sfx/level_start.ogg",
    "pause": "res://assets/audio/sfx/pause.ogg",
}

# 背景音乐预设
var bgm_presets: Dictionary = {
    "title": "res://assets/audio/bgm/title.ogg",
    "gameplay": "res://assets/audio/bgm/gameplay.ogg",
    "game_over": "res://assets/audio/bgm/game_over.ogg",
}


# ==================== 节点引用 ====================

# 音效播放器组（每个音效一个独立的 AudioStreamPlayer）
var sfx_players: Dictionary = {}

# 当前背景音乐播放器
var current_bgm_player: AudioStreamPlayer = null

# 当前背景音乐流
var current_bgm: AudioStream = null

# 音量设置（0.0 = 静音，1.0 = 最大）
var sfx_volume: float = 1.0
var bgm_volume: float = 0.7

# 是否启用音效
var sfx_enabled: bool = true

# 是否启用背景音乐
var bgm_enabled: bool = true


# ==================== 生命周期 ====================

# 场景初始化：创建音效播放器池
func _ready() -> void:
    # 为每个预设音效创建一个 AudioStreamPlayer
    for key in sfx_presets:
        var player: AudioStreamPlayer = AudioStreamPlayer.new()
        player.bus = "SFX"  # 使用 SFX 混音轨道
        player.stream = load(sfx_presets[key]) if sfx_presets[key] != "" else null
        player.volume_db = linear_to_db(sfx_volume)
        add_child(player)
        sfx_players[key] = player

    print("音频管理器已就绪，音效数量:", sfx_players.size())


# ==================== 公共方法 ====================

# 播放音效
# sound_key: 音效预设中的 key
# loop: 是否循环（音效通常不循环）
func play_sound(sound_key: String, loop: bool = false) -> void:
    if not sfx_enabled:
        return

    if sound_key in sfx_players:
        var player: AudioStreamPlayer = sfx_players[sound_key]
        if player.stream:
            player.loop = loop
            player.play()
        else:
            # 如果音效文件不存在，跳过（不影响游戏运行）
            pass
    else:
        push_warning("未找到音效预设:", sound_key)


# 停止音效
func stop_sound(sound_key: String) -> void:
    if sound_key in sfx_players:
        sfx_players[sound_key].stop()


# 停止所有音效
func stop_all_sounds() -> void:
    for key in sfx_players:
        sfx_players[key].stop()


# 播放背景音乐
# bgm_key: 背景音乐预设中的 key
# fade_in_seconds: 淡入时间（秒）
func play_bgm(bgm_key: String, fade_in_seconds: float = 0.0) -> void:
    if not bgm_enabled:
        return

    if bgm_key in bgm_presets:
        var stream: AudioStream = load(bgm_presets[bgm_key]) if bgm_presets[bgm_key] != "" else null

        if stream:
            # 如果正在播放同一首，不重复播放
            if current_bgm == stream:
                return

            # 停止旧的音乐
            if current_bgm_player:
                current_bgm_player.stop()

            # 创建新的播放器
            current_bgm_player = AudioStreamPlayer.new()
            current_bgm_player.bus = "BGM"  # 使用 BGM 混音轨道
            current_bgm_player.stream = stream
            current_bgm_player.volume_db = linear_to_db(bgm_volume)
            current_bgm_player.loop = true
            add_child(current_bgm_player)
            current_bgm_player.play()
            current_bgm = stream

            # 淡入效果
            if fade_in_seconds > 0:
                current_bgm_player.volume_db = linear_to_db(0.0)
                var tween: Tween = create_tween()
                tween.tween_property(current_bgm_player, "volume_db", linear_to_db(bgm_volume), fade_in_seconds)


# 停止背景音乐
func stop_bgm(fade_out_seconds: float = 0.0) -> void:
    if current_bgm_player:
        if fade_out_seconds > 0:
            # 淡出效果
            var tween: Tween = create_tween()
            tween.tween_property(current_bgm_player, "volume_db", linear_to_db(0.0), fade_out_seconds)
            tween.tween_callback(func(): current_bgm_player.stop())
        else:
            current_bgm_player.stop()


# 暂停/恢复背景音乐
func toggle_bgm_pause() -> void:
    if current_bgm_player:
        if current_bgm_player.playing:
            current_bgm_player.pause()
        else:
            current_bgm_player.play()


# 设置音效音量
func set_sfx_volume(volume: float) -> void:
    sfx_volume = clamp(volume, 0.0, 1.0)
    for key in sfx_players:
        sfx_players[key].volume_db = linear_to_db(sfx_volume)


# 设置背景音乐音量
func set_bgm_volume(volume: float) -> void:
    bgm_volume = clamp(volume, 0.0, 1.0)
    if current_bgm_player:
        current_bgm_player.volume_db = linear_to_db(bgm_volume)


# 切换音效开关
func toggle_sfx(enabled: bool) -> void:
    sfx_enabled = enabled


# 切换背景音乐开关
func toggle_bgm(enabled: bool) -> void:
    bgm_enabled = enabled


# 保存音量设置到本地
func save_volume_settings() -> void:
    var settings: Dictionary = {
        "sfx_volume": sfx_volume,
        "bgm_volume": bgm_volume,
        "sfx_enabled": sfx_enabled,
        "bgm_enabled": bgm_enabled,
    }
    var json_str: String = JSON.stringify(settings)

    # 保存到用户数据目录
    var save_path: String = "user://audio_settings.json"
    var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)

    if file:
        file.store_string(json_str)
        file.close()
        print("音频设置已保存")


# 从本地加载音量设置
func load_volume_settings() -> void:
    var save_path: String = "user://audio_settings.json"

    if FileAccess.file_exists(save_path):
        var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)

        if file:
            var json_str: String = file.get_as_text()

            file.close()
            var settings: Variant = JSON.parse_string(json_str)

            if settings is Dictionary:
                sfx_volume = settings.get("sfx_volume", 1.0)
                bgm_volume = settings.get("bgm_volume", 0.7)
                sfx_enabled = settings.get("sfx_enabled", true)
                bgm_enabled = settings.get("bgm_enabled", true)
                # 应用设置
                set_sfx_volume(sfx_volume)
                set_bgm_volume(bgm_volume)
                print("音频设置已加载")


# 线性音量转分贝
static func linear_to_db(linear: float) -> float:
    if linear <= 0.0:
        return -80.0  # 静音的分贝值
    return 20.0 * log(linear) / log(10.0)
