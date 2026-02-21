# Web + Mobile Quickstart

## 已完成的基础改造

- 触摸映射到鼠标：`project.godot`
  - `input_devices/pointing/emulate_mouse_from_touch=true`
  - `input_devices/pointing/emulate_touch_from_mouse=true`
- 拉伸策略：`project.godot`
  - `window/stretch/aspect="expand"`
- 触摸事件支持
  - `ui/components/ItemCard.gd`
  - `ui/components/BoardSlot.gd`
  - `ui/effects/DragManager.gd`
- 主界面自适应（首轮）
  - `ui/MainMenu.gd`
  - `ui/GameModeSelect.gd`
  - `ui/CharacterSelect.gd`
  - `ui/GameBoard.gd`
  - `ui/components/BackpackDrawer.gd`

## 导出 Web

1. 在 Godot 安装 `Web Export Templates`。
2. `Project -> Export -> Add... -> Web`。
3. 导出到 `build/web/`（确保有 `index.html`）。
4. 首次建议先关闭 `Use Threads`，减少浏览器安全头配置复杂度。

## 本机开服（给手机访问）

在项目根目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run_web_server.ps1 -Port 8080
```

看到 `LAN: http://<你的IP>:8080/` 后，手机与电脑在同一局域网即可访问。

## 一键拿临时公网地址

导出完成后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\start_public_web.ps1 -Port 8080
```

脚本会：
- 在后台启动本地静态服务
- 启动 `cloudflared` 隧道
- 输出一个临时公网地址（`https://xxxx.trycloudflare.com`）

停止服务：

```powershell
Stop-Process -Id <server_pid>,<tunnel_pid> -Force
```

## 备用通道（已验证可用）

当 Cloudflare 隧道在当前网络不稳定时，使用 Pinggy：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\start_public_web_pinggy.ps1 -Port 8080
```

脚本会输出：
- `Public HTTPS`
- `Public HTTP`
- 停止命令（`Stop-Process -Id ... -Force`）

## 常见问题

- 手机打不开：检查防火墙是否放行 8080 端口，或放行 Python。
- 页面空白/报错：优先检查浏览器控制台，确认导出是否完整（`index.html`、`.wasm`、`.pck` 是否都在）。
- 操作手感不佳：优先在横屏测试；后续再做第二轮 UI 精细化适配。
