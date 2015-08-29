module.exports = function(grunt){
    grunt.initConfig({
        browserify: {
            dist: {
                options: {

                    transform: [
                        
                        ["babelify", {
                            loose: "all"
                        }],
                        ["brfs"]
                    ]
                },
                files: {
                    "./dist/module.js": ["./js/index.js"]
                }
            }
        },
        elm: {
            compile: {
                files: {
                    "./dist/elm.js": ["./elm/*.elm"]
                }
            }
        },
        watch: {
            scripts: {
                files: ["./elm/*.elm","./js/*.js"],
                tasks: ["browserify", "elm"]
            }
        }
    })

    grunt.loadNpmTasks("grunt-browserify")
    grunt.loadNpmTasks("grunt-contrib-watch")
    grunt.loadNpmTasks("grunt-elm")
    
    grunt.registerTask("default", ["watch"]);
    grunt.registerTask("build", ["browserify", "elm"]);

}