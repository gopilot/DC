var gulp = require('gulp');
var stylus = require('gulp-stylus');
var jade = require('gulp-jade');
var when = require('when');
var jsyaml = require('js-yaml');
var fs = require('fs');

var deploy = require("gulp-gh-pages");
var static = require('node-static');

//
// Create a node-static server instance to serve the './public' folder
//
var file = new static.Server('./out');

function runServer(port) {
    require('http').createServer(function (request, response) {
        request.addListener('end', function () {
            file.serve(request, response);
        }).resume();
    }).listen(port || 8000);
}


gulp.task('deploy', ['stylus', 'html', 'static', 'scripts'], function () {
    var remote = "https://github.com/gopilot/philly.git";

    return gulp.src("./out/**/*")
        .pipe( deploy( remote ) );
});

// compile css
gulp.task('stylus', function () {
    return gulp.src('./css/[!_]*.styl')
        .pipe(stylus({use: ['nib']}))
        .pipe(gulp.dest('./out/css'))
});

// compile our HTML
gulp.task('html', function() {
    var locals = jsyaml.load(fs.readFileSync('./info.yaml', 'utf8')); // load yaml
    return gulp.src('./[!_]*.jade')
        .pipe(jade({
            locals: locals
        }))
        .pipe(gulp.dest('./out'))
});

gulp.task('default', ['stylus', 'html', 'scripts', 'static'])

// copy over everything from the static folder (images, etc)
// NOTE: into the root of the out folder
gulp.task('static', function(){
    return gulp.src('./static/**')
        .pipe(gulp.dest('./out'));
});

gulp.task('scripts', function(){
    return gulp.src('./scripts/**')
        .pipe(gulp.dest('./out/scripts'))
});

gulp.task('watch', function() {
    runServer();
    gulp.watch('./static/**', ['static']);
    gulp.watch('./css/*.styl', ['stylus']);
    gulp.watch('./scripts/**/*.js', ['scripts'])
    gulp.watch(['./*.jade', './components/*.jade', './info.yaml'], ['html']);
});

