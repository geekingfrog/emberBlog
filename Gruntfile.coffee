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
        templateData:
          production: false
          scripts: [
            'vendor/lodash.js'
            'vendor/jquery-1.9.1.js'
            'vendor/handlebars-1.0.0-rc.3.js'
            'vendor/ember-1.0.0-rc.3.js'
            'vendor/moment.js'
            'vendor/highlight.pack.js'
            'blog.js'
          ]

        output: 'blog/devIndex.html'

      dist:
        template: 'blog/index.html.handlebars'
        output: 'blog/index.html'
        templateData:
          production: true
          scripts: [
            '//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.2.1/lodash.min.js'
            '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js'
            '//cdnjs.cloudflare.com/ajax/libs/handlebars.js/1.0.0-rc.3/handlebars.min.js'
            '//cdnjs.cloudflare.com/ajax/libs/ember.js/1.0.0-rc.3/ember.min.js'
            '//cdnjs.cloudflare.com/ajax/libs/moment.js/2.0.0/moment.min.js'
            'assets/vendor/highlight.pack.js'
            'blog.min.js'
          ]


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
      generic:
        src: 'blog/app.js'
        dest: 'blog/blog.js'
        options: {
          ignore: 'blog/vendor/**'
        }
    } # end browserify 

    uglify: {
      dist:
        files:
          'blog/blog.min.js': ['blog/blog.js']
    }

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
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.registerTask 'default', [
    'sass'
    'coffee'
    'ember_templates'
    'browserify'
    'compile-handlebars:dev'
  ]

  grunt.registerTask 'dist', [
    'sass'
    'coffee'
    'ember_templates'
    'browserify'
    'uglify:dist'
    'compile-handlebars:dist'
  ]

  grunt.registerTask 'server', ['coffee', 'exec:server']

