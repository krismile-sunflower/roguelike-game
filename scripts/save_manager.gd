# SaveManager - 游戏存档管理器
# 使用 JSON 序列化保存/加载游戏数据
# 支持：最高分、关卡进度、音量设置、游玩时间
extends Node

# ==================== 存档数据结构 ====================

# 存档数据字典
var save_data: Dictionary = {
    "high_score": 0,
    "max_level": 1,
    "total_play_time": 0.0,
    "games_played": 0,
    "games_won": 0,
    "last_save_time": 0,
    "settings": {
        "sfx_volume": 1.0,
        "bgm_volume": 0.7,
        "sfx_enabled": true,
        "bgm_enabled": true,
    }
}

# 存档文件路径
var save_path: String = "user://savegame.json"

# 是否已加载
var is_loaded: bool = false


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
    # 尝试加载存档
    load_save()
    print("存档管理器已就绪")


# ==================== 公共方法：保存 ====================

# 保存完整存档
func save_all() -> void:
    # 更新最后保存时间
    save_data["last_save_time"] = Time.get_unix_time_from_system()

    # 序列化为 JSON
    var json_str := JSON.stringify(save_data, "\t")  # 带缩进，方便阅读

    # 写入文件
    var file := FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_string(json_str)
        file.close()
        print("存档已保存:", save_path)
    else:
        push_error("无法保存存档:", save_path)


# 保存最高分
func save_high_score(score: int) -> void:
    if score > save_data["high_score"]:
        save_data["high_score"] = score
        save_all()  # 同时保存完整存档


# 保存关卡进度
func save_level_progress(level: int) -> void:
    if level > save_data["max_level"]:
        save_data["max_level"] = level
        save_all()


# 增加游玩统计
func increment_stats(games_won: bool = false) -> void:
    save_data["games_played"] += 1
    if games_won:
        save_data["games_won"] += 1
    save_all()


# 保存游玩时间
func save_play_time(seconds: float) -> void:
    save_data["total_play_time"] += seconds
    save_all()


# ==================== 公共方法：加载 ====================

# 加载存档
func load_save() -> bool:
    if not FileAccess.file_exists(save_path):
        print("没有找到存档文件，使用默认数据")
        _reset_save_data()
        return false

    var file := FileAccess.open(save_path, FileAccess.READ)
    if not file:
        push_error("无法读取存档文件")
        return false

    var json_str := file.get_as_text()
    file.close()

    # 解析 JSON
    var parsed := JSON.parse_string(json_str)
    if parsed is Dictionary:
        # 合并数据（保留新字段）
        _merge_save_data(parsed)
        is_loaded = true
        print("存档已加载")
        return true
    else:
        push_error("存档文件格式错误")
        _reset_save_data()
        return false


# 获取最高分
func get_high_score() -> int:
    return save_data.get("high_score", 0)


# 获取最大关卡
func get_max_level() -> int:
    return save_data.get("max_level", 1)


# 获取总游玩时间（秒）
func get_total_play_time() -> float:
    return save_data.get("total_play_time", 0.0)


# 获取游玩统计
func get_play_stats() -> Dictionary:
    return {
        "games_played": save_data.get("games_played", 0),
        "games_won": save_data.get("games_won", 0),
        "total_play_time": save_data.get("total_play_time", 0.0),
    }


# 获取设置
func get_settings() -> Dictionary:
    return save_data.get("settings", {})


# ==================== 公共方法：清除 ====================

# 清除存档（重置所有数据）
func clear_save() -> void:
    if FileAccess.file_exists(save_path):
        DirAccess.remove_absolute(save_path)
        print("存档已清除")
    _reset_save_data()


# 导出存档数据为字符串（用于分享/调试）
func export_save_string() -> String:
    return JSON.stringify(save_data, "  ")


# 导入存档数据（从字符串）
func import_save_string(json_str: String) -> bool:
    var parsed := JSON.parse_string(json_str)
    if parsed is Dictionary:
        _merge_save_data(parsed)
        save_all()
        return true
    return false


# ==================== 私有方法 ====================

# 重置为默认存档数据
func _reset_save_data() -> void:
    save_data = {
        "high_score": 0,
        "max_level": 1,
        "total_play_time": 0.0,
        "games_played": 0,
        "games_won": 0,
        "last_save_time": 0,
        "settings": {
            "sfx_volume": 1.0,
            "bgm_volume": 0.7,
            "sfx_enabled": true,
            "bgm_enabled": true,
        }
    }
    is_loaded = false


# 合并存档数据（保留未知字段）
func _merge_save_data(new_data: Dictionary) -> void:
    for key in new_data:
        if key in save_data:
            if typeof(save_data[key]) == TYPE_DICTIONARY and typeof(new_data[key]) == TYPE_DICTIONARY:
                # 递归合并子字典
                for sub_key in new_data[key]:
                    save_data[key][sub_key] = new_data[key][sub_key]
            else:
                save_data[key] = new_data[key]
        else:
            # 新增字段，直接添加
            save_data[key] = new_data[key]
