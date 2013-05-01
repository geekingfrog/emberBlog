module.exports = (grunt) ->
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')

    coffee: {
      compile:
        expand: true
        cwd: '.'
        src: ['*.coffee', '!Gruntfile.coffee']
        dest: '.'
        ext: '.js'
    } # end coffee

    sass: {
      dev:
        options: {trace: true, style: 'expanded'}
        files: {'blog/assets/css/frog.css': "blog/assets/css/scss/frog.scss"}
    } # end sass

    'compile-handlebars':
      dev:
        template: 'blog/index.html.handlebars'
        templateData: {production: false}
        output: 'blog/index.html'

    ember_templates: {
      compile:
        options:
          # compile templates in **/templates directories. A template is a file
          # whose name ends in .handlebars
          # All template are registered using the filename, regardless of their path
          # If the template should contains a slash, like post/index for example,
          # name it post.index.handlebars
          templateName: (filename) ->
            target = filename.replace(/.*templates\//i, '').replace('.','/')
            grunt.log.writeln 'register template: '+target
            return target
        files: {'blog/templates.js': 'blog/**/templates/*.handlebars'}
    } # end ember_templates

    browserify: {
      dev:
        src: 'blog/app.js'
        dest: 'blog/blog.js'
        options: {
          # debug: true
          ignore: 'blog/vendor/**'
        }
    } # end browserify 

    exec: {
      server:
        cmd: 'node server/server.js'
        # stdout: true
        # stderr: true
    } # end exec

    watch: {
      sass: {
        files: 'blog/assets/css/**/*.scss'
        tasks: ['sass']
      }
      index: {
        files: 'blog/index.html.handlebars'
        tasks: 'compile-handlebars:dev'
      }
      ember: {
        files: 'blog/**/templates/*.handlebars'
        tasks: ['ember_templates']
      }
      browserify: {
        files: ['blog/**/*.js', '!blog/blog.js', '!blog/vendor/**']
        tasks: ['browserify']
      }
    }
  })

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-compile-handlebars'
  grunt.loadNpmTasks 'grunt-ember-templates'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-exec'

  grunt.registerTask 'default', [
    'sass'
    'coffee'
    'ember_templates'
    'browserify'
    'compile-handlebars'
  ]

  grunt.registerTask 'server', ['coffee', 'exec:server']

