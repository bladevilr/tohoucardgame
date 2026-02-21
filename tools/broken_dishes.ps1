# 破损/透明背景菜品清单（需要重新生成）
# 文件大小 < 600KB，说明图片被错误扣除了背景

$broken_dishes = @(
    @{ id = "yakitori"; name = "焼き鳥"; desc = "grilled chicken skewers - three plump glazed chicken skewers on a small ceramic plate" },
    @{ id = "hashimaki"; name = "筷卷"; desc = "okonomiyaki rolled on chopsticks - savory pancake rolled onto disposable chopsticks, topped with brown sauce, mayo, and bonito flakes" },
    @{ id = "corn_potage"; name = "コーンポタージュ"; desc = "creamy corn soup - a white bowl filled with thick golden creamy corn soup with croutons and cream swirl on top" },
    @{ id = "omurice"; name = "オムライス"; desc = "omelet rice - golden-yellow omelet pillow over ketchup rice with a zigzag of bright red ketchup on a white oval plate" },
    @{ id = "beef_stew"; name = "ビーフシチュー"; desc = "beef stew - a piping hot bowl of rich dark brown beef stew with tender meat chunks, carrots, and potatoes" },
    @{ id = "scotch_egg"; name = "スコッチエッグ"; desc = "scotch egg - a scotch egg sliced in half revealing a soft-boiled golden yolk, sitting on greens" },
    @{ id = "napolitan"; name = "ナポリタン"; desc = "Japanese ketchup spaghetti - twirled mound of glossy red ketchup spaghetti with sliced sausages and green pepper on a round plate" },
    @{ id = "cabbage_roll"; name = "ロールキャベツ"; desc = "cabbage rolls - tender stuffed cabbage rolls simmering in light tomato broth in a small dish" },
    @{ id = "ratatouille"; name = "ラタトゥイユ"; desc = "ratatouille - a beautiful circular arrangement of thinly sliced colorful layered vegetables baked in tomato sauce" },
    @{ id = "pot_au_feu"; name = "ポトフ"; desc = "pot au feu - rustic French beef and vegetable stew in a small pot with clear warm broth" },
    @{ id = "chateaubriand"; name = "シャトーブリアン"; desc = "chateaubriand steak - thick premium cut medium-rare beef tenderloin steak sliced on a high-end plate with garnish" }
)

Write-Host "Broken dishes requiring regeneration:"
$broken_dishes | ForEach-Object { Write-Host " - $($_.id) ($($_.name))" }
