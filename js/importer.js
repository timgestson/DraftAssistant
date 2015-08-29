const fs = require("fs")
const csv = require("papaparse")
const path = require("path")


let adp = fs.readFileSync(
    path.join(__dirname, 
        "../data/adp.csv")
    ).toString()


function importer(){
    const parsedAdp = csv.parse(adp, {header: true, dynamicTyping: true})
    const players = parsedAdp.data
    .map((player)=>{
        let parsedPlayer =  {
            name: player["Name"],
            position: player["Position"],
            bye: player["Bye"] || 0,
            drafted: false,
            positionalRank: player["Rank"] || 0,
            positionalTier: player["Tier"] || 0,
            adp: player["ADP"],
            onMyTeam: false
        }
        return parsedPlayer
    }).filter((player)=> player.name)

    return {
        players: players,
        screen: "Home"
    }
}
export default importer
