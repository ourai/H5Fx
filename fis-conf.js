fis.set("project.ignore", fis.get("project.ignore").concat([
  "bower_components/**",
  //"*-INF/**",
  //"velocity/**",
  "bower.json",
  "package.json",
  ".*"
]));

fis.hook("commonjs");

fis
  .match("*.html", {
    useCompile: false
  })
  .match("/src/(**).js", {
    release: "/dist/$1",
    moduleId: "dist/$1",
    isMod: true,
    deploy: fis.plugin("local-deliver", {to: "."})
  })
  // .match("/dist/**.js", {
  //   packTo: "/h5fx.js",
  //   deploy: fis.plugin("local-deliver", {to: "."})
  // })
  .match("/src/index.js", {
    isMod: false
  });
