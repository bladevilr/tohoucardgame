## 平衡性一键测试 (Balance Runner)
##
## 一键运行所有平衡性测试工具, 输出综合报告。
## 可在 Godot 编辑器中通过 @tool 脚本运行, 或作为场景挂载。
##
## 用法:
##   - 在编辑器中创建一个 Node, 挂上此脚本
##   - 按 F6 运行当前场景
##   - 控制台会输出所有测试结果到 user://balance_report.txt
##
## 也可在代码中调用:
##   var runner = BalanceRunner.new()
##   runner.run_all()

@tool
extends Node

@export var sims_per_test: int = 200
@export var run_on_ready: bool = true

func _ready():
	if run_on_ready:
		run_all()

func run_all():
	var full_report := ""
	var start_time = Time.get_ticks_msec()

	print("=" .repeat(60))
	print("  平衡性全量测试 开始")
	print("  模拟次数/测试项: %d" % sims_per_test)
	print("=" .repeat(60))

	# 1. 菜系均衡
	print("\n[1/4] 菜系均衡循环赛...")
	var cuisine_test = CuisineBalanceTest.new()
	var cuisine_result = cuisine_test.run_round_robin(sims_per_test)
	var cuisine_report = cuisine_test.print_matrix(cuisine_result)
	print(cuisine_report)
	full_report += cuisine_report + "\n\n"

	# 2. PvE 打野校准
	print("\n[2/4] PvE 打野校准...")
	var encounter_cal = EncounterCalibrator.new()
	var encounter_result = encounter_cal.calibrate()
	var encounter_report = encounter_cal.format_report(encounter_result)
	print(encounter_report)
	full_report += encounter_report + "\n\n"

	# 3. 经济曲线
	print("\n[3/4] 经济曲线分析...")
	var economy = EconomyAnalyzer.new()
	var economy_result = economy.simulate_run(sims_per_test)
	var economy_report = economy.format_report(economy_result)
	print(economy_report)
	full_report += economy_report + "\n\n"

	# 4. 单卡强度
	print("\n[4/4] 单卡强度排名 (这可能需要较长时间)...")
	var ranker = CardPowerRanker.new()
	var rank_result = ranker.rank_all_cards(sims_per_test)
	var rank_report = ranker.format_report(rank_result)
	print(rank_report)
	full_report += rank_report + "\n\n"

	# 汇总
	var elapsed = (Time.get_ticks_msec() - start_time) / 1000.0
	var summary = "\n" + "=" .repeat(60) + "\n"
	summary += "  测试完成, 耗时 %.1f 秒\n" % elapsed
	summary += "  菜系失衡: %d 对\n" % cuisine_result.imbalanced_matchups.size()
	summary += "  超模卡: %d 张\n" % rank_result.op_cards.size()
	summary += "  废卡: %d 张\n" % rank_result.weak_cards.size()
	summary += "=" .repeat(60)
	print(summary)
	full_report += summary

	# 保存报告到文件
	var report_path: String = "user://balance_report.txt"
	var file = FileAccess.open(report_path, FileAccess.WRITE)
	if file:
		file.store_string(full_report)
		file.close()
		print("\n报告已保存至 %s" % report_path)
	else:
		push_warning("无法保存报告文件")
