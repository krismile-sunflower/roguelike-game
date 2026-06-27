# GameData - 全局游戏数据单例
# 用途：管理玩家生命值、分数等全局状态
# 通过 AutoLoad 机制，游戏任意脚本都可通过 GameData 访问这些数据
extends Node

# ==================== 属性 ====================

# 玩家当前生命值（默认 3）
# 使用 setter 确保值在 0-3 范围内，并在变化时发出信号通知 UI
var player_health: int = 3:
    set(val):
        player_health = clamp(val, 0, 3)  # 限制在 0 到 3 之间
        health_changed.emit(player_health)  # 发出变化信号
        if player_health <= 0:
            print("游戏结束！")

# 玩家当前分数（默认 0）
# 使用 setter 确保值非负，并在变化时发出信号通知 UI
var score: int = 0:
    set(val):
        score = max(0, val)  # 分数不能为负数
        score_changed.emit(score)  # 发出变化信号

# ==================== 信号 ====================

# 当分数变化时发出，参数为新分数
signal score_changed(new_score: int)

# 当生命值变化时发出，参数为新生命值
signal health_changed(new_health: int)

# ==================== 方法 ====================

# 增加分数
# 参数 amount: 每次增加的分数（默认 1）
func add_score(amount: int = 1) -> void:
    score += amount  # 直接修改 score，触发 setter 中的信号
    print("得分 +", amount, "，当前总分:", score)

# 受到伤害，减少生命值
# 参数 amount: 每次扣除的生命值（默认 1）
func take_damage(amount: int = 1) -> void:
    player_health -= amount  # 直接修改 player_health，触发 setter 中的信号

# 恢复生命值
# 参数 amount: 恢复的生命值（默认 1）
func heal(amount: int = 1) -> void:
    player_health += amount  # 直接修改 player_health，触发 setter 中的信号

# 重置游戏数据到初始状态
func reset() -> void:
    player_health = 3
    score = 0
    print("游戏数据已重置")
