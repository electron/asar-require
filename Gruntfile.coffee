module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      glob_to_multiple:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'

    coffeelint:
      src: ['src/**/*.coffee']
      test: ['spec/*.coffee']
      gruntfile: ['Gruntfile.coffee']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-coffeelint')

  grunt.registerTask 'clean', ->
    grunt.file.delete('lib') if grunt.file.exists('lib')

  grunt.registerTask('lint', ['coffeelint'])
  grunt.registerTask('default', ['coffee', 'lint'])
  grunt.registerTask('prepublish', ['clean', 'coffee', 'lint'])
