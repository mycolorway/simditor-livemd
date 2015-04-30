module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    coffee:
      src:
        options:
          bare: true
        files:
          'lib/simditor-livemd.js': 'src/simditor-livemd.coffee'
    watch:
      src:
        files: ['src/*.coffee']
        tasks: ['coffee:src', 'umd']

    umd:
      all:
        src: 'lib/simditor-livemd.js'
        template: 'umd.hbs'
        amdModuleId: 'simditor-livemd'
        objectToExport: 'SimditorLivemd'
        globalAlias: 'SimditorLivemd'
        deps:
          'default': ['$', 'SimpleModule', 'Simditor']
          amd: ['jquery', 'simple-module', 'simditor']
          cjs: ['jquery', 'simple-module', 'simditor']
          global:
            items: ['jQuery', 'SimpleModule', 'Simditor']
            prefix: ''

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-umd'

  grunt.registerTask 'default', ['coffee', 'umd', 'watch']

