import importer from  "./importer"



const storedState = localStorage.getItem("draftState")
const startingState = storedState ? JSON.parse(storedState) : importer()

console.log("starting State", startingState)
const app = Elm.fullscreen(Elm.App, 
        { 
            getState: startingState,
            swipe: null 
        })

const ports = app.ports

ports.setState.subscribe((state)=>{
    localStorage.setItem("draftState", JSON.stringify(state));
})

var hammers = []


ports.gestureListener.subscribe((model)=>{
    var action = "draft"
    var left = "DRAFT(THEM)"
    var right = "DRAFT(MINE)"
    if(model.screen == "Drafted" || model.screen == "My Team"){
        action = "undraft"
        left = "UNDRAFT"
        right = "UNDRAFT"
    }
    hammers.map(function(hammer){
        Object.keys(hammer.handlers).forEach(function(handler){
            delete hammer.handlers[handler]
        })
    })
    hammers = []

    

    $(".swipable").each((index, elem)=>{
        //elem.removeAllListeners()
        
        var gesture = new Hammer(elem)
        hammers.push(gesture)
        gesture.off("panleft panright panend pancancel")

        gesture.get("pan").set({
            direction: Hammer.DIRECTION_HORIZONTAL
        })
    
        gesture.on("panleft panright", handlePan)
        gesture.on("panend pancancel", handleEnd)
        
        function handlePan(ev){     
            if(ev.deltaX > 0){
                var span = $(elem).find(".draftStamp")
                span.text(right)
                span.css("opacity", (ev.deltaX / 140))
            }else if(ev.deltaX < 0){
                var span = $(elem).find(".draftStamp")
                span.text(left)
                span.css("opacity", ((-ev.deltaX) / 140))
            }  
        }

        function handleEnd(ev){
            $(elem).find(".draftStamp").css("opacity","0")
            if (ev.deltaX > 140)
                sendSwipe("right",$(elem).attr("id"), action)
            else if (ev.deltaX < -140)
                sendSwipe("left", $(elem).attr("id"), action)
        }
    })

    
})


function sendSwipe(direction, id, action){
    console.log(arguments)
    ports.swipe.send({
        action: action,
        player: id,
        direction: direction
    })
}
