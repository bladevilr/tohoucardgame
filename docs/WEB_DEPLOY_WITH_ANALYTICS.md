# Web 部署 + 玩家统计（独立 IP）

这套方案用于 Godot Web 导出包的自建部署，统计：
- 总访问事件数
- 不同 IP 数（`unique_ips`）
- 不同设备 ID 数（`unique_clients`）
- 24 小时 / 7 天 / 今日独立 IP

统计接口：
- `GET /api/stats`
- 若配置了 token：`GET /api/stats?token=你的token`

---

## 1. 本地启动（Windows）

先导出到 `build/web`，然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run_web_analytics_server.ps1 -Port 8080
```

打开：
- 游戏：`http://127.0.0.1:8080/`
- 统计：`http://127.0.0.1:8080/api/stats`

可选参数：
- `-StatsToken "your-secret-token"`
- `-TrustXForwardedFor`（反代场景下才开）

---

## 2. Linux 服务器部署

假设你把项目放在 `/opt/touhoubazaar`，并且 Web 导出在 `/opt/touhoubazaar/build/web`。

### 2.1 直接运行

```bash
cd /opt/touhoubazaar
python3 tools/web_analytics_server.py \
  --root build/web \
  --host 127.0.0.1 \
  --port 18080 \
  --data-file /var/lib/touhoubazaar/events.jsonl \
  --stats-token "replace-with-a-strong-token" \
  --trust-x-forwarded-for
```

说明：
- 建议监听 `127.0.0.1`，由 Nginx 反代对外。
- `--trust-x-forwarded-for` 只在你确认前面是可信反代时启用。

### 2.2 systemd 守护

`/etc/systemd/system/touhoubazaar-web.service`：

```ini
[Unit]
Description=TouhouBazaar Web Analytics Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/touhoubazaar
ExecStart=/usr/bin/python3 /opt/touhoubazaar/tools/web_analytics_server.py --root /opt/touhoubazaar/build/web --host 127.0.0.1 --port 18080 --data-file /var/lib/touhoubazaar/events.jsonl --stats-token replace-with-a-strong-token --trust-x-forwarded-for
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

启用并启动：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now touhoubazaar-web
sudo systemctl status touhoubazaar-web
```

---

## 3. Nginx 反代示例

`/etc/nginx/sites-available/touhoubazaar.conf`：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:18080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

启用：

```bash
sudo ln -s /etc/nginx/sites-available/touhoubazaar.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

再用 Certbot 配 HTTPS（建议）：

```bash
sudo certbot --nginx -d your-domain.com
```

---

## 4. 查看统计

示例：

```bash
curl "https://your-domain.com/api/stats?token=replace-with-a-strong-token"
```

关键字段：
- `unique_ips`: 总独立 IP 数
- `unique_clients`: 总独立设备 ID 数
- `unique_ips_24h`: 最近 24 小时独立 IP
- `by_day`: 按天统计（事件/独立 IP/独立设备）

---

## 5. 注意事项

- 这个统计是“轻量自建”方案，不是完整 BI 系统。
- IP 统计会受 NAT/代理影响，建议同时看 `unique_clients`。
- 若有隐私合规要求（例如 GDPR/本地法规），请补充隐私政策与告知。
- `events.jsonl` 会持续增长，建议定期归档或切分。
