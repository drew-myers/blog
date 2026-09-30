<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>◊(select 'h1 doc)</title>
  <link rel="stylesheet" href="/styles.css">
</head>
<body>
  <header class="site-header">
    <a href="/"><strong>My Blog</strong></a>
  </header>

  <main>
    ◊(->html doc #:splice? #t)
  </main>

  <footer class="site-footer">
    <p>Built with Pollen. Nobody reads this, and that's fine.</p>
  </footer>
</body>
</html>
