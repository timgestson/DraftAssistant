var express = require("express")
var app = express()
app.set('port', (process.env.PORT || 8082));
app.use(express.static(__dirname));

app.get("/", function(req, resp){
    resp.redirect("/index.html")
    })
    app.listen(app.get("port"), function(){
        console.log("App listening on port " + app.get("port"))  
	})
