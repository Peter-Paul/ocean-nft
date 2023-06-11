const express = require("express")
const cors = require("cors")
const cookieParser=require("cookie-parser")
const { port } =  require("./constants.js")
const coinRoutes = require("./routes/coins.js")
const voteRoutes = require("./routes/votes.js")
const bannerRoutes = require("./routes/banners.js")
const subscriptionRoutes = require("./routes/subscription.js")

const app = express()

app.use(express.json())
app.use(cookieParser())

app.use(cors())
// app.use(cors({
//     // origin:["http://localhost:3000","http://localhost:8080"],
//     origin:["*"],
//     credentials:true,
//     methods:['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
//     exposedHeaders:['Content-Length','Content-Type','Set-Cookie','Origin','Access-Control-Allow-Credentials','Access-Control-Allow-Origin' ]
// }))

//routes
app.use('/coins',coinRoutes)
app.use('/votes',voteRoutes)
app.use('/banners',bannerRoutes)
app.use('/subscribe',subscriptionRoutes)

app.listen( port, () => console.log(`Node server running on port ${port}`)  )