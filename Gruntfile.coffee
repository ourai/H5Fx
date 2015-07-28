module.exports = ( grunt ) ->
  pkg = grunt.file.readJSON "package.json"
  info =
    name: pkg.name.charAt(0).toUpperCase() + pkg.name.substring(1)
    version: pkg.version
  npmTasks = [
      "grunt-contrib-coffee"
      "grunt-contrib-uglify"
      "grunt-contrib-concat"
      "grunt-contrib-copy"
    ]

  grunt.initConfig
    repo: info
    pkg: pkg
    meta:
      temp: ".<%= pkg.name %>-cache"
    concat:
      coffee:
        files:
          "<%= meta.temp %>/<%= pkg.name %>.coffee": [
              "src/intro.coffee"
              "src/variables.coffee"
              "src/functions.coffee"
              "src/field.coffee"
              "src/form.coffee"
              "src/outro.coffee"
            ]
      js_normal:
        options:
          process: ( src, filepath ) ->
            return src.replace /@(NAME|VERSION)/g, ( text, key ) ->
              return info[key.toLowerCase()]
        src: [
            "build/intro.js"
            "<%= meta.temp %>/<%= pkg.name %>.js"
            "build/outro.js"
          ]
        dest: "<%= pkg.name %>.js"
    coffee:
      options:
        bare: true
        separator: "\x20"
      build_normal:
        src: "<%= meta.temp %>/<%= pkg.name %>.coffee"
        dest: "<%= meta.temp %>/<%= pkg.name %>.js"
      test:
        src: "test/test.coffee"
        dest: "test/test.js"
    uglify:
      options:
        banner: "/*!\n" +
                " * <%= repo.name %> v<%= repo.version %>\n" +
                " * <%= pkg.homepage %>\n" +
                " *\n" +
                " * Copyright 2015, <%= grunt.template.today('yyyy') %> Ourairyu, http://ourai.ws/\n" +
                " *\n" +
                " * Date: <%= grunt.template.today('yyyy-mm-dd') %>\n" +
                " */\n"
        sourceMap: false
      build_normal:
        src: "<%= pkg.name %>.js"
        dest: "<%= pkg.name %>.min.js"
    copy:
      test:
        expand: true
        cwd: "."
        src: ["*.js"]
        dest: "test"

  grunt.loadNpmTasks task for task in npmTasks

  # Tasks about CoffeeScript
  grunt.registerTask "compile_coffee", [
      "concat:coffee"
      "coffee:build_normal"
      "concat:js_normal"
      "uglify"
    ]
  grunt.registerTask "test", [
      "copy:test"
      "coffee:test"
    ]
  # Default task
  grunt.registerTask "default", [
      "compile_coffee"
      "test"
    ]
