# Async scripts

If you want to generate `async` script, you can need only to declare `async` in your templates like this:

```twig
  <!-- dev:test.js async --><!-- endbuild -->
```

The output will looks like this:
```twig
  <!-- dev:test.js async -->
    <script async type="text/javascript" src="/test.js" />
  <!-- endbuild -->
```
